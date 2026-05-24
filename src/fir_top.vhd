----------------------------------------------------------------------------------
-- Module Name : fir_top - Behavioral
-- Description : Top-level systeme FIR sur Nexys A7 (Artix-7 XC7A100T).
--               Instancie clk_div, fsm, pmod_adc, pmod_dac et fir_base.
--
-- Generic USE_V2 :
--   false (defaut) : utilise clk_div_v1 + fsm_v1 (sequentiel, baseline)
--   true           : utilise clk_div_v2 + fsm_v2 (optimise, SPI paralleles,
--                    clock_pmod = 20 MHz via DDR divise-par-5)
--
-- Connexions PMOD (Nexys A7) :
--   PMOD JA (ADC) : JA1=MISO, JA2=CS_N, JA3=SCLK
--   PMOD JB (DAC) : JB1=MOSI, JB2=CS_N, JB3=SCLK
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fir_top is
    generic (
        USE_V2 : boolean := false   -- false = v1 (sequentiel), true = v2 (parallele)
    );
    port (
        filter_in   : in  std_logic;
        clk         : in  std_logic;
        reset       : in  std_logic;
        PMODAD1_CS  : out std_logic;
        PMODAD1_CLK : out std_logic;
        PMODDA1_CS  : out std_logic;
        PMODDA1_CLK : out std_logic;
        filter_out  : out std_logic
    );
end fir_top;

architecture Behavioral of fir_top is

    -- Signaux d'horloge internes
    signal clock_pmod_sg : std_logic;
    signal clock_conv_sg : std_logic;
    signal clock_ramp_unused : std_logic;

    -- Signaux de handshake FSM <-> PmodAD / PmodDA
    signal adc_start_sg : std_logic;
    signal adc_busy_sg  : std_logic;
    signal dac_start_sg : std_logic;
    signal dac_busy_sg  : std_logic;

    -- Signaux de controle FSM -> datapath FIR
    signal rom_address_sg              : std_logic_vector(4 downto 0);
    signal delay_line_address_sg       : std_logic_vector(4 downto 0);
    signal delay_line_sample_shift_sg  : std_logic;
    signal accu_ctrl_sg                : std_logic;
    signal buff_oe_sg                  : std_logic;

    -- Donnees echantillons
    signal delay_line_in_sg : std_logic_vector(7 downto 0);
    signal buff_out_sg      : std_logic_vector(7 downto 0);

    -- Declarations de composants -------------------------------------------
    component clk_div_v1
        Port (
            reset      : in  STD_LOGIC;
            clock      : in  STD_LOGIC;
            clock_ramp : out STD_LOGIC;
            clock_pmod : out STD_LOGIC;
            clock_conv : out STD_LOGIC
        );
    end component;

    component clk_div_v2
        port (
            reset      : in  std_logic;
            clock      : in  std_logic;
            clock_pmod : out std_logic;
            clock_conv : out std_logic
        );
    end component;

    component fsm_v1
        Port (
            reset                   : in  STD_LOGIC;
            clock                   : in  STD_LOGIC;
            clock_conv              : in  STD_LOGIC;
            adc_start               : out STD_LOGIC;
            adc_busy                : in  STD_LOGIC;
            dac_start               : out STD_LOGIC;
            buff_oe                 : out STD_LOGIC;
            accu_ctrl               : out STD_LOGIC;
            delay_line_sample_shift : out STD_LOGIC;
            rom_address             : out STD_LOGIC_VECTOR(4 downto 0);
            DL_SS_address           : out STD_LOGIC_VECTOR(4 downto 0);
            dac_busy                : in  STD_LOGIC
        );
    end component;

    component fsm_v2
        Port (
            reset                   : in  STD_LOGIC;
            clock                   : in  STD_LOGIC;
            clock_conv              : in  STD_LOGIC;
            adc_start               : out STD_LOGIC;
            adc_busy                : in  STD_LOGIC;
            dac_start               : out STD_LOGIC;
            buff_oe                 : out STD_LOGIC;
            accu_ctrl               : out STD_LOGIC;
            delay_line_sample_shift : out STD_LOGIC;
            rom_address             : out STD_LOGIC_VECTOR(4 downto 0);
            DL_SS_address           : out STD_LOGIC_VECTOR(4 downto 0);
            dac_busy                : in  STD_LOGIC
        );
    end component;

    component PmodAD is
        Port (
            reset     : in  STD_LOGIC;
            clock     : in  STD_LOGIC;
            adc_start : in  STD_LOGIC;
            adc_busy  : out STD_LOGIC;
            adc_ch0   : out STD_LOGIC_VECTOR(7 downto 0);
            ext_cs    : out STD_LOGIC;
            ext_clk   : out STD_LOGIC;
            ext_d0    : in  STD_LOGIC
        );
    end component;

    component PmodDA is
        Port (
            reset     : in  STD_LOGIC;
            clock     : in  STD_LOGIC;
            dac_start : in  STD_LOGIC;
            dac_busy  : out STD_LOGIC;
            dac_ch0   : in  STD_LOGIC_VECTOR(7 downto 0);
            ext_sync  : out STD_LOGIC;
            ext_sclk  : out STD_LOGIC;
            ext_d0    : out STD_LOGIC
        );
    end component;

    component FIR_base is
        Port (
            FIR_in                  : in  STD_LOGIC_VECTOR(7 downto 0);
            clock                   : in  STD_LOGIC;
            delay_line_address      : in  STD_LOGIC_VECTOR(4 downto 0);
            rom_address             : in  STD_LOGIC_VECTOR(4 downto 0);
            delay_line_sample_shift : in  STD_LOGIC;
            accu_ctrl               : in  STD_LOGIC;
            buff_oe                 : in  STD_LOGIC;
            reset                   : in  STD_LOGIC;
            FIR_out                 : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

begin

    -- Diviseur d'horloge (v1 ou v2) ------------------------------------------
    gen_v1 : if not USE_V2 generate
        CD : clk_div_v1
            port map (
                reset      => reset,
                clock      => clk,
                clock_ramp => clock_ramp_unused,
                clock_pmod => clock_pmod_sg,
                clock_conv => clock_conv_sg
            );
    end generate;

    gen_v2 : if USE_V2 generate
        CD : clk_div_v2
            port map (
                reset      => reset,
                clock      => clk,
                clock_pmod => clock_pmod_sg,
                clock_conv => clock_conv_sg
            );
    end generate;

    -- FSM (v1 ou v2) ---------------------------------------------------------
    gen_fsm_v1 : if not USE_V2 generate
        fsm_1 : fsm_v1
            port map (
                clock                   => clk,
                reset                   => reset,
                clock_conv              => clock_conv_sg,
                adc_start               => adc_start_sg,
                adc_busy                => adc_busy_sg,
                dac_start               => dac_start_sg,
                buff_oe                 => buff_oe_sg,
                accu_ctrl               => accu_ctrl_sg,
                delay_line_sample_shift => delay_line_sample_shift_sg,
                rom_address             => rom_address_sg,
                DL_SS_address           => delay_line_address_sg,
                dac_busy                => dac_busy_sg
            );
    end generate;

    gen_fsm_v2 : if USE_V2 generate
        fsm_1 : fsm_v2
            port map (
                clock                   => clk,
                reset                   => reset,
                clock_conv              => clock_conv_sg,
                adc_start               => adc_start_sg,
                adc_busy                => adc_busy_sg,
                dac_start               => dac_start_sg,
                buff_oe                 => buff_oe_sg,
                accu_ctrl               => accu_ctrl_sg,
                delay_line_sample_shift => delay_line_sample_shift_sg,
                rom_address             => rom_address_sg,
                DL_SS_address           => delay_line_address_sg,
                dac_busy                => dac_busy_sg
            );
    end generate;

    -- Controleur ADC ---------------------------------------------------------
    ADC_controller : PmodAD
        port map (
            reset     => reset,
            clock     => clock_pmod_sg,
            adc_start => adc_start_sg,
            adc_busy  => adc_busy_sg,
            adc_ch0   => delay_line_in_sg,
            ext_cs    => PMODAD1_CS,
            ext_clk   => PMODAD1_CLK,
            ext_d0    => filter_in
        );

    -- Controleur DAC ---------------------------------------------------------
    DAC_controller : PmodDA
        port map (
            reset     => reset,
            clock     => clock_pmod_sg,
            dac_start => dac_start_sg,
            dac_busy  => dac_busy_sg,
            dac_ch0   => buff_out_sg,
            ext_sync  => PMODDA1_CS,
            ext_sclk  => PMODDA1_CLK,
            ext_d0    => filter_out
        );

    -- Datapath FIR -----------------------------------------------------------
    FIR : FIR_base
        port map (
            FIR_in                  => delay_line_in_sg,
            clock                   => clk,
            reset                   => reset,
            delay_line_address      => delay_line_address_sg,
            rom_address             => rom_address_sg,
            delay_line_sample_shift => delay_line_sample_shift_sg,
            accu_ctrl               => accu_ctrl_sg,
            buff_oe                 => buff_oe_sg,
            FIR_out                 => buff_out_sg
        );

end Behavioral;

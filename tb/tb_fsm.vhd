--------------------------------------------------------------------------------
-- Testbench : tb_fsm  (pour fsm_v1)
-- Source    : testbench original ISE, adapte : component fsm -> fsm_v1.
-- Usage     : verification visuelle des transitions d'etats (GTKWave).
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_fsm IS
END tb_fsm;

ARCHITECTURE behavior OF tb_fsm IS

    COMPONENT fsm_v1
    PORT(
         reset                   : IN  std_logic;
         clock                   : IN  std_logic;
         clock_conv              : IN  std_logic;
         adc_start               : OUT std_logic;
         adc_busy                : IN  std_logic;
         dac_start               : OUT std_logic;
         buff_oe                 : OUT std_logic;
         accu_ctrl               : OUT std_logic;
         delay_line_sample_shift : OUT std_logic;
         rom_address             : OUT std_logic_vector(4 downto 0);
         DL_SS_address           : OUT std_logic_vector(4 downto 0);
         dac_busy                : IN  std_logic
        );
    END COMPONENT;

   signal reset                   : std_logic := '0';
   signal clock                   : std_logic := '0';
   signal clock_conv              : std_logic := '0';
   signal adc_busy                : std_logic := '0';
   signal dac_busy                : std_logic := '0';

   signal adc_start               : std_logic;
   signal dac_start               : std_logic;
   signal buff_oe                 : std_logic;
   signal accu_ctrl               : std_logic;
   signal delay_line_sample_shift : std_logic;
   signal rom_address             : std_logic_vector(4 downto 0);
   signal DL_SS_address           : std_logic_vector(4 downto 0);

   constant clock_period      : time := 10 ns;
   constant clock_conv_period : time := 320 ns;  -- 3.125 MHz (/32 de 100 MHz)

BEGIN

   uut: fsm_v1 PORT MAP (
         reset                   => reset,
         clock                   => clock,
         clock_conv              => clock_conv,
         adc_start               => adc_start,
         adc_busy                => adc_busy,
         dac_start               => dac_start,
         buff_oe                 => buff_oe,
         accu_ctrl               => accu_ctrl,
         delay_line_sample_shift => delay_line_sample_shift,
         rom_address             => rom_address,
         DL_SS_address           => DL_SS_address,
         dac_busy                => dac_busy
       );

   clock_process : process
   begin
      clock <= '0';
      wait for clock_period/2;
      clock <= '1';
      wait for clock_period/2;
   end process;

   clock_conv_process : process
   begin
      clock_conv <= '0';
      wait for clock_conv_period/2;
      clock_conv <= '1';
      wait for clock_conv_period/2;
   end process;

   stim_proc: process
   begin
      -- hold reset state for 100 ns.
      reset <= '1';
      wait for 100 ns;
      reset <= '0';
      wait for clock_period*10;

      -- Simuler une conversion ADC complete (16 cycles SPI x 80 ns = 1280 ns)
      wait until adc_start = '1';
      wait for 20 ns;
      adc_busy <= '1';
      wait for 1280 ns;
      adc_busy <= '0';

      -- Attendre fin du filtre et depart DAC
      wait until dac_start = '1';
      wait for 20 ns;
      dac_busy <= '1';
      wait for 1280 ns;
      dac_busy <= '0';

      wait for clock_period * 20;
      wait;
   end process;

END;

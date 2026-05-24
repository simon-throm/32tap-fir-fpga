----------------------------------------------------------------------------------
-- Module Name : fsm_v1 - Behavioral
-- Description : FSM de controle FIR version 1 (sequentielle).
--
-- Machine d'etats :
--   idle -> AD_conv_start -> AD_conv -> filter(x32) -> DA_conv_start -> DA_conv -> idle
--
-- ADC et DAC sont strictement serialises.
-- Voir fsm_v2 pour la version optimisee avec transferts SPI paralleles.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_v1 is
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
end fsm_v1;

architecture Behavioral of fsm_v1 is
    type state_t is (idle, AD_conv_start, AD_conv, filter, DA_conv_start, DA_conv);
    signal state : state_t := idle;
    signal k     : integer range 0 to 31;
begin

    process(clock, reset)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                state <= idle;
            else
                case (state) is

                    -- IDLE STATE
                    when idle =>
                        adc_start               <= '0';
                        accu_ctrl               <= '0';
                        delay_line_sample_shift <= '0';
                        buff_oe                 <= '0';
                        dac_start               <= '0';
                        k                       <= 0;
                        if clock_conv = '1' then
                            if adc_busy = '0' then
                                state     <= AD_conv_start;
                                adc_start <= '1';
                            end if;
                        end if;

                    -- AD CONV START STATE
                    when AD_conv_start =>
                        if adc_busy = '1' then
                            adc_start <= '0';
                            state     <= AD_conv;
                        end if;

                    when AD_conv =>
                        if adc_busy = '0' then
                            delay_line_sample_shift <= '1';
                            state                   <= filter;
                        end if;

                    -- FILTER STATE
                    when filter =>
                        delay_line_sample_shift <= '0';
                        accu_ctrl               <= '1';
                        if k = 31 then
                            buff_oe   <= '1';
                            accu_ctrl <= '0';
                            dac_start <= '1';
                            state     <= DA_conv_start;
                        else
                            k <= k + 1;
                        end if;

                    -- DA CONV START STATE
                    when DA_conv_start =>
                        buff_oe <= '0';
                        if dac_busy = '1' then
                            dac_start <= '0';
                            state     <= DA_conv;
                        end if;

                    -- DA CONV STATE
                    when DA_conv =>
                        if dac_busy = '0' then
                            state <= idle;
                        end if;

                end case;
            end if;
        end if;
    end process;

    rom_address   <= std_logic_vector(to_unsigned(k, 5));
    DL_SS_address <= std_logic_vector(to_unsigned(k, 5));

end Behavioral;

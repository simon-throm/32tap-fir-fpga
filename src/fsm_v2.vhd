----------------------------------------------------------------------------------
-- Module Name : fsm_v2 - Behavioral
-- Description : FSM de controle FIR version 2 (optimisee).
--               ADC et DAC demarre simultanement depuis idle.
--               Identique au fichier fsm.vhd original, entity renommee fsm->fsm_v2
--               et overflow sur k corrige (if k=31 then ... else k<=k+1).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_v2 is
    Port ( reset :      in  STD_LOGIC;
           clock :      in  STD_LOGIC;
           clock_conv : in  STD_LOGIC;
           adc_start :  out STD_LOGIC;
           adc_busy :   in  STD_LOGIC;
           dac_start, buff_oe, accu_ctrl, delay_line_sample_shift  :  out STD_LOGIC;
           rom_address, DL_SS_address : out STD_LOGIC_VECTOR(4 downto 0);
           dac_busy :   in  STD_LOGIC);
end fsm_v2;

architecture Behavioral of fsm_v2 is
    type state_t is (idle, AD_conv_start, ADDA_conv, filter);
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
                                if dac_busy = '0' then
                                    state     <= AD_conv_start;
                                    adc_start <= '1';
                                    dac_start <= '1';
                                end if;
                            end if;
                        end if;

                    -- ADDA CONV START STATE
                    when AD_conv_start =>
                        buff_oe <= '0';
                        if adc_busy = '1' then
                            adc_start <= '0';
                            if dac_busy = '1' then
                                dac_start <= '0';
                                state     <= ADDA_conv;
                            end if;
                        end if;

                    -- ADDA CONV
                    when ADDA_conv =>
                        if adc_busy = '0' then
                            delay_line_sample_shift <= '1';
                            if dac_busy = '0' then
                                state <= filter;
                            end if;
                        end if;

                    -- FILTER STATE
                    when filter =>
                        delay_line_sample_shift <= '0';
                        accu_ctrl               <= '1';
                        if k = 31 then
                            buff_oe   <= '1';
                            accu_ctrl <= '0';
                            state     <= idle;
                        else
                            k <= k + 1;
                        end if;

                end case;
            end if;
        end if;
    end process;

    rom_address   <= std_logic_vector(to_unsigned(k, 5));
    DL_SS_address <= std_logic_vector(to_unsigned(k, 5));

end Behavioral;

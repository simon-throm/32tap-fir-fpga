----------------------------------------------------------------------------------
-- Module Name : fsm_v2 - Behavioral
-- Description : FSM de controle FIR version 2 (optimisee).
--
-- Optimisation cle : ADC et DAC lanc?s simultanement.
--   Le DAC transmet le PRECEDENT resultat filtre pendant que
--   l'ADC recoit le PROCHAIN echantillon, eliminant un transfert
--   SPI complet du chemin critique.
--
-- Machine d'etats :
--   idle -> conv_start (ADC+DAC simultanes) -> conv -> filter(x32) -> DA_latch -> idle
--
-- Resultat mesure :
--   FSM v1 : bande passante ~3  kHz
--   FSM v2 : bande passante ~13 kHz (x4.5 moins d'attenuation)
--
-- Interface identique a fsm_v1 (remplacement direct dans fir_top).
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_v2 is
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
end fsm_v2;

architecture Behavioral of fsm_v2 is
    type state_t is (idle, conv_start, conv, filter, DA_latch);
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
                                -- Lancer ADC et DAC simultanement
                                state     <= conv_start;
                                adc_start <= '1';
                                dac_start <= '1';
                            end if;
                        end if;

                    -- CONV_START : attendre que les deux controleurs soient busy
                    when conv_start =>
                        buff_oe <= '0';
                        if adc_busy = '1' then
                            adc_start <= '0';
                            if dac_busy = '1' then
                                dac_start <= '0';
                                state     <= conv;
                            end if;
                        end if;

                    -- CONV : attendre la fin des deux transferts SPI
                    when conv =>
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
                            accu_ctrl <= '0';
                            state     <= DA_latch;
                        else
                            k <= k + 1;
                        end if;

                    -- DA_LATCH : capturer le resultat pour le prochain cycle DAC
                    when DA_latch =>
                        buff_oe <= '1';
                        state   <= idle;

                end case;
            end if;
        end if;
    end process;

    rom_address   <= std_logic_vector(to_unsigned(k, 5));
    DL_SS_address <= std_logic_vector(to_unsigned(k, 5));

end Behavioral;

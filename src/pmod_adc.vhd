----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:51:54 12/16/2016 
-- Design Name: 
-- Module Name:    PmodAD1 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: INPUT CLOCK MUST BE 40 MHZ MAX.
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PmodAD is
    Port ( reset :         in  STD_LOGIC;
           clock :         in  STD_LOGIC; -- max 40 MHz
           adc_start :     in  STD_LOGIC; -- active high
           adc_busy :      out STD_LOGIC; -- active high
           adc_ch0 :       out STD_LOGIC_VECTOR (7 downto 0);
           ext_cs :        out STD_LOGIC;
           ext_clk :       out STD_LOGIC;
           ext_d0 :        in  STD_LOGIC);
end PmodAD;

architecture Behavioral of PmodAD is

type state_t is (idle, conv);
signal state :              state_t := idle;
subtype bit_count_t is integer range 0 to 15;
signal bit_count :          bit_count_t;
signal d0_buf :             STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal d0_int :             STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
signal clk_state :          STD_LOGIC := '1';
begin
    
    process(clock, reset)
    begin
        if reset = '1' then
            state <= idle;
        elsif rising_edge(clock) then
            case (state) is
            when idle =>
                ext_cs   <= '1';
                ext_clk  <= '1';
                adc_busy <= '0';
                if adc_start = '1' then
                    clk_state <= '0'; -- reset spi clock (inverted)
                    ext_cs   <= '0';
                    bit_count <= 15;  -- reset 16 bit spi counter
                    adc_busy  <= '1';
                    state <= conv;    -- update state
                end if;
            when conv =>
                adc_busy <= '1';
                ext_clk  <= clk_state;
                if clk_state = '1' then -- hold spi miso bit on rising edge
                    if (bit_count < 13) and (bit_count > 4) then
                        d0_buf(bit_count - 5) <= ext_d0;
                    end if;
                    if bit_count = 0 then
                        d0_int <= d0_buf;
                        state <= idle;
                    else
                        bit_count <= bit_count - 1;
                    end if;
                end if;
                clk_state <= not(clk_state);
            end case;
        end if;
	end process;
	
	adc_ch0 <= d0_int;
	
end Behavioral;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:29:03 09/20/2011 
-- Design Name: 
-- Module Name:    delay_line - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity delay_line is
    Port ( Delay_line_in : in  STD_LOGIC_VECTOR (7 downto 0);
           Delay_line_address : in  STD_LOGIC_VECTOR (4 downto 0);
           Delay_line_sample_shift  : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           clk  : in  STD_LOGIC;
           delay_line_out : out  STD_LOGIC_VECTOR (7 downto 0));
end delay_line;

architecture Behavioral of delay_line is

type table is array (0 to 31) of std_logic_vector (7 downto 0);
signal shift_register : table;

begin

process (reset, clk)
begin
	if reset = '1' then
		FOR i in 0 to 31 loop
			shift_register(i) <= (others => '0');
		end LOOP;
	
	elsif rising_edge(clk) then
		if Delay_line_sample_shift = '1' then
			FOR i in 31 downto 1 loop
				shift_register(i) <= shift_register(i-1);
			end loop;
			
			shift_register(0) <= delay_line_in;
			
		end if;

	end if;		
end process; 

			delay_line_out <= shift_register(to_integer(unsigned(delay_line_address)));
end Behavioral;


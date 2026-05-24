----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:41:24 09/26/2011 
-- Design Name: 
-- Module Name:    buff - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity buff is
	port (	buff_in  : in std_logic_vector (7 downto 0);--(20 downto 0) si sortie 21 bits
		buff_oe  : in std_logic;
		clk      : in std_logic;
		reset    : in std_logic;
		buff_out : out std_logic_vector (7 downto 0));--(20 downto 0) si sortie 21 bits

end buff;

architecture Behavioral of buff is

begin
process(clk, reset) 
begin
if reset = '1' then
		buff_out <= (others => '0');
elsif rising_edge(clk) then
	if buff_oe = '1' then
		buff_out <= buff_in;
	end if;
	
end if;

end process;
end Behavioral;


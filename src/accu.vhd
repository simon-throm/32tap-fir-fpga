----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:32:17 09/26/2011 
-- Design Name: 
-- Module Name:    accu - Behavioral 
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

entity accu is
port (	accu_in	  : in std_logic_vector(15 downto 0);
		accu_ctrl : in std_logic;
		clk       : in std_logic;
		reset     : in std_logic;
		accu_out  : out std_logic_vector(20 downto 0));

end accu;


architecture Behavioral of accu is


signal accu_int: unsigned (20 downto 0) := (others=>'0');

begin



process(clk, reset)
begin

if reset = '1' then
		accu_int <= (others => '0');
 
elsif rising_edge(clk) then
	if accu_ctrl = '1' then
		accu_int <= accu_int + unsigned(accu_in);

	elsif accu_ctrl = '0' then
		accu_int <= (others => '0');
	end if;
end if;

end process;

accu_out <= STD_LOGIC_VECTOR(accu_int);

end Behavioral;


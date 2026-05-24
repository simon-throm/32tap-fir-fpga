----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:28:07 09/26/2011 
-- Design Name: 
-- Module Name:    mult - Behavioral 
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

entity mult is
port(	mult_in_a : in std_logic_vector(7 downto 0);
		mult_in_b : in std_logic_vector(7 downto 0);
		mult_out  : out std_logic_vector(15 downto 0));

end mult;

architecture Behavioral of mult is

begin

	mult_out <= std_logic_vector(unsigned(mult_in_a) * unsigned(mult_in_b));



end Behavioral;


----------------------------------------------------------------------------------
-- Module Name : rom - Behavioral
-- Description : ROM synchrone 32 coefficients FIR passe-bas (8 bits).
--               Latence : 1 cycle horloge (lecture synchrone).
-- Note        : wait until clk='1' remplac? par rising_edge(clk)
--               pour compatibilit? Vivado / GHDL.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity rom is
    port (
        clk         : in  std_logic;
        rom_address : in  std_logic_vector(4 downto 0);
        rom_out     : out std_logic_vector(7 downto 0)
    );
end rom;

architecture Behavioral of rom is
    signal rom_address_int : integer range 0 to 31;
begin
    rom_address_int <= to_integer(unsigned(rom_address));

    process(clk)
    begin
        if rising_edge(clk) then
            case rom_address_int is
                when  0 | 31 => rom_out <= X"0A";
                when  1 | 30 => rom_out <= X"12";
                when  2 | 29 => rom_out <= X"1C";
                when  3 | 28 => rom_out <= X"29";
                when  4 | 27 => rom_out <= X"38";
                when  5 | 26 => rom_out <= X"4A";
                when  6 | 25 => rom_out <= X"5E";
                when  7 | 24 => rom_out <= X"73";
                when  8 | 23 => rom_out <= X"89";
                when  9 | 22 => rom_out <= X"9F";
                when 10 | 21 => rom_out <= X"B4";
                when 11 | 20 => rom_out <= X"C7";
                when 12 | 19 => rom_out <= X"D8";
                when 13 | 18 => rom_out <= X"E5";
                when 14 | 17 => rom_out <= X"EE";
                when 15 | 16 => rom_out <= X"F3";
                when others  => rom_out <= X"00";
            end case;
        end if;
    end process;

end Behavioral;

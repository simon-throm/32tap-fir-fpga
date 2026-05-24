----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:22:31 01/04/2017 
-- Design Name: 
-- Module Name:    PmodDA1 - Behavioral 
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

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PmodDA is
    Port ( reset :      in  STD_LOGIC;
           clock :      in  STD_LOGIC;
           dac_start :  in  STD_LOGIC;
           dac_busy :   out STD_LOGIC;
           dac_ch0 :    in  STD_LOGIC_VECTOR (7 downto 0);
           ext_sync :   out STD_LOGIC;
           ext_sclk :   out STD_LOGIC;
           ext_d0 :     out STD_LOGIC);
end PmodDA;


architecture Behavioral of PmodDA is

type state_t is (idle, busy);
signal state :          state_t := idle;
subtype bit_count_t is integer range 0 to 15;
signal bit_count :      bit_count_t := 15;
signal clk_state :      STD_LOGIC := '0';
signal data :           STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
begin

    process (clock)
    begin
        if rising_edge(clock) then
            if reset = '1' then
                state <= idle;
            else
                case state is
                when idle =>
                    dac_busy <= '0';
                    ext_sync <= '1';
                    ext_sclk <= '1';
                    ext_d0   <= '1';
                    if dac_start = '1' then
                        data <= dac_ch0;      -- hold input data
                        bit_count <= 15;      -- reset spi bit counter
                        clk_state <= '0';     -- reset clk state
                        ext_sync <= '0';      -- enable spi cs
                        state <= busy;        -- change state
                    end if;
                when busy =>
                    dac_busy <= '1';
                    ext_sync <= '0';          -- hold cs spi enable
                    ext_sclk <= clk_state;    -- update spi clock
                    if bit_count < 8 then     -- update spi mosi
                        ext_d0 <= data(bit_count);
                    else
                        ext_d0 <= '0';        -- MSB 8 bits are set to 0
                    end if;
                    if clk_state = '1' then 
                        if bit_count = 0 then
                          state <= idle;
                        else
                          bit_count <= bit_count - 1;
                        end if;
                    end if;
                    clk_state <= not(clk_state);
                end case;
            end if;
        end if;
    end process;

end Behavioral;


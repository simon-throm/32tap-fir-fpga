----------------------------------------------------------------------------------
-- Module Name : clk_div_v1 - Behavioral
-- Description : Diviseur d'horloge version 1 (baseline).
--
--   clock_ramp : clk / 2  =  50    MHz  (usage debug / ramp)
--   clock_pmod : clk / 4  =  25    MHz  -> SCLK SPI = 12.5 MHz
--   clock_conv : clk / 32 =  3.125 MHz  -> cadence de conversion
--
-- Utiliser avec fsm_v1. Voir clk_div_v2 pour la version optimis?e 20 MHz DDR.
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity clk_div_v1 is
    Port (
        reset      : in  STD_LOGIC;
        clock      : in  STD_LOGIC;
        clock_ramp : out STD_LOGIC;   -- 50    MHz
        clock_pmod : out STD_LOGIC;   -- 25    MHz (vers PmodAD / PmodDA)
        clock_conv : out STD_LOGIC    -- 3.125 MHz (cadence conversion)
    );
end clk_div_v1;

architecture Behavioral of clk_div_v1 is
    signal clkdiv : unsigned(7 downto 0) := (others => '0');
begin

    process(reset, clock)
    begin
        if reset = '1' then
            clkdiv <= (others => '0');
        elsif rising_edge(clock) then
            clkdiv <= clkdiv + 1;
        end if;
    end process;

    clock_ramp <= clkdiv(0);   -- /2  = 50    MHz
    clock_pmod <= clkdiv(1);   -- /4  = 25    MHz
    clock_conv <= clkdiv(4);   -- /32 = 3.125 MHz

end Behavioral;

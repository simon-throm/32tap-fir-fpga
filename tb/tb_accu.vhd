--------------------------------------------------------------------------------
-- Testbench : tb_accu  (self-checking)
-- Covers    : accumulate, synchronous clear, async reset, overflow guard.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_accu is
end tb_accu;

architecture behavior of tb_accu is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '1';
    signal accu_ctrl : std_logic := '0';
    signal accu_in   : std_logic_vector(15 downto 0) := (others => '0');
    signal accu_out  : std_logic_vector(20 downto 0);

    constant CLK_PERIOD : time := 10 ns;

    procedure check(actual : std_logic_vector(20 downto 0);
                    expected : integer; msg : string) is
    begin
        assert to_integer(unsigned(actual)) = expected
            report "FAIL [" & msg & "] got=" &
                   integer'image(to_integer(unsigned(actual))) &
                   " exp=" & integer'image(expected)
            severity error;
    end procedure;

begin

    clk <= not clk after CLK_PERIOD / 2;

    uut : entity work.accu
        port map (accu_in, accu_ctrl, clk, reset, accu_out);

    process
    begin
        wait for 3 * CLK_PERIOD; reset <= '0';
        wait until rising_edge(clk);

        -- 1. Accumulate 4 x 1000
        accu_ctrl <= '0'; accu_in <= std_logic_vector(to_unsigned(1000, 16));
        wait until rising_edge(clk);
        accu_ctrl <= '1';
        wait for 4 * CLK_PERIOD;
        wait for 1 ns;  -- let last rising-edge update settle
        check(accu_out, 4000, "4 x 1000");

        -- 2. Synchronous clear
        accu_ctrl <= '0';
        wait until rising_edge(clk);
        wait for 1 ns;
        check(accu_out, 0, "sync clear");

        -- 3. Async reset mid-accumulation
        accu_ctrl <= '1'; accu_in <= std_logic_vector(to_unsigned(50, 16));
        wait for 3 * CLK_PERIOD;
        reset <= '1'; wait for CLK_PERIOD;
        check(accu_out, 0, "async reset");
        reset <= '0';

        -- 4. No overflow: 32 x 65025 = 2,080,800 < 2^21 = 2,097,152
        accu_ctrl <= '0'; wait until rising_edge(clk);
        accu_ctrl <= '1';
        accu_in   <= std_logic_vector(to_unsigned(65025, 16));
        wait for 32 * CLK_PERIOD;
        wait for 1 ns;
        check(accu_out, 65025 * 32, "no overflow 32 x 65025");

        report "tb_accu: all tests passed" severity note;
        wait;
    end process;

end behavior;

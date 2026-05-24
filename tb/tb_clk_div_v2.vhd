--------------------------------------------------------------------------------
-- Testbench : tb_clk_div_v2  (self-checking)
-- Covers    : verifies that clock_pmod has exactly 20 MHz frequency and
--             50% duty cycle using the DDR divide-by-5 circuit.
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_clk_div_v2 is
end tb_clk_div_v2;

architecture behavior of tb_clk_div_v2 is

    signal clk        : std_logic := '0';
    signal reset      : std_logic := '1';
    signal clock_pmod : std_logic;
    signal clock_conv : std_logic;

    constant CLK_PERIOD   : time := 10 ns;  -- 100 MHz
    constant PMOD_PERIOD  : time := 50 ns;  -- expected 20 MHz

    -- Measure rising-to-rising period and rising-to-falling (duty cycle)
    signal t_rise1  : time := 0 ns;
    signal t_rise2  : time := 0 ns;
    signal t_fall1  : time := 0 ns;
    signal measured : boolean := false;

begin

    clk <= not clk after CLK_PERIOD / 2;

    uut : entity work.clk_div_v2
        port map (reset => reset, clock => clk,
                  clock_pmod => clock_pmod, clock_conv => clock_conv);

    -- Measurement process
    measure : process
    begin
        reset <= '1'; wait for 30 ns; reset <= '0';

        -- Wait for first rising edge
        wait until rising_edge(clock_pmod);
        t_rise1 <= now;

        -- Wait for falling edge
        wait until falling_edge(clock_pmod);
        t_fall1 <= now;

        -- Wait for second rising edge
        wait until rising_edge(clock_pmod);
        t_rise2 <= now;

        measured <= true;
        wait for 10 ns;  -- let signals settle in delta

        -- Check period
        assert (t_rise2 - t_rise1) = PMOD_PERIOD
            report "FAIL: clock_pmod period = " &
                   time'image(t_rise2 - t_rise1) &
                   " expected " & time'image(PMOD_PERIOD)
            severity error;

        -- Check 50% duty cycle (HIGH = 25 ns)
        assert (t_fall1 - t_rise1) = 25 ns
            report "FAIL: clock_pmod HIGH duration = " &
                   time'image(t_fall1 - t_rise1) &
                   " expected 25 ns (50% duty cycle)"
            severity error;

        report "tb_clk_div_v2: clock_pmod period=" &
               time'image(t_rise2 - t_rise1) &
               " high=" & time'image(t_fall1 - t_rise1) &
               " -> 20 MHz 50% duty cycle OK"
        severity note;

        wait;
    end process;

end behavior;

--------------------------------------------------------------------------------
-- Testbench : tb_delay_line
-- Source    : testbench original ISE, inchange.
-- Usage     : verification visuelle (formes d'onde GTKWave).
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tb_delay_line IS
END tb_delay_line;

ARCHITECTURE behavior OF tb_delay_line IS

    COMPONENT delay_line
    PORT(
         Delay_line_in          : IN  std_logic_vector(7 downto 0);
         Delay_line_address     : IN  std_logic_vector(4 downto 0);
         Delay_line_sample_shift: IN  std_logic;
         reset                  : IN  std_logic;
         clk                    : IN  std_logic;
         delay_line_out         : OUT std_logic_vector(7 downto 0)
        );
    END COMPONENT;

   signal Delay_line_in           : std_logic_vector(7 downto 0) := (others => '0');
   signal Delay_line_address      : std_logic_vector(4 downto 0) := (others => '0');
   signal Delay_line_sample_shift : std_logic := '0';
   signal reset                   : std_logic := '0';
   signal clk                     : std_logic := '0';
   signal delay_line_out          : std_logic_vector(7 downto 0);

   constant clk_period : time := 10 ns;

BEGIN

   uut: delay_line PORT MAP (
         Delay_line_in           => Delay_line_in,
         Delay_line_address      => Delay_line_address,
         Delay_line_sample_shift => Delay_line_sample_shift,
         reset                   => reset,
         clk                     => clk,
         delay_line_out          => delay_line_out
       );

   clk_process : process
   begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
   end process;

   stim_proc: process
   begin
      reset <= '1';
      wait for 100 ns;
      reset <= '0';
      wait for clk_period*10;

      -- insert stimulus here
      Delay_line_in <= "00001000";
      Delay_line_sample_shift <= '1' after 250 ns;
      Delay_line_sample_shift <= '0' after 295 ns;
      Delay_line_in <= "00010000" after 300 ns;
      Delay_line_sample_shift <= '1' after 350 ns;
      Delay_line_address <= "00100"; -- after 360 ns;

      wait;
   end process;

END;

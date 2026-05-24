----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:18:15 11/12/2019 
-- Design Name: 
-- Module Name:    sous_FIR - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FIR_base is
    Port ( FIR_in : in  STD_LOGIC_VECTOR (7 downto 0);
           clock: in  STD_LOGIC;
			  delay_line_address, rom_address: in STD_LOGIC_VECTOR (4 downto 0);
			  delay_line_sample_shift, accu_ctrl, buff_oe : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           FIR_out : out  STD_LOGIC_VECTOR (7 downto 0));
end FIR_base;

architecture Behavioral of FIR_base is

component delay_line 
		port(	Delay_line_in		: in std_logic_vector(7 downto 0);
			Delay_line_address  	: in std_logic_vector(4 downto 0);
			Delay_line_sample_shift : in std_logic;
			reset 			: in std_logic;
			clk 			: in std_logic;
			delay_line_out 		: out std_logic_vector(7 downto 0));
	end component;

	component rom
		port (	clk 	    : in std_logic;
			rom_address : in std_logic_vector(4 downto 0);
			rom_out     : out std_logic_vector(7 downto 0));
	end component;

	component mult
		port(	mult_in_a : in std_logic_vector(7 downto 0);
			mult_in_b : in std_logic_vector(7 downto 0);
			mult_out  : out std_logic_vector(15 downto 0));
	end component;

	component accu
		port (	accu_in	  : in std_logic_vector(15 downto 0);
			accu_ctrl : in std_logic;
			clk 	  : in std_logic;
			reset 	  : in std_logic;
			accu_out  : out std_logic_vector(20 downto 0));
	end component;

	component buff
		port (	buff_in  : in std_logic_vector (7 downto 0);--(20 downto 0) si sortie 21 bits
			buff_oe  : in std_logic;
			clk 	 : in std_logic;
			reset 	 : in std_logic;
			buff_out : out std_logic_vector (7 downto 0));--(20 downto 0) si sortie 21 bits
	end component;

--	component fsm
--	Port ( reset :      in  STD_LOGIC;
--           clock :      in  STD_LOGIC;
--           clock_conv : in  STD_LOGIC;
--           adc_start :  out STD_LOGIC;
--           adc_busy :   in  STD_LOGIC;
--           dac_start, buff_oe, accu_ctrl, delay_line_sample_shift  :  out STD_LOGIC;
--			  rom_address, DL_SS_address : out STD_LOGIC_VECTOR(4 downto 0);
--           dac_busy :   in  STD_LOGIC);
--	end component;


	--signal rom_address_sg : std_logic_vector (4 downto 0);
	--signal delay_line_address_sg : std_logic_vector (4 downto 0);
	--signal delay_line_sample_shift_sg : std_logic;
	--signal accu_ctrl_sg, clock_pmod_sg : std_logic;
	--signal buff_oe_sg: std_logic;
	signal delay_line_out_sg : std_logic_vector(7 downto 0);
	signal rom_out_sg : std_logic_vector(7 downto 0);
	signal mult_out_sg : std_logic_vector(15 downto 0);
	signal accu_out_sg : std_logic_vector(20 downto 0);
	signal buff_out_sg : std_logic_vector(7 downto 0);
	
	
begin
	delay_line_1 : delay_line 
		port map ( Delay_line_in => FIR_in, 
				Delay_line_address => delay_line_address, 
				Delay_line_sample_shift => delay_line_sample_shift, 
				reset => reset, 
				clk => clock, 
				delay_line_out => delay_line_out_sg);
				
	rom_1 	     : rom 
		port map (clk => clock, 
				rom_address => rom_address, 
				rom_out => rom_out_sg);
				
	mult_1 	     : mult 
		port map (mult_in_b=> rom_out_sg, 
				mult_in_a => delay_line_out_sg, 
				mult_out => mult_out_sg);
				
	accu_1 	     : accu 
		port map (accu_in => mult_out_sg, 
				accu_ctrl => accu_ctrl, 
				clk => clock, 
				reset => reset, 
				accu_out => accu_out_sg);
				
	buff_1 	     : buff 
		port map (buff_in => accu_out_sg(19 downto 12), 
				buff_out => FIR_out, 
				clk => clock, 
				reset => reset, 
				buff_oe => buff_oe);--(20 downto 0) si sortie 21 bits
				

end Behavioral;


--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	psec4_SELFtrigger
-- author		: 	ejo
-- date			: 	4/2014
-- description	:  psec4 trigger generation
--------------------------------------------------
	
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.Definition_Pool.all;

entity psec4_SELFtrigger is
	port(
			xCLR_ALL					: in	std_logic;   --wakeup reset (clears high)
			xDONE						: in	std_logic;	-- USB done signal	
			xTRIG_CLK				: in  std_logic;
			xRESET_FROM_FIRM		: in	std_logic;
			xSELF_TRIGGER			: in	std_logic_vector(29 downto 0);
			
			xSELF_TRIG_CLEAR		: in	std_logic;
			xSELF_TRIG_ENABLE		: in	std_logic;
			xSELF_TRIG_MASK		: in	std_logic_vector(29 downto 0);

			xSELF_TRIG_LATCHEDOR1: out std_logic;
			xSELF_TRIG_LATCHEDOR2: out std_logic;
			xSELF_TRIG_LATCHEDOR3: out std_logic;
			
			xSELF_TRIG_LATCHED	: out std_logic_vector(29 downto 0));
	end psec4_SELFtrigger;

architecture Behavioral	of psec4_SELFtrigger is
	signal SELF_TRIG_LATCHED 		: std_logic_vector(29 downto 0);
	
begin

xSELF_TRIG_LATCHEDOR1 <= 	SELF_TRIG_LATCHED(0) or SELF_TRIG_LATCHED(1) or
									SELF_TRIG_LATCHED(2) or SELF_TRIG_LATCHED(3) or
									SELF_TRIG_LATCHED(4) or SELF_TRIG_LATCHED(5) or
									SELF_TRIG_LATCHED(6) or SELF_TRIG_LATCHED(7) or
									SELF_TRIG_LATCHED(8) or SELF_TRIG_LATCHED(9);
xSELF_TRIG_LATCHEDOR2 <= 	SELF_TRIG_LATCHED(10) or SELF_TRIG_LATCHED(11) or
									SELF_TRIG_LATCHED(12) or SELF_TRIG_LATCHED(13) or
									SELF_TRIG_LATCHED(14) or SELF_TRIG_LATCHED(15) or
									SELF_TRIG_LATCHED(16) or SELF_TRIG_LATCHED(17) or
									SELF_TRIG_LATCHED(18) or SELF_TRIG_LATCHED(19);
xSELF_TRIG_LATCHEDOR3 <= 	SELF_TRIG_LATCHED(20) or SELF_TRIG_LATCHED(21) or
									SELF_TRIG_LATCHED(22) or SELF_TRIG_LATCHED(23) or
									SELF_TRIG_LATCHED(24) or SELF_TRIG_LATCHED(25) or
									SELF_TRIG_LATCHED(26) or SELF_TRIG_LATCHED(27) or
									SELF_TRIG_LATCHED(28) or SELF_TRIG_LATCHED(29);
									
latch_self_trigger: for i in 0 to 29 generate
	process(	xCLR_ALL, xTRIG_CLK, xSELF_TRIG_ENABLE, xSELF_TRIG_CLEAR, xDONE, xRESET_FROM_FIRM,
			xSELF_TRIGGER(i), xSELF_TRIG_MASK(i))
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' or 
			xDONE = '1' or xRESET_FROM_FIRM = '1' then
				SELF_TRIG_LATCHED(i)  <= '0';
				xSELF_TRIG_LATCHED(i) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(i)) and xSELF_TRIG_MASK(i) = '1' then
		--elsif rising_edge(xTRIG_CLK) and xSELF_TRIGGER(i) = '1' and xSELF_TRIG_MASK(i) = '1' then
				SELF_TRIG_LATCHED(i)  <= '1';
				xSELF_TRIG_LATCHED(i) <= '1';
		end if;
	end process;
end generate latch_self_trigger;

end Behavioral;

			
			
			
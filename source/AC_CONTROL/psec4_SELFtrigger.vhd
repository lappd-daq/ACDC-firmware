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
			xTRIG_CLK				: in 	std_logic;   --fast clk (320MHz) to trigger all chans once internally triggered
			xMCLK						: in	std_logic;   --ext trig sync with write clk
			xCLR_ALL					: in	std_logic;   --wakeup reset (clears high)
			xDONE						: in	std_logic;	-- USB done signal		
			xSLOW_CLK				: in	std_logic;
			
			xSELF_TRIGGER			: in	std_logic_vector(29 downto 0);
			
			xSELF_TRIG_CLEAR		: in	std_logic;
			xSELF_TRIG_ENABLE		: in	std_logic;
			xSELF_TRIG_MASK		: in	std_logic_vector(29 downto 0);
			
			xSELF_TRIG_OR			: out std_logic;
			xSELF_TRIG_LATCHED_OR: out std_logic;
			xSELF_TRIG_BITSUM		: out std_logic_vector(2 downto 0);
			xSELF_TRIG_LATCHED	: out std_logic_vector(29 downto 0));
	end psec4_SELFtrigger;

architecture Behavioral	of psec4_SELFtrigger is
	signal SELF_TRIG_LATCHED 		: std_logic_vector(29 downto 0);
	signal SELF_TRIG_CLOCKED		: std_logic_vector(29 downto 0); 
	signal SELF_TRIG_LATCHED_OR 	: std_logic;
	signal SELF_TRIG_OR				: std_logic;
	signal SELF_TRIG_BITSUM_RUN	: std_logic_vector(2 downto 0);
	signal TRIG_CLK					: std_logic;
	
begin
	TRIG_CLK  					<= xTRIG_CLK;
	xSELF_TRIG_OR				<= SELF_TRIG_OR;
	xSELF_TRIG_LATCHED 		<= SELF_TRIG_LATCHED;
	xSELF_TRIG_LATCHED_OR 	<= SELF_TRIG_LATCHED_OR;	
	xSELF_TRIG_BITSUM			<= SELF_TRIG_BITSUM_RUN;
	SELF_TRIG_LATCHED_OR 	<= (SELF_TRIG_LATCHED(0) or SELF_TRIG_LATCHED(1) or
										SELF_TRIG_LATCHED(2) or SELF_TRIG_LATCHED(3) or
										SELF_TRIG_LATCHED(4) or SELF_TRIG_LATCHED(5) or
										SELF_TRIG_LATCHED(6) or SELF_TRIG_LATCHED(7) or
										SELF_TRIG_LATCHED(8) or SELF_TRIG_LATCHED(9) or
										SELF_TRIG_LATCHED(10) or SELF_TRIG_LATCHED(11) or
										SELF_TRIG_LATCHED(12) or SELF_TRIG_LATCHED(13) or
										SELF_TRIG_LATCHED(14) or SELF_TRIG_LATCHED(15) or
										SELF_TRIG_LATCHED(16) or SELF_TRIG_LATCHED(17) or
										SELF_TRIG_LATCHED(18) or SELF_TRIG_LATCHED(19) or
										SELF_TRIG_LATCHED(20) or SELF_TRIG_LATCHED(21) or
										SELF_TRIG_LATCHED(22) or SELF_TRIG_LATCHED(23) or
										SELF_TRIG_LATCHED(24) or SELF_TRIG_LATCHED(25) or
										SELF_TRIG_LATCHED(26) or SELF_TRIG_LATCHED(27) or
										SELF_TRIG_LATCHED(28) or SELF_TRIG_LATCHED(29));	
		
			
----------------------------------------------------------
--process to check number of trigger bits fired, so it can be matched to a coincidence target
	count_trigbits:process(	TRIG_CLK, xCLR_ALL, xDONE, xSELF_TRIG_CLEAR, 
									xSELF_TRIG_ENABLE, SELF_TRIG_LATCHED)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1'  or xDONE = '1' then
			SELF_TRIG_BITSUM_RUN <= (others => '0');	
			SELF_TRIG_CLOCKED <= (others => '0');
			SELF_TRIG_OR <= '0';
		elsif rising_edge(TRIG_CLK) then
			SELF_TRIG_OR 	<= (SELF_TRIG_LATCHED(0) or SELF_TRIG_LATCHED(1) or
										SELF_TRIG_LATCHED(2) or SELF_TRIG_LATCHED(3) or
										SELF_TRIG_LATCHED(4) or SELF_TRIG_LATCHED(5) or
										SELF_TRIG_LATCHED(6) or SELF_TRIG_LATCHED(7) or
										SELF_TRIG_LATCHED(8) or SELF_TRIG_LATCHED(9) or
										SELF_TRIG_LATCHED(10) or SELF_TRIG_LATCHED(11) or
										SELF_TRIG_LATCHED(12) or SELF_TRIG_LATCHED(13) or
										SELF_TRIG_LATCHED(14) or SELF_TRIG_LATCHED(15) or
										SELF_TRIG_LATCHED(16) or SELF_TRIG_LATCHED(17) or
										SELF_TRIG_LATCHED(18) or SELF_TRIG_LATCHED(19) or
										SELF_TRIG_LATCHED(20) or SELF_TRIG_LATCHED(21) or
										SELF_TRIG_LATCHED(22) or SELF_TRIG_LATCHED(23) or
										SELF_TRIG_LATCHED(24) or SELF_TRIG_LATCHED(25) or
										SELF_TRIG_LATCHED(26) or SELF_TRIG_LATCHED(27) or
										SELF_TRIG_LATCHED(28) or SELF_TRIG_LATCHED(29));
--			SELF_TRIG_BITSUM_RUN <= ("00"&SELF_TRIG_CLOCKED(0))  + ("00"&SELF_TRIG_CLOCKED(1))  +
--											("00"&SELF_TRIG_CLOCKED(2))  + ("00"&SELF_TRIG_CLOCKED(3))  +
--											("00"&SELF_TRIG_CLOCKED(4))  + ("00"&SELF_TRIG_CLOCKED(5))  +
--											("00"&SELF_TRIG_CLOCKED(6))  + ("00"&SELF_TRIG_CLOCKED(7))  +
--											("00"&SELF_TRIG_CLOCKED(8))  + ("00"&SELF_TRIG_CLOCKED(9))  +
--											("00"&SELF_TRIG_CLOCKED(10)) + ("00"&SELF_TRIG_CLOCKED(11)) +
--											("00"&SELF_TRIG_CLOCKED(12)) + ("00"&SELF_TRIG_CLOCKED(13)) +
--											("00"&SELF_TRIG_CLOCKED(14)) + ("00"&SELF_TRIG_CLOCKED(15)) +
--											("00"&SELF_TRIG_CLOCKED(16)) + ("00"&SELF_TRIG_CLOCKED(17)) +
--											("00"&SELF_TRIG_CLOCKED(18)) + ("00"&SELF_TRIG_CLOCKED(19)) +
--											("00"&SELF_TRIG_CLOCKED(20)) + ("00"&SELF_TRIG_CLOCKED(21)) +
--											("00"&SELF_TRIG_CLOCKED(22)) + ("00"&SELF_TRIG_CLOCKED(23)) +
--											("00"&SELF_TRIG_CLOCKED(24)) + ("00"&SELF_TRIG_CLOCKED(25)) +
--											("00"&SELF_TRIG_CLOCKED(26)) + ("00"&SELF_TRIG_CLOCKED(27)) +
--											("00"&SELF_TRIG_CLOCKED(28)) + ("00"&SELF_TRIG_CLOCKED(29));
--											("0000"&SELF_TRIG_CLOCKED(0))  + ("0000"&SELF_TRIG_CLOCKED(1))  +
--											("0000"&SELF_TRIG_CLOCKED(2))  + ("0000"&SELF_TRIG_CLOCKED(3))  +
--											("0000"&SELF_TRIG_CLOCKED(4))  + ("0000"&SELF_TRIG_CLOCKED(5))  +
--											("0000"&SELF_TRIG_CLOCKED(6))  + ("0000"&SELF_TRIG_CLOCKED(7))  +
--											("0000"&SELF_TRIG_CLOCKED(8))  + ("0000"&SELF_TRIG_CLOCKED(9))  +
--											("0000"&SELF_TRIG_CLOCKED(10)) + ("0000"&SELF_TRIG_CLOCKED(11)) +
--											("0000"&SELF_TRIG_CLOCKED(12)) + ("0000"&SELF_TRIG_CLOCKED(13)) +
--											("0000"&SELF_TRIG_CLOCKED(14)) + ("0000"&SELF_TRIG_CLOCKED(15)) +
--											("0000"&SELF_TRIG_CLOCKED(16)) + ("0000"&SELF_TRIG_CLOCKED(17)) +
--											("0000"&SELF_TRIG_CLOCKED(18)) + ("0000"&SELF_TRIG_CLOCKED(19)) +
--											("0000"&SELF_TRIG_CLOCKED(20)) + ("0000"&SELF_TRIG_CLOCKED(21)) +
--											("0000"&SELF_TRIG_CLOCKED(22)) + ("0000"&SELF_TRIG_CLOCKED(23)) +
--											("0000"&SELF_TRIG_CLOCKED(24)) + ("0000"&SELF_TRIG_CLOCKED(25)) +
--											("0000"&SELF_TRIG_CLOCKED(26)) + ("0000"&SELF_TRIG_CLOCKED(27)) +
--											("0000"&SELF_TRIG_CLOCKED(28)) + ("0000"&SELF_TRIG_CLOCKED(29));
			elsif falling_edge(TRIG_CLK) then
				SELF_TRIG_CLOCKED <= SELF_TRIG_LATCHED;
		end if;
	end process;			
----------------------------------------------------------
--latch rising edge of self trigger bits w.r.t specified mask
----------------------------------------------------------
	--channel(0)
	selftrig_0:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(0) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(0)) and xSELF_TRIG_MASK(0) = '1' then
			SELF_TRIG_LATCHED(0) <= '1';
		end if;
	end process;
	--channel(1)
	selftrig_1:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(1) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(1)) and xSELF_TRIG_MASK(1) = '1' then
			SELF_TRIG_LATCHED(1) <= '1';
		end if;
	end process;
	--channel(2)
	selftrig_2:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then
			SELF_TRIG_LATCHED(2) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(2)) and xSELF_TRIG_MASK(2) = '1' then
			SELF_TRIG_LATCHED(2) <= '1';
		end if;
	end process;
	--channel(3)
	selftrig_3:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then 	
			SELF_TRIG_LATCHED(3) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(3)) and xSELF_TRIG_MASK(3) = '1' then
			SELF_TRIG_LATCHED(3) <= '1';
		end if;
	end process;
	--channel(4)
	selftrig_4:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(4) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(4)) and xSELF_TRIG_MASK(4) = '1' then
			SELF_TRIG_LATCHED(4) <= '1';
		end if;
	end process;
	--channel(5)
	selftrig_5:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(5) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(5)) and xSELF_TRIG_MASK(5) = '1' then
			SELF_TRIG_LATCHED(5) <= '1';
		end if;
	end process;
	--channel(6)
	selftrig_6:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(6) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(6)) and xSELF_TRIG_MASK(6) = '1' then
			SELF_TRIG_LATCHED(6) <= '1';
		end if;
	end process;
	--channel(7)
	selftrig_7:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(7) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(7)) and xSELF_TRIG_MASK(7) = '1' then
			SELF_TRIG_LATCHED(7) <= '1';
		end if;
	end process;
	--channel(8)
	selftrig_8:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(8) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(8)) and xSELF_TRIG_MASK(8) = '1' then
			SELF_TRIG_LATCHED(8) <= '1';
		end if;
	end process;
	--channel(9)
	selftrig_9:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(9) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(9)) and xSELF_TRIG_MASK(9) = '1' then
			SELF_TRIG_LATCHED(9) <= '1';
		end if;
	end process;
	--channel(10)
	selftrig_10:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(10) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(10)) and xSELF_TRIG_MASK(10) = '1' then
			SELF_TRIG_LATCHED(10) <= '1';
		end if;
	end process;
	--channel(11)
	selftrig_11:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(11) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(11)) and xSELF_TRIG_MASK(11) = '1' then
			SELF_TRIG_LATCHED(11) <= '1';
		end if;
	end process;
	--channel(12)
	selftrig_12:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(12) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(12)) and xSELF_TRIG_MASK(12) = '1' then
			SELF_TRIG_LATCHED(12) <= '1';
		end if;
	end process;
	--channel(13)
	selftrig_13:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(13) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(13)) and xSELF_TRIG_MASK(13) = '1' then
			SELF_TRIG_LATCHED(13) <= '1';
		end if;
	end process;
	--channel(14)
	selftrig_14:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(14) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(14)) and xSELF_TRIG_MASK(14) = '1' then
			SELF_TRIG_LATCHED(14) <= '1';
		end if;
	end process;
	--channel(15)
	selftrig_15:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(15) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(15)) and xSELF_TRIG_MASK(15) = '1' then
			SELF_TRIG_LATCHED(15) <= '1';
		end if;
	end process;
	--channel(16)
	selftrig_16:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(16) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(16)) and xSELF_TRIG_MASK(16) = '1' then
			SELF_TRIG_LATCHED(16) <= '1';
		end if;
	end process;
	--channel(17)
	selftrig_17:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(17) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(17)) and xSELF_TRIG_MASK(17) = '1' then
			SELF_TRIG_LATCHED(17) <= '1';
		end if;
	end process;
	--channel(18)
	selftrig_18:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(18) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(18)) and xSELF_TRIG_MASK(18) = '1' then
			SELF_TRIG_LATCHED(18) <= '1';
		end if;
	end process;
	--channel(19)
	selftrig_19:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(19) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(19)) and xSELF_TRIG_MASK(19) = '1' then
			SELF_TRIG_LATCHED(19) <= '1';
		end if;
	end process;
	--channel(20)
	selftrig_20:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(20) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(20)) and xSELF_TRIG_MASK(20) = '1' then
			SELF_TRIG_LATCHED(20) <= '1';
		end if;
	end process;	
	--channel(21)
	selftrig_21:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(21) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(21)) and xSELF_TRIG_MASK(21) = '1' then
			SELF_TRIG_LATCHED(21) <= '1';
		end if;
	end process;
	--channel(22)
	selftrig_22:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then
			SELF_TRIG_LATCHED(22) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(22)) and xSELF_TRIG_MASK(22) = '1' then
			SELF_TRIG_LATCHED(22) <= '1';
		end if;
	end process;
	--channel(23)
	selftrig_23:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then 	
			SELF_TRIG_LATCHED(23) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(23)) and xSELF_TRIG_MASK(23) = '1' then
			SELF_TRIG_LATCHED(23) <= '1';
		end if;
	end process;
	--channel(24)
	selftrig_24:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(24) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(24)) and xSELF_TRIG_MASK(24) = '1' then
			SELF_TRIG_LATCHED(24) <= '1';
		end if;
	end process;
	--channel(25)
	selftrig_25:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(25) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(25)) and xSELF_TRIG_MASK(25) = '1' then
			SELF_TRIG_LATCHED(25) <= '1';
		end if;
	end process;
	--channel(26)
	selftrig_26:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(26) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(26)) and xSELF_TRIG_MASK(26) = '1' then
			SELF_TRIG_LATCHED(26) <= '1';
		end if;
	end process;
	--channel(27)
	selftrig_27:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(27) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(27)) and xSELF_TRIG_MASK(27) = '1' then
			SELF_TRIG_LATCHED(27) <= '1';
		end if;
	end process;
	--channel(28)
	selftrig_28:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(28) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(28)) and xSELF_TRIG_MASK(28) = '1' then
			SELF_TRIG_LATCHED(28) <= '1';
		end if;
	end process;
	--channel(29)
	selftrig_29:process(xCLR_ALL, xSELF_TRIG_CLEAR, xSELF_TRIGGER, xSELF_TRIG_MASK, xSELF_TRIG_ENABLE)
	begin
		if xCLR_ALL = '1'  or xSELF_TRIG_ENABLE = '0' or xSELF_TRIG_CLEAR = '1' then	
			SELF_TRIG_LATCHED(29) <= '0';	
		elsif rising_edge(xSELF_TRIGGER(29)) and xSELF_TRIG_MASK(29) = '1' then
			SELF_TRIG_LATCHED(29) <= '1';
		end if;
	end process;	

end Behavioral;

			
			
			
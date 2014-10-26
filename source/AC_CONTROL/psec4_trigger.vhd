--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	psec4_trigger
-- author		: 	ejo
-- date			: 	6/2012
-- description	:  psec4 trigger generation
--------------------------------------------------
	
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Definition_Pool.all;

entity psec4_trigger is
	port(
			xTRIG_CLK		: in 	std_logic;   --fast clk (320MHz) to trigger all chans once internally triggered
			xMCLK				: in	std_logic;   --ext trig sync with write clk
			xCLR_ALL			: in	std_logic;   --wakeup reset (clears high)
			xDONE				: in	std_logic;	-- USB done signal		
			
			xCC_TRIG			: in	std_logic;   -- software trig
			xDC_TRIG			: in	std_logic;
			xSELFTRIG 		: in	std_logic_vector(5 downto 0); --internal trig sgnl
			
			xSET_SMPL_RATE				: in	std_logic;
			xSET_ENABLE_SELF_TRIG	: in	std_logic;
			xRESET_TRIG_FLAG			: in	std_logic;
			
			xDLL_RESET		: in	std_logic;
			xPLL_LOCK		: in	std_logic;
			xTRIG_FEEDIN	: in	std_logic;		
			xTRIG_FEEDOUT	: out	std_logic; 
			
			xTRIGGER_OUT	: out	std_logic;
			xLATCHED_SELF_TRIG: out	std_logic_vector(5 downto 0);
			xTRIG_CLEAR		: out	std_logic;
			
			xEVENT_CNT		: out std_logic_vector(EVT_CNT_SIZE-1 downto 0);
			xSAMPLE_BIN		: out	std_logic_vector(3 downto 0));
	end psec4_trigger;

architecture Behavioral of psec4_trigger is
-------------------------------------------------------------------------------
-- SIGNALS 
-------------------------------------------------------------------------------	
	type 	HANDLE_TRIG_TYPE	is (WAIT_FOR_TRIG, HOLD_TRIG, RESET_BOSS_TRIG);
	signal	HANDLE_TRIG_STATE	:	HANDLE_TRIG_TYPE;
	
	type 	RESET_TRIG_TYPE	is (RESETT, RELAXT);
	signal	RESET_TRIG_STATE:	RESET_TRIG_TYPE;
-------------------------------------------------------------------------------
	signal TRIG_ENABLE	:	std_logic := '0';
	signal EXT_TRIG_A		:	std_logic ;   -- software
	signal EXT_TRIG_B		:	std_logic := '0';	 -- hardware
	signal EXT_TRIG_C		: 	std_logic := '0';	 -- internal
	signal EXT_TRIG		:	std_logic;   -- A or B or C trigs
	signal TRIG_CHANNEL	: 	std_logic_vector(5 downto 0);
	signal CC_TRIG			:	std_logic;
	signal DC_TRIG			: 	std_logic  := '0';
	signal SELF_TRIG		:	std_logic;
	signal SELF_TRIG_OR	:	std_logic;
	signal TRIG_CLEAR		:	std_logic := '0';
	signal TRIG_FEEDOUT  : 	std_logic;
	
	signal RESET_TRIG_FROM_SOFTWARE	:	std_logic := '0';
	signal RESET_TRIG_COUNT				:	std_logic := '1';

	signal EVENT_CNT			:	std_logic_vector(EVT_CNT_SIZE-1 downto 0);	
	signal BIN_COUNT			:	std_logic_vector(3 downto 0) := "0000";
	signal MASK_FLAG			:	std_logic := '0';
	signal BIN_COUNT_START 	: 	std_logic := '0';
	signal BIN_COUNT_SAVE	:	std_logic_vector(3 downto 0);
	signal BIN_COUNT_LATCH	:	std_logic_vector(3 downto 0);
	signal BIN_COUNT_CHECK	:	std_logic_vector(3 downto 0);
--	signal BIN_COUNT_MASK	:	std_logic_vector(3 downto 0);
-------------------------------------------------------------------------------  
begin  -- Behavioral
-------------------------------------------------------------------------------	
	xEVENT_CNT 		<= EVENT_CNT;
	xSAMPLE_BIN		<= (BIN_COUNT_SAVE and (xSET_SMPL_RATE & "011"));
	EXT_TRIG			<= EXT_TRIG_A or EXT_TRIG_B or EXT_TRIG_C;
	TRIG_ENABLE    <= xSET_ENABLE_SELF_TRIG;
	SELF_TRIG_OR	<= xSELFTRIG(0) or xSELFTRIG(1) or
							xSELFTRIG(2) or xSELFTRIG(3) or
							xSELFTRIG(4) or xSELFTRIG(5);
							
	xTRIG_CLEAR    <= (not TRIG_ENABLE) or RESET_TRIG_FROM_SOFTWARE;
	xTRIGGER_OUT	<= EXT_TRIG;
	xLATCHED_SELF_TRIG <= TRIG_CHANNEL;
	xTRIG_FEEDOUT		<= TRIG_FEEDOUT;
	
--implement event counter
process(xCLR_ALL,EXT_TRIG) 
begin
	if xCLR_ALL = '1' then
		EVENT_CNT <= (others => '0');
	elsif rising_edge(EXT_TRIG) then
		EVENT_CNT <= EVENT_CNT + 1;
	end if;
end process;

--**-----------------------------
--\/-----------------------------
--trigger 'binning' firmware-----
process(xMCLK, xCLR_ALL, xPLL_LOCK)
begin	
	if xCLR_ALL = '1' or xPLL_LOCK = '0' then
		BIN_COUNT_START <= '0';
	elsif rising_edge(xMCLK) and xPLL_LOCK = '1' then
		BIN_COUNT_START <= '1';
	end if;
end process;
--fine 'binning' counter cycle
process(xCLR_ALL, xTRIG_CLK, xDLL_RESET, BIN_COUNT_START)
begin
	if xDLL_RESET = '0' or BIN_COUNT_START = '0' then
		--BIN_COUNT <= (others => '1');
		BIN_COUNT <= "0000";
--	elsif rising_edge(xTRIGCLK) and BIN_COUNT_START <= '1' then
	elsif rising_edge(xTRIG_CLK) and xDLL_RESET = '1' and BIN_COUNT_START = '1' then
		BIN_COUNT <= BIN_COUNT + 1;
	end if;
end process;

--process(xCLR_ALL, xMCLK, xDONE)
--begin
--	if xCLR_ALL = '1' or xDONE = '1' then
--		--BIN_COUNT_MASK <= (others => '0');
--		MASK_FLAG <= '0';
--		BIN_COUNT_CHECK <= (others => '0');
--	elsif xSET_SMPL_RATE = '1' and xMCLK = '1' then
--		BIN_COUNT_CHECK <= BIN_COUNT;
--		if BIN_COUNT_CHECK > 7 then
--			MASK_FLAG <= '1';
--			--BIN_COUNT_MASK <= "1000";
--		end if;
--	end if;
--end process;

process(xCLR_ALL, xDONE, EXT_TRIG)
begin
	if xCLR_ALL = '1' or xDONE = '1' then
		BIN_COUNT_SAVE <= (others => '0');
	elsif rising_edge(EXT_TRIG) then
		BIN_COUNT_SAVE <= BIN_COUNT;
	end if;
end process;
	
----------------------------------------------
-----CC triggering option------    
process(xMCLK, xDONE, xCLR_ALL, xCC_TRIG)
	begin
		if xDONE = '1' or xCLR_ALL = '1'  then
			CC_TRIG <= '0';
			EXT_TRIG_A <= '0';
		--elsif rising_edge(TRIG_FROM_CC) then
		elsif rising_edge(xCC_TRIG) then
			CC_TRIG <= '1';
			EXT_TRIG_A <= '1';
		end if;
end process;
		
--process(xMCLK, CC_TRIG, xCLR_ALL, xDONE)
--	begin
--		if xDONE = '1' or xCLR_ALL = '1' then
--			EXT_TRIG_A <= '0';
--		elsif falling_edge(xMCLK) and CC_TRIG = '1' then
--			EXT_TRIG_A <= '1';
--		end if;
--end process; 
-----end CC trigger control ------------
----------------------------------------------

--------------------------------------------
----internal trigger handling!--------------
process(xTRIG_CLK, xDONE, xCLR_ALL, SELF_TRIG_OR)
begin
	if xCLR_ALL = '1' or xDONE = '1' or TRIG_ENABLE = '0' or 
			RESET_TRIG_FROM_SOFTWARE = '1' then
		SELF_TRIG <= '0';
	elsif rising_edge(SELF_TRIG_OR) and TRIG_ENABLE = '1' then
		SELF_TRIG <= '1';
	end if;
end process;

process(xTRIG_CLK, SELF_TRIG, xCLR_ALL, xDONE)
begin
	if xDONE = '1' or xCLR_ALL = '1' or 
			RESET_TRIG_FROM_SOFTWARE = '1' then
		EXT_TRIG_C 		<= '0';
		TRIG_FEEDOUT 	<= '0';
	elsif falling_edge(xTRIG_CLK) and (SELF_TRIG = '1' or
			xTRIG_FEEDIN = '1') then
		EXT_TRIG_C 		<= '1';
		TRIG_FEEDOUT 	<= TRIG_ENABLE;
	end if;
end process; 

--process(xSELFTRIG, xDONE, xCLR_ALL, TRIG_ENABLE, xMCLK, SELF_TRIG)
--variable i : integer range 200000 downto -1 := 0;
--begin
--	if xCLR_ALL = '1' then --or TRIG_ENABLE = '0' then
--		TRIG_CLEAR 			<= '1';
--		TRIG_CHANNEL		<= (others=>'0');
--		i := 0;
--		HANDLE_TRIG_STATE <= WAIT_FOR_TRIG;
--	--elsif rising_edge(xMCLK) and TRIG_ENABLE = '1' then
--	elsif rising_edge(xMCLK) then
--		case HANDLE_TRIG_STATE is
--			
--			when WAIT_FOR_TRIG =>
--				TRIG_CLEAR <= '0';
--				if EXT_TRIG_C = '1' then
--					i := i+1;
--					if i = 2 then
--						TRIG_CHANNEL <= xSELFTRIG;
--						i := 0;
--						HANDLE_TRIG_STATE <= HOLD_TRIG;
--					end if;
--				end if;
--			
--			when HOLD_TRIG =>
--				TRIG_CLEAR <= '0';
--				if xDONE = '1' then
--					HANDLE_TRIG_STATE <= RESET_BOSS_TRIG;
--				end if;		
--				
--			
--			when RESET_BOSS_TRIG =>
--				TRIG_CLEAR <= '1';
--				i := i+1;
--				if i >=  10000 then
--					i := 0;
--					TRIG_CLEAR <= '0';
--					HANDLE_TRIG_STATE <= WAIT_FOR_TRIG;
--				end if;	
--		end case;
--	end if;
--end process;

process(xTRIG_CLK, xRESET_TRIG_FLAG)
		begin
			if xCLR_ALL = '1' then
				RESET_TRIG_FROM_SOFTWARE <= '0';
			elsif rising_edge(xTRIG_CLK) and (RESET_TRIG_COUNT = '0') then
				RESET_TRIG_FROM_SOFTWARE <= '0';
			elsif rising_edge(xTRIG_CLK) and xRESET_TRIG_FLAG = '1' then
				RESET_TRIG_FROM_SOFTWARE <= '1';
			end if;
	end process;
	
	process(xMCLK, RESET_TRIG_FROM_SOFTWARE)
	variable i : integer range 10000004 downto -1 := 0;
		begin
			if falling_edge(xMCLK) and RESET_TRIG_FROM_SOFTWARE = '0' then
				i := 0;
				RESET_TRIG_STATE <= RESETT;
				RESET_TRIG_COUNT <= '1';
			elsif falling_edge(xMCLK) and RESET_TRIG_FROM_SOFTWARE  = '1' then
				case RESET_TRIG_STATE is
					when RESETT =>
						i:=i+1;
						if i > 10000000 then
							i := 0;
							RESET_TRIG_STATE <= RELAXT;
						end if;
						
					when RELAXT =>
						RESET_TRIG_COUNT <= '0';

				end case;
			end if;
	end process;
---end internal trigger---------------------
--------------------------------------------
end Behavioral;
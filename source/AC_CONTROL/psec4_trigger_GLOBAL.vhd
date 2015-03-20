--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	psec4_trigger_GLOBAL
-- author		: 	ejo
-- date			: 	4/2014
-- description	:  psec4 trigger generation
--------------------------------------------------
	
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Definition_Pool.all;

entity psec4_trigger_GLOBAL is
	port(
			xTRIG_CLK				: in 	std_logic;   --fast clk (320MHz) to trigger all chans once internally triggered
			xMCLK						: in	std_logic;   --ext trig sync with write clk
			xCLR_ALL					: in	std_logic;   --wakeup reset (clears high)
			xDONE						: in	std_logic;	-- USB done signal		
			xSLOW_CLK				: in	std_logic;
			
			xCC_TRIG					: in	std_logic;   -- trig over LVDS
			xDC_TRIG					: in	std_logic;   -- on-board SMA input
			
			xSELFTRIG_0 			: in	std_logic_vector(5 downto 0); --internal trig sgnl
			xSELFTRIG_1 			: in	std_logic_vector(5 downto 0); --internal trig sgnl
			xSELFTRIG_2 			: in	std_logic_vector(5 downto 0); --internal trig sgnl
			xSELFTRIG_3				: in	std_logic_vector(5 downto 0); --internal trig sgnl
			xSELFTRIG_4 			: in	std_logic_vector(5 downto 0); --internal trig sgnl
			
			xSELF_TRIGGER_MASK	: in 	std_logic_vector(29 downto 0);
			xSELF_TRIGGER_SETTING: in	std_logic_vector(11 downto 0); --open dataspace for config of this block

			xRESET_TRIG_FLAG		: in	std_logic;
			
			xDLL_RESET				: in	std_logic;
			xPLL_LOCK				: in	std_logic;
			xTRIG_VALID   			: in	std_logic;
			xDONE_FROM_SYS			: in	std_logic;
			
			xTRIGGER_OUT			: out	std_logic;
			xSTART_ADC				: out std_logic;

			xSELFTRIG_CLEAR		: out	std_logic;
			
			xRATE_ONLY           : out std_logic;
			
			xPSEC4_TRIGGER_INFO_1: out Word_array;
			xPSEC4_TRIGGER_INFO_2: out Word_array;
			xPSEC4_TRIGGER_INFO_3: out Word_array;
			
			xSAMPLE_BIN				: out	std_logic_vector(3 downto 0);
			xSELF_TRIG_RATES		: out rate_count_array;

			xSELF_TRIG_SIGN		: out std_logic);
	end psec4_trigger_GLOBAL;

architecture Behavioral of psec4_trigger_GLOBAL is
-------------------------------------------------------------------------------
-- SIGNALS 
-------------------------------------------------------------------------------	
	type 	HANDLE_TRIG_TYPE	is (CHECK_FOR_TRIG, IDLE, WAIT_FOR_COINCIDENCE, WAIT_FOR_SYSTEM, 
											SELF_START_ADC, SELF_RESET, SELF_DONE);
	signal	HANDLE_TRIG_STATE	:	HANDLE_TRIG_TYPE;
	
	type 	RESET_TRIG_TYPE	is (RESETT, RELAXT);
	signal	RESET_TRIG_STATE:	RESET_TRIG_TYPE;
	
	type  COUNT_FINE_BINS_TYPE is (ONE, TWO, THREE, FOUR, FIVE, SIX, SEVEN, EIGHT, NINE, TEN);
	signal COUNT_FINE_BINS_STATE : COUNT_FINE_BINS_TYPE;
	
	--type to generate scaler mode based of 1 Hz clock
	type COUNT_RATE_TYPE    is (STATE_ONE, STATE_TWO);
	type COUNT_RATES_TYPE    is (	SELF_CHECK, SELF_CHECK_RESET,PRE_SELF_COUNT, SELF_COUNT, SELF_COUNT_SAVE, 
											SELF_COUNT_LATCH, SELF_COUNT_RESET, SELF_COUNT_HOLD);
	signal	COUNT_RATE_OF_SELFTRIG 	:		COUNT_RATE_TYPE;
	signal   SCALER_MODE_STATE		  	:   	COUNT_RATES_TYPE;

	type REG_TRIG_BITS_STATE_TYPE is (TRIG1, TRIG2, TRIG3, TRIG4, DONE5);
	signal REG_TRIG_BITS_STATE : REG_TRIG_BITS_STATE_TYPE  ;
	
	type SYSTEM_TRIG_COINC_STATE_TYPE is (GET_SYS_TRIG, PULSE_SYS_TRIG, END_SYS_TRIG);
	signal SYSTEM_TRIG_COINC_STATE  : SYSTEM_TRIG_COINC_STATE_TYPE;
-------------------------------------------------------------------------------
	signal SELF_TRIG_EXT							:  std_logic;     --self trig needs to be clocked to sync across boards!!
	signal SELF_TRIG_EXT_HI						:	std_logic;		--clock in on rising edge
	signal SELF_TRIG_EXT_LO						:  std_logic;		--clock in on falling edge
	signal CC_TRIG									:	std_logic;		--trigger signal over LVDS
	signal CC_TRIG_START_ADC					:  std_logic;
	signal DC_TRIG									: 	std_logic  := '0';		--trigger from AC/DC SMA input
	signal CLK_40									:  std_logic;
	
	signal SELF_TRIGGER   						: 	std_logic_vector (29 downto 0); 	-- self trigger bits
	signal SCALER_LATCH							: 	std_logic_vector (29 downto 0);	
	signal SELF_TRIG_LATCHED					: 	std_logic_vector (29 downto 0); 	-- latched self trigger bits
	signal SELF_TRIGGER_CLOCKED				: 	std_logic_vector (29 downto 0); 	-- latched self trigger bits

	signal SELF_TRIGGER_LATCHED_OR			: 	std_logic;
	signal SELF_TRIGGER_CLOCKED_OR			: 	std_logic;

	signal SELF_TRIGGER_MASK 					: 	std_logic_vector (29 downto 0); -- self trigger mask bits
	signal SELF_TRIGGER_NO_COINCIDNT 		: 	std_logic_vector (4 downto 0);  -- number of coincident triggers (target)
	signal SELF_TRIGGER_NO						: 	std_logic_vector (2 downto 0);  -- number of coincident triggers
	signal SELF_TRIGGER_OR						: 	std_logic;
	signal SELF_TRIGGER_START_ADC				: 	std_logic;
	
	signal SELF_COUNT_RATE						: 	rate_count_array;
	signal SELF_COUNT_RATE_LATCH				: 	rate_count_array;
	
	--rate count state-machine indicators:
	signal SELF_COUNT_sig						: 	std_logic;
	signal SELF_COUNT_RESET_sig				: 	std_logic;
	
	signal RESET_TRIG_FROM_SOFTWARE			:	std_logic := '0';      -- trig clear signals
	signal RESET_TRIG_COUNT						:	std_logic := '1';      -- trig clear signals
	signal RESET_TRIG_FROM_FIRMWARE_FLAG 	:  std_logic;
	signal SELF_TRIG_CLR							:  std_logic;
	signal SELFTRIG_CLEAR            		:  std_logic;
	signal reset_trig_from_scaler_mode		: 	std_logic;
	
	signal SELF_WAIT_FOR_SYS_TRIG    		:	std_logic;
	signal SELF_TRIG_RATE_ONLY 				: 	std_logic;
	signal SELF_TRIG_EN							: 	std_logic;
	signal USE_SMA_TRIG_ON_BOARD				: 	std_logic;
	signal SMA_TRIG								: 	std_logic;
	
	signal trig_latch1							: 	std_logic_vector (29 downto 0); 
	signal trig_latch2							: 	std_logic_vector (29 downto 0); 
	signal trig_latch3							: 	std_logic_vector (29 downto 0);
	signal trig_latch4							: 	std_logic_vector (29 downto 0); 

	signal EVENT_CNT								:	std_logic_vector(31 downto 0);	

	signal BIN_COUNT								: 	std_logic_vector(3 downto 0) := "0000";
	signal BIN_COUNT_SAVE						: 	std_logic_vector(3 downto 0) := "0000";
	
	signal clock_dll_reset_hi		   		: 	std_logic;--_vector(2 downto 0) := (others=>'0');
	signal clock_dll_reset_lo					: 	std_logic;--_vector(2 downto 0) := (others=>'0');
	signal clock_dll_reset_lo_lo	   		: 	std_logic;--_vector(2 downto 0) := (others=>'0');
	signal clock_dll_reset_hi_hi				: 	std_logic;--_vector(2 downto 0) := (others=>'0');
	signal self_trig_ext_registered  		: 	std_logic_vector(2 downto 0) := (others=>'0');
	signal reset_from_scaler_reg				: 	std_logic_vector(2 downto 0) := (others=>'0');
	signal self_count_1Hz			         : 	std_logic_vector(2 downto 0) := (others=>'0');
	signal clear_all_registered_hi   		: 	std_logic_vector(2 downto 0) := (others=>'0'); -- transfer clock domain
	signal clear_all_registered_lo   		: 	std_logic_vector(2 downto 0) := (others=>'0'); -- transfer clock domain
	signal self_trig_latched_reg				: 	std_logic_vector(2 downto 0) := (others=>'0');
	signal cc_trig_reg							: 	std_logic_vector(2 downto 0) := (others=>'0');
	signal RATE_ONLY_flag						: 	std_logic := '0';
	
	signal cc_trig_coinc							:  std_logic;
	signal cc_trig_coinc_pulse					:  std_logic;
	
	signal coincidence_window					:  std_logic_vector(2 downto 0) := "010";
	signal cc_trigger_width						:  std_logic_vector(2 downto 0) := "010";
	signal TRIG_OR_ASIC0							:  std_logic;
	signal TRIG_OR_ASIC1							:  std_logic;
	signal TRIG_OR_ASIC2							:  std_logic;
	signal TRIG_OR_ASIC3							:  std_logic;
	signal TRIG_OR_ASIC4							:  std_logic;
	
	signal USE_CONCIDENCE						:  std_logic := '0';
	signal coincidence_0							:  std_logic;
	signal coincidence_1							:  std_logic;
	signal coincidence_2							:  std_logic;
	signal coincidence_3							:  std_logic;
	signal coincidence_4							:  std_logic;
	
	signal pulse_counter							:  std_logic_vector(3 downto 0) := (others=>'0');
	signal coinc_counter							:  std_logic_vector(3 downto 0) := (others=>'0');

component psec4_SELFtrigger
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
			
			xSELF_TRIG_CLOCKED_OR: out std_logic;
			xSELF_TRIG_LATCHED_OR: out std_logic;
			xSELF_TRIG_BITSUM		: out std_logic_vector(2 downto 0);
			xSELF_TRIG_CLOCKED	: out std_logic_vector(29 downto 0);
			xSELF_TRIG_LATCHED	: out std_logic_vector(29 downto 0));
			
end component;
-------------------------------------------------------------------------------  
begin  -- Behavioral
-------------------------------------------------------------------------------		
	---------------------------------------------------------------
	SELF_TRIG_EXT  <= SELF_TRIG_EXT_HI;
	---------------------------------------------------------------
	--this is the PSEC4 combined trigger signal!!!!!!!!!!!!!!!!!!!!
	xTRIGGER_OUT	<= (CC_TRIG and (not SELF_WAIT_FOR_SYS_TRIG)) or (SELF_TRIG_EXT_HI and SELF_TRIG_EN);
	---------------------------------------------------------------
	CLK_40			<= xMCLK;
	---------------------------------------------------------------
	xSTART_ADC <= CC_TRIG_START_ADC or SELF_TRIGGER_START_ADC;
	---------------------------------------------------------------
	SELF_TRIG_CLR <= xCLR_ALL or (not xDLL_RESET) or (not SELF_TRIG_EN);
	SELFTRIG_CLEAR <= SELF_TRIG_CLR or RESET_TRIG_FROM_SOFTWARE    		--this clears trigger given software or firmware instruction
							or RESET_TRIG_FROM_FIRMWARE_FLAG
							or reset_from_scaler_reg(2)                  		--this clears trigger when running in scaler mode 
							or (SELF_TRIG_RATE_ONLY nor xTRIG_VALID)     		--this clears trigger whenever both are 0
							or ((not xTRIG_VALID) and SELF_WAIT_FOR_SYS_TRIG);	--this clears trigger when valid=0 and wait_for_system = 1
	---------------------------------------------------------------
	xSELFTRIG_CLEAR <= SELFTRIG_CLEAR;
	---------------------------------------------------------------
	xSELF_TRIG_RATES <= SELF_COUNT_RATE_LATCH;
	---------------------------------------------------------------
----------------------------------------------------------
--packet-ize some meta-data
----------------------------------------------------------
xPSEC4_TRIGGER_INFO_1(0)(3 downto 0)  <= BIN_COUNT_SAVE;  --fine timestamp (rising)
xPSEC4_TRIGGER_INFO_1(0)(15 downto 4) <= (others=> '0');
xPSEC4_TRIGGER_INFO_1(1)(11 downto 0) <= xSELF_TRIGGER_SETTING;
xPSEC4_TRIGGER_INFO_1(2)(15 downto 0) <= EVENT_CNT(15 downto 0);
xPSEC4_TRIGGER_INFO_1(3)(15 downto 0) <= EVENT_CNT(31 downto 16);

xPSEC4_TRIGGER_INFO_2(0)(15 downto 0) <= trig_latch1(15 downto 0);
xPSEC4_TRIGGER_INFO_2(1)(15 downto 0) <= "00" & trig_latch1(29 downto 16);
xPSEC4_TRIGGER_INFO_2(2)(15 downto 0) <= trig_latch2(15 downto 0);
xPSEC4_TRIGGER_INFO_2(3)(15 downto 0) <= "00" & trig_latch2(29 downto 16);
xPSEC4_TRIGGER_INFO_2(4)(15 downto 0) <= trig_latch3(15 downto 0);

xPSEC4_TRIGGER_INFO_3(0)(15 downto 0) <= "00" & trig_latch3(29 downto 16);
xPSEC4_TRIGGER_INFO_3(1)(15 downto 0) <= trig_latch4(15 downto 0);
xPSEC4_TRIGGER_INFO_3(2)(15 downto 0) <= "00" & trig_latch4(29 downto 16);
xPSEC4_TRIGGER_INFO_3(3)(15 downto 0) <= SELF_TRIGGER_MASK(15 downto 0);
xPSEC4_TRIGGER_INFO_3(4)(15 downto 0) <= "00" & SELF_TRIGGER_MASK(29 downto 16);
----------------------------------------------------------
----------------------------------------------------------
process(	xCLR_ALL, xTRIG_CLK, xDONE, SELF_TRIGGER_LATCHED_OR, 
			SELF_TRIGGER_CLOCKED)
begin	
	if xCLR_ALL = '1' or xDONE = '1' or SELF_TRIG_CLR = '1' or 
			RESET_TRIG_FROM_SOFTWARE = '1' then
		trig_latch1 <= (others => '0');
		trig_latch2 <= (others => '0');
		trig_latch3 <= (others => '0');
		trig_latch4 <= (others => '0');
		REG_TRIG_BITS_STATE <= trig1;
	elsif falling_edge(xTRIG_CLK) and SELF_TRIG_EXT_HI = '1' then
		case REG_TRIG_BITS_STATE is
			when trig1 =>
				trig_latch1 <= SELF_TRIGGER_CLOCKED;
				REG_TRIG_BITS_STATE <= trig2;
			when trig2 =>
				trig_latch2 <= SELF_TRIGGER_CLOCKED;
				REG_TRIG_BITS_STATE <= trig3;
			when trig3 =>
				trig_latch3 <= SELF_TRIGGER_CLOCKED;
				REG_TRIG_BITS_STATE <= trig4;
			when trig4 =>
				trig_latch4 <= SELF_TRIGGER_CLOCKED;
				REG_TRIG_BITS_STATE <= done5;
			when done5 =>
				-----
		end case;
	end if;
end process;			
----------------------------------------------------------
-----CC triggering option
----- when not using 'wait_for_system option'
----------------------------------------------------------
process(xMCLK, xDONE, xCLR_ALL, xCC_TRIG)
	begin
		if xDONE = '1' or xCLR_ALL = '1' or SELF_WAIT_FOR_SYS_TRIG = '1' or xDONE_FROM_SYS = '1' then
			CC_TRIG <= '0';
			CC_TRIG_START_ADC <= '0';
		elsif rising_edge(xCC_TRIG) and SELF_WAIT_FOR_SYS_TRIG = '0' then
			CC_TRIG <= '1';
			CC_TRIG_START_ADC <= '1'; --not SELF_WAIT_FOR_SYS_TRIG;  --if self-triggering, don't start ADC here
		end if;
end process;
----------------------------------------------------------
-----CC triggering from system
----- when  using 'wait_for_system option'
----------------------------------------------------------
process(xCLR_ALL, xCC_TRIG)
	begin
		if xCLR_ALL = '1' or SELF_WAIT_FOR_SYS_TRIG = '0' or xTRIG_VALID = '0' or xDONE_FROM_SYS = '1'then
			cc_trig_coinc <= '0';
		elsif rising_edge(xCC_TRIG) and SELF_WAIT_FOR_SYS_TRIG = '1' and xTRIG_VALID = '1' then
			cc_trig_coinc <= '1';  --only want to look at first rising edge in xTRIG_VALID region
		end if;
end process;
------------
process(CLK_40, xCLR_ALL, cc_trig_coinc)
variable i : integer range 100 downto -1 := 0;
	begin
		if xCLR_ALL = '1' or SELF_WAIT_FOR_SYS_TRIG = '0' or xTRIG_VALID = '0' or cc_trig_coinc = '0' or xDONE_FROM_SYS = '1' then
			i:=0;
			pulse_counter <= (others=>'0');
			cc_trig_coinc_pulse <= '0';
			SYSTEM_TRIG_COINC_STATE <= GET_SYS_TRIG;
			
		elsif falling_edge(CLK_40) and cc_trig_coinc = '1' then
			case SYSTEM_TRIG_COINC_STATE is
				
				when GET_SYS_TRIG =>
					pulse_counter <= (others=>'0');
					cc_trig_coinc_pulse <= '1';
					SYSTEM_TRIG_COINC_STATE <= PULSE_SYS_TRIG;
					
				when PULSE_SYS_TRIG =>
					if pulse_counter = (('0' &cc_trigger_width(2 downto 0)) + 2) then   
					--if i > (cc_trigger_width + 1) then   
						SYSTEM_TRIG_COINC_STATE <= END_SYS_TRIG;
					elsif pulse_counter = "1111" then
						SYSTEM_TRIG_COINC_STATE <= END_SYS_TRIG;
					else
						pulse_counter <= pulse_counter + 1;
						cc_trig_coinc_pulse <= '1';
					end if;
					
				when END_SYS_TRIG =>
					pulse_counter <= (others=>'0');
					cc_trig_coinc_pulse <= '0';
			
			end case;			
		end if;
end process;
----------------------------------------------------------
----------------------------------------------------------
-----Option to use sma trigger input
----------------------------------------------------------
process(xMCLK, xDONE, xCLR_ALL, xCC_TRIG)
	begin
		if xCLR_ALL = '1' or SELFTRIG_CLEAR = '1' or USE_SMA_TRIG_ON_BOARD = '0' or xDONE_FROM_SYS = '1' then
				----------------
				SMA_TRIG <= '0';
				----------------
		elsif rising_edge(xDC_TRIG) and USE_SMA_TRIG_ON_BOARD = '1' 
			and SELF_TRIG_EN = '1' then
				----------------
				SMA_TRIG <= '1';
				----------------
		end if;
end process;
----------------------------------------------------------	
--trigger 'binning' firmware
--poor man's TDC
----------------------------------------------------------
fall_edge_bin:process(xTRIG_CLK, clock_dll_reset_hi)
begin
	if clock_dll_reset_hi = '0' then
		BIN_COUNT <= (others => '0');
		COUNT_FINE_BINS_STATE <= ONE;
	--binning clock is 10X sample clock
	elsif falling_edge(xTRIG_CLK) and clock_dll_reset_hi = '1' then 
		case COUNT_FINE_BINS_STATE is
			when ONE=>
				BIN_COUNT <= "0001";
				COUNT_FINE_BINS_STATE <= TWO;
			when TWO=>
				BIN_COUNT <= "0010";
				COUNT_FINE_BINS_STATE <= THREE;
			when THREE=>
				BIN_COUNT <= "0011";
				COUNT_FINE_BINS_STATE <= FOUR;
			when FOUR=>
				BIN_COUNT <= "0100";
				COUNT_FINE_BINS_STATE <= FIVE;
			when FIVE=>
				BIN_COUNT <= "0101";
				COUNT_FINE_BINS_STATE <= SIX;
			when SIX=>
				BIN_COUNT <= "0110";
				COUNT_FINE_BINS_STATE <= SEVEN;
			when SEVEN=>
				BIN_COUNT <= "0111";
				COUNT_FINE_BINS_STATE <= EIGHT;
			when EIGHT=>
				BIN_COUNT <= "1000";
				COUNT_FINE_BINS_STATE <= NINE;
			when NINE=>
				BIN_COUNT <= "1001";
				COUNT_FINE_BINS_STATE <= TEN;	
			when TEN=>
				BIN_COUNT <= "0000";
				COUNT_FINE_BINS_STATE <= ONE;
		end case;
	end if;
end process;
----
process(SELF_TRIG_EXT_HI) 
begin
	if rising_edge(SELF_TRIG_EXT_HI) then
		BIN_COUNT_SAVE <= BIN_COUNT;
	end if;
end process;
--end binning
----------------------------------------------------------
----------------------------------------------------------
--clock domain transfers
----------------------------------------------------------
process (xCLR_ALL, xTRIG_CLK )
begin
	if xCLR_ALL = '1' then
		clock_dll_reset_hi <= '0';
	elsif rising_edge(xTRIG_CLK) then
		clock_dll_reset_hi <= xDLL_RESET;
	end if;
end process;
----------------------------------------------------------
--generic clock domain transfer for slower signals
process(xMCLK)
begin
	if rising_edge(xMCLK) then
		clear_all_registered_hi 	<= clear_all_registered_hi(1 downto 0)&xCLR_ALL;
		self_count_1Hz					<= self_count_1Hz(1 downto 0)&SELF_COUNT_sig;
		self_trig_latched_reg      <= self_trig_latched_reg(1 downto 0)&SELF_TRIGGER_LATCHED_OR;
	end if;
end process;
process(xMCLK)
begin
	if falling_edge(xMCLK) then
		self_trig_ext_registered 	<= self_trig_ext_registered(1 downto 0)&SELF_TRIG_EXT_HI;
		clear_all_registered_lo 	<= clear_all_registered_lo(1 downto 0)&xCLR_ALL;
		reset_from_scaler_reg   	<= reset_from_scaler_reg(1 downto 0)&reset_trig_from_scaler_mode;
		cc_trig_reg                <= cc_trig_reg(1 downto 0)&CC_TRIG;
	end if;
end process;

process(xCLR_ALL, xMCLK, self_trig_ext_registered)
begin
	if xCLR_ALL = '1' then
		TRIG_OR_ASIC0 <= '0';
		TRIG_OR_ASIC1 <= '0';
		TRIG_OR_ASIC2 <= '0';
		TRIG_OR_ASIC3 <= '0';
		TRIG_OR_ASIC4 <= '0';

	elsif rising_edge(xMCLK) and self_trig_ext_registered(1) = '0'then
		TRIG_OR_ASIC0 <= '0';
		TRIG_OR_ASIC1 <= '0';
		TRIG_OR_ASIC2 <= '0';
		TRIG_OR_ASIC3 <= '0';
		TRIG_OR_ASIC4 <= '0';
	
	elsif rising_edge(xMCLK) and self_trig_ext_registered(1) = '1' then	
		TRIG_OR_ASIC0 <= SELF_TRIGGER(0) or SELF_TRIGGER(1) or SELF_TRIGGER(2) or SELF_TRIGGER(3) or SELF_TRIGGER(4) or SELF_TRIGGER(5);
		TRIG_OR_ASIC1 <= SELF_TRIGGER(6) or SELF_TRIGGER(7) or SELF_TRIGGER(8) or SELF_TRIGGER(9) or SELF_TRIGGER(10) or SELF_TRIGGER(11);
		TRIG_OR_ASIC2 <= SELF_TRIGGER(12) or SELF_TRIGGER(13) or SELF_TRIGGER(14) or SELF_TRIGGER(15) or SELF_TRIGGER(16) or SELF_TRIGGER(17);
		TRIG_OR_ASIC3 <= SELF_TRIGGER(18) or SELF_TRIGGER(19) or SELF_TRIGGER(20) or SELF_TRIGGER(21) or SELF_TRIGGER(22) or SELF_TRIGGER(23);
		TRIG_OR_ASIC4 <= SELF_TRIGGER(24) or SELF_TRIGGER(25) or SELF_TRIGGER(26) or SELF_TRIGGER(27) or SELF_TRIGGER(28) or SELF_TRIGGER(29);
	end if;
end process;
		
process(xCLR_ALL, xMCLK, self_trig_ext_registered)
begin
	if xCLR_ALL = '1' then
		coincidence_0 <= '0';
		coincidence_1 <= '0';
		coincidence_2 <= '0';
		coincidence_3 <= '0';
		coincidence_4 <= '0';
	elsif rising_edge(xMCLK) and self_trig_ext_registered(2) = '0' then
		coincidence_0 <= '0';
		coincidence_1 <= '0';
		coincidence_2 <= '0';
		coincidence_3 <= '0';
		coincidence_4 <= '0';
	elsif rising_edge(xMCLK) and self_trig_ext_registered(2) = '1' then
		coincidence_0 <= TRIG_OR_ASIC0 and TRIG_OR_ASIC1;
		coincidence_1 <= TRIG_OR_ASIC1 and TRIG_OR_ASIC2;
		coincidence_2 <= TRIG_OR_ASIC2 and TRIG_OR_ASIC3;
		coincidence_3 <= TRIG_OR_ASIC3 and TRIG_OR_ASIC4;
		coincidence_4 <= TRIG_OR_ASIC4 and TRIG_OR_ASIC0;
	end if;
end process;
	
----------------------------------------------------------
---self triggering firmware:
----------------------------------------------------------
----------------------------------------------------------
---parse self_trigger_settings
----------------------------------------------------------
SELF_TRIGGER_MASK       <= xSELF_TRIGGER_MASK;
SELF_TRIG_EN 				<= xSELF_TRIGGER_SETTING(0);
SELF_WAIT_FOR_SYS_TRIG 	<= xSELF_TRIGGER_SETTING(1);
SELF_TRIG_RATE_ONLY 		<= xSELF_TRIGGER_SETTING(2);
xRATE_ONLY 					<= SELF_TRIG_RATE_ONLY;
xSELF_TRIG_SIGN			<= xSELF_TRIGGER_SETTING(3);
USE_SMA_TRIG_ON_BOARD   <= xSELF_TRIGGER_SETTING(4);
USE_CONCIDENCE				<= xSELF_TRIGGER_SETTING(5);

coincidence_window      <= xSELF_TRIGGER_SETTING(11 downto 9);
cc_trigger_width			<= xSELF_TRIGGER_SETTING(8 downto 6);
----------------------------------------------------------
SELF_TRIGGER <= xSELFTRIG_4 & xSELFTRIG_3 & xSELFTRIG_2 & xSELFTRIG_1 & xSELFTRIG_0;
----------------------------------------------------------
--now, send in self trigger:	
----------------------------------------------------------
process( xTRIG_CLK, SELF_TRIGGER_LATCHED_OR,
			xCLR_ALL, xDONE, SELFTRIG_CLEAR, xTRIG_VALID)
begin	
	if xCLR_ALL = '1' or (xDONE = '1' and SELF_TRIG_EN = '0') or xDONE_FROM_SYS = '1'
		or (SELFTRIG_CLEAR = '1' and SELF_TRIG_EN = '1') or RATE_ONLY_flag = '1' then
		--
		SELF_TRIG_EXT_HI <= '0';
		SELF_TRIG_EXT_LO <= '0';
		--
	--latch self-trigger signal from SELF_TRIGGER_WRAPPER or tag system trigger, depending on source
   --elsif rising_edge(xTRIG_CLK) and (SELF_TRIGGER_LATCHED_OR = '1' and xTRIG_VALID= '1') or CC_TRIG = '1') then
	elsif rising_edge(xTRIG_CLK) and (((  	(xSELFTRIG_0(0)='1'and xSELF_TRIGGER_MASK(0)='1')   or
														(xSELFTRIG_0(1)='1'and xSELF_TRIGGER_MASK(1)='1')   or
														(xSELFTRIG_0(2)='1'and xSELF_TRIGGER_MASK(2)='1')   or
														(xSELFTRIG_0(3)='1'and xSELF_TRIGGER_MASK(3)='1')   or
														(xSELFTRIG_0(4)='1'and xSELF_TRIGGER_MASK(4)='1')   or
														(xSELFTRIG_0(5)='1'and xSELF_TRIGGER_MASK(5)='1')   or
														(xSELFTRIG_1(0)='1'and xSELF_TRIGGER_MASK(6)='1')   or
														(xSELFTRIG_1(1)='1'and xSELF_TRIGGER_MASK(7)='1')   or
														(xSELFTRIG_1(2)='1'and xSELF_TRIGGER_MASK(8)='1')   or
														(xSELFTRIG_1(3)='1'and xSELF_TRIGGER_MASK(9)='1')   or
														(xSELFTRIG_1(4)='1'and xSELF_TRIGGER_MASK(10)='1')  or
														(xSELFTRIG_1(5)='1'and xSELF_TRIGGER_MASK(11)='1')  or
														(xSELFTRIG_2(0)='1'and xSELF_TRIGGER_MASK(12)='1')  or
														(xSELFTRIG_2(1)='1'and xSELF_TRIGGER_MASK(13)='1')  or
														(xSELFTRIG_2(2)='1'and xSELF_TRIGGER_MASK(14)='1')  or
														(xSELFTRIG_2(3)='1'and xSELF_TRIGGER_MASK(15)='1')  or
														(xSELFTRIG_2(4)='1'and xSELF_TRIGGER_MASK(16)='1')  or
														(xSELFTRIG_2(5)='1'and xSELF_TRIGGER_MASK(17)='1')  or	
														(xSELFTRIG_3(0)='1'and xSELF_TRIGGER_MASK(18)='1')  or
														(xSELFTRIG_3(1)='1'and xSELF_TRIGGER_MASK(19)='1')  or
														(xSELFTRIG_3(2)='1'and xSELF_TRIGGER_MASK(20)='1')  or
														(xSELFTRIG_3(3)='1'and xSELF_TRIGGER_MASK(21)='1')  or
														(xSELFTRIG_3(4)='1'and xSELF_TRIGGER_MASK(22)='1')  or
														(xSELFTRIG_3(5)='1'and xSELF_TRIGGER_MASK(23)='1')  or
														(xSELFTRIG_4(0)='1'and xSELF_TRIGGER_MASK(24)='1')  or
														(xSELFTRIG_4(1)='1'and xSELF_TRIGGER_MASK(25)='1')  or
														(xSELFTRIG_4(2)='1'and xSELF_TRIGGER_MASK(26)='1')  or
														(xSELFTRIG_4(3)='1'and xSELF_TRIGGER_MASK(27)='1')  or
														(xSELFTRIG_4(4)='1'and xSELF_TRIGGER_MASK(28)='1')  or
														(xSELFTRIG_4(5)='1'and xSELF_TRIGGER_MASK(29)='1') 
														or SMA_TRIG = '1' )  and xTRIG_VALID= '1') or 
														(CC_TRIG = '1' and SELF_WAIT_FOR_SYS_TRIG = '0')) then
		--
		SELF_TRIG_EXT_HI <= 	'1';    
		--
	end if;
end process;									
----------------------------------------------------------
--process to determine whether to start ADC or 
--release trigger signal
----------------------------------------------------------
process(CLK_40, xCLR_ALL, xDONE)
variable i : integer range 100 downto -1 := 0;
begin
	--HANDLE_TRIG_STATE <= WAIT_FOR_COINCIDENCE;
	if xCLR_ALL = '1' or (xDONE = '1' and SELF_TRIG_EN = '0') or xDONE_FROM_SYS = '1' or
		--or (xTRIG_VALID = '0' and SELF_TRIG_EN = '1')  or
		SELF_TRIG_RATE_ONLY = '1' then
		--
		i := 0;
		SELF_TRIGGER_START_ADC <= '0';
		RESET_TRIG_FROM_FIRMWARE_FLAG <= '0';
		coinc_counter <= (others =>'0');
		HANDLE_TRIG_STATE <= IDLE;
		--
	elsif rising_edge(CLK_40) then	
		case HANDLE_TRIG_STATE is
			when IDLE =>
				coinc_counter <= (others =>'0');
				RESET_TRIG_FROM_FIRMWARE_FLAG <= '0';
				HANDLE_TRIG_STATE <=CHECK_FOR_TRIG;
			
			when CHECK_FOR_TRIG=>
				RESET_TRIG_FROM_FIRMWARE_FLAG <= '0';
				coinc_counter <= (others =>'0');
				i := 0;
				--if SELF_TRIGGER_NO >= SELF_TRIGGER_NO_COINCIDNT then
				--	i := 0;
				if  self_trig_ext_registered(2) = '1' then
					HANDLE_TRIG_STATE <= WAIT_FOR_COINCIDENCE;
				
				else
					HANDLE_TRIG_STATE <= IDLE;
				
				end if;
				
			when WAIT_FOR_COINCIDENCE=> 
				if  USE_CONCIDENCE = '0' and SELF_WAIT_FOR_SYS_TRIG = '0' then
					--
					i := 0;
					HANDLE_TRIG_STATE <= SELF_START_ADC;
					--
				elsif USE_CONCIDENCE = '0' and SELF_WAIT_FOR_SYS_TRIG = '1' then
					--
					i := 0;
					HANDLE_TRIG_STATE <= WAIT_FOR_SYSTEM;
					--
				elsif SELF_WAIT_FOR_SYS_TRIG = '0' and USE_CONCIDENCE = '1' and 
					(coincidence_0 = '1' or coincidence_1 = '1' or coincidence_2 = '1' or coincidence_3 = '1' or coincidence_4 = '1') then
					--
					i := 0;
					HANDLE_TRIG_STATE <= SELF_START_ADC;
					--
				elsif SELF_WAIT_FOR_SYS_TRIG = '1' and USE_CONCIDENCE = '1' and 
					(coincidence_0 = '1' or coincidence_1 = '1' or coincidence_2 = '1' or coincidence_3 = '1' or coincidence_4 = '1') then
					--
					i := 0;
					HANDLE_TRIG_STATE <= WAIT_FOR_SYSTEM;
					--
				--elsif i>1 then
				--	i := 0;
				--	HANDLE_TRIG_STATE <= SELF_RESET;
				else
					HANDLE_TRIG_STATE <= SELF_RESET;
				--	i := i+1;
				end if;
	
			when WAIT_FOR_SYSTEM => 
				if cc_trig_coinc_pulse = '1' then
					i := 0;
					HANDLE_TRIG_STATE <= SELF_START_ADC;
				elsif coinc_counter(2 downto 0) = (('0' & coincidence_window(2 downto 0))) or coinc_counter = "1111" then 
					HANDLE_TRIG_STATE <= SELF_RESET;
				else
					coinc_counter <= coinc_counter + 1;
				end if;
				
			when SELF_START_ADC =>
				coinc_counter <= (others =>'0');
				i := 0;
				SELF_TRIGGER_START_ADC <= '1'; 
				---ends case
							
			when SELF_RESET =>
				coinc_counter <= (others =>'0');
				if i > 2 then
					i := 0;
					HANDLE_TRIG_STATE <= SELF_DONE;
				else
					RESET_TRIG_FROM_FIRMWARE_FLAG <= '1';
					i := i + 1;
				end if;
				
			when SELF_DONE =>
				RESET_TRIG_FROM_FIRMWARE_FLAG <= '0';
				HANDLE_TRIG_STATE <= IDLE;

			
		end case;
	end if;
end process;
----------------------------------------------------------	
--process to measure trigger rates ('scaler' mode)
process(CLK_40, SELF_TRIG_RATE_ONLY)
begin
	if SELF_TRIG_RATE_ONLY = '0' then
		RATE_ONLY_flag <= '0';
	elsif rising_edge(CLK_40) and SELF_TRIG_RATE_ONLY = '1' then
		RATE_ONLY_flag <= '1';
	end if;
end process;
process(xCLR_ALL, CLK_40, SELF_TRIG_RATE_ONLY, SELF_COUNT_sig)
variable i : integer range 100 downto -1 := 0;
begin
	--SCALER_MODE_STATE <= SELF_CHECK;
	if xCLR_ALL = '1' or RATE_ONLY_flag = '0' then
		for ii in 29 downto 0 loop
			SELF_COUNT_RATE(ii)       <= (others=>'0');
			SELF_COUNT_RATE_LATCH(ii) <= (others=>'0');
		end loop;
	
		reset_trig_from_scaler_mode <= '0';
		SCALER_MODE_STATE <= SELF_CHECK;

 	elsif falling_edge(CLK_40) and RATE_ONLY_flag = '1' then
		
		--increment scalar state machine:
		case SCALER_MODE_STATE is
		
			--check to see state of slow (1 Hz nominal) state machine
			when SELF_CHECK =>
				reset_trig_from_scaler_mode <= '1';
				
				--state #1: count triggers
				if self_count_1Hz(2) = '1'   then
					--check for overflow
					for ii in 29 downto 0 loop
						if SELF_COUNT_RATE(ii) = x"FFFF" then
							SELF_COUNT_RATE(ii) <= x"FFFE";
						else
							SELF_COUNT_RATE(ii) <= SELF_COUNT_RATE(ii);
						end if;
					end loop;
					SCALER_MODE_STATE <= SELF_CHECK_RESET; 
				
				--state #2: register trigger count and reset counters
				else
					SCALER_MODE_STATE <= SELF_COUNT_LATCH; 
				end if;
				
			when SELF_CHECK_RESET =>
				reset_trig_from_scaler_mode <= '1';
				SCALER_MODE_STATE <= PRE_SELF_COUNT;
				
			when PRE_SELF_COUNT =>
				if self_count_1Hz(2) = '1' then
					SCALER_MODE_STATE <= SELF_COUNT;
				else
					SCALER_MODE_STATE <= SELF_CHECK;	
				end if;

			--count triggers
			when SELF_COUNT =>
				reset_trig_from_scaler_mode <= '0';		
				
				--did self-trigger fire?
				if self_trig_latched_reg(2) = '1' then
					SCALER_MODE_STATE <= SELF_COUNT_SAVE;
				
				--or, if there is nothing 
				else
					SCALER_MODE_STATE <= PRE_SELF_COUNT;
				end if;
				
			when SELF_COUNT_SAVE =>
				reset_trig_from_scaler_mode <= '0';		
				--add up bits to rate counting array
				for ii in 29 downto 0 loop
					if SELF_TRIG_LATCHED(ii) = '1' then
						SELF_COUNT_RATE(ii) <= SELF_COUNT_RATE(ii) + 1;
					else 
						SELF_COUNT_RATE(ii) <= SELF_COUNT_RATE(ii);
					end if;
				end loop;	
				SCALER_MODE_STATE <= SELF_CHECK;		
		
			when SELF_COUNT_LATCH =>
				reset_trig_from_scaler_mode <= '1';		
				for ii in 29 downto 0 loop
					SELF_COUNT_RATE_LATCH(ii) <= SELF_COUNT_RATE(ii);
				end loop;
				
				SCALER_MODE_STATE  <= SELF_COUNT_RESET;
			
			when SELF_COUNT_RESET =>
				reset_trig_from_scaler_mode <= '1';		
				for ii in 29 downto 0 loop
					SELF_COUNT_RATE(ii) <= (others=>'0');
				end loop;
				
				SCALER_MODE_STATE <=  SELF_COUNT_HOLD;
			
			when SELF_COUNT_HOLD =>
				reset_trig_from_scaler_mode <= '1';		
				if self_count_1Hz(2) = '1' then
					SCALER_MODE_STATE <= SELF_CHECK;
				else
					for ii in 29 downto 0 loop
						SELF_COUNT_RATE(ii) <= (others=>'0');
					end loop;
					SCALER_MODE_STATE <= SELF_COUNT_HOLD;

				end if;
				

			when others=>
				SCALER_MODE_STATE <= SELF_CHECK;
	
		end case;
	end if;
end process;	
--generate signals to toggle above process w.r.t. slow 1Hz clock
process(xCLR_ALL, xSLOW_CLK)
begin
	--COUNT_RATE_OF_SELFTRIG <= STATE_ONE;
	if xCLR_ALL = '1' then 
		SELF_COUNT_sig       <= '0';
		COUNT_RATE_OF_SELFTRIG <= STATE_ONE;
	elsif rising_edge(xSLOW_CLK) then
		case COUNT_RATE_OF_SELFTRIG is
			when STATE_ONE =>
				SELF_COUNT_sig         <= '1';
				COUNT_RATE_OF_SELFTRIG <= STATE_TWO;
			when STATE_TWO =>
				SELF_COUNT_sig         <= '0';
				COUNT_RATE_OF_SELFTRIG <= STATE_ONE;
			when others=>
				--blank
		end case;
	end if;
end process;
----------------------------------------------------------
--clearing trigger
						
process(xTRIG_CLK, xRESET_TRIG_FLAG)
		begin
			if xCLR_ALL = '1' then
				RESET_TRIG_FROM_SOFTWARE <= '0';
			elsif rising_edge(xMCLK) and (RESET_TRIG_COUNT = '0') then
				RESET_TRIG_FROM_SOFTWARE <= '0';
			elsif rising_edge(xMCLK) and (xRESET_TRIG_FLAG = '1') then -- or RESET_TRIG_FROM_FIRMWARE_FLAG = '1') then
				RESET_TRIG_FROM_SOFTWARE <= '1';
			end if;
	end process;
	
	process(xMCLK, RESET_TRIG_FROM_SOFTWARE)
	variable i : integer range 100 downto -1  := 0;
		begin
			if falling_edge(xMCLK) and RESET_TRIG_FROM_SOFTWARE = '0' then
				i := 0;
				RESET_TRIG_STATE <= RESETT;
				RESET_TRIG_COUNT <= '1';
			elsif falling_edge(xMCLK) and RESET_TRIG_FROM_SOFTWARE  = '1' then
				case RESET_TRIG_STATE is
					when RESETT =>
						i:=i+1;
						if i > 1 then
							i := 0;

							RESET_TRIG_STATE <= RELAXT;
						end if;
						
					when RELAXT =>
						RESET_TRIG_COUNT <= '0';

				end case;
			end if;
	end process;
	
SELF_TRIGGER_WRAPPER	:	psec4_SELFtrigger
port map(
			xTRIG_CLK					=> xTRIG_CLK,
			xMCLK							=> xMCLK,
			xCLR_ALL						=> xCLR_ALL,
			xDONE							=> xDONE,
			xSLOW_CLK					=> xSLOW_CLK,
			
			xSELF_TRIGGER				=> SELF_TRIGGER,
			
			xSELF_TRIG_CLEAR			=> SELF_TRIG_CLR or RESET_TRIG_FROM_SOFTWARE or reset_trig_from_scaler_mode,
			xSELF_TRIG_ENABLE			=> SELF_TRIG_EN, 
			xSELF_TRIG_MASK			=> SELF_TRIGGER_MASK,
	
			xSELF_TRIG_CLOCKED_OR 	=> SELF_TRIGGER_CLOCKED_OR,
			xSELF_TRIG_LATCHED_OR 	=> SELF_TRIGGER_LATCHED_OR,  
			xSELF_TRIG_BITSUM		 	=> SELF_TRIGGER_NO,
			xSELF_TRIG_CLOCKED		=> SELF_TRIGGER_CLOCKED,
			xSELF_TRIG_LATCHED		=> SELF_TRIG_LATCHED);

---end internal trigger---------------------
--------------------------------------------
end Behavioral;
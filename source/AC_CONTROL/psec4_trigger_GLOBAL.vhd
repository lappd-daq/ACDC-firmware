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
	type 	HANDLE_TRIG_TYPE	is (WAIT_FOR_COINCIDENCE, WAIT_FOR_SYSTEM, 
											SELF_START_ADC, SELF_RESET, SELF_DONE);
	signal	HANDLE_TRIG_STATE	:	HANDLE_TRIG_TYPE;
	
	type 	RESET_TRIG_TYPE	is (RESETT, RELAXT);
	signal	RESET_TRIG_STATE:	RESET_TRIG_TYPE;
	
	--type to generate scaler mode based of 1 Hz clock
	type COUNT_RATE_TYPE    is (SELF_COUNT, SELF_COUNT_LATCH, SELF_COUNT_RESET);
	signal	COUNT_RATE_OF_SELFTRIG :	COUNT_RATE_TYPE;
	signal   SCALER_MODE_STATE		  :   COUNT_RATE_TYPE;
	signal   SCALER_MODE_LATCH_STATE:   COUNT_RATE_TYPE;

	type REG_TRIG_BITS_STATE_TYPE is (TRIG1, TRIG2, TRIG3, TRIG4, DONE5);
	signal REG_TRIG_BITS_STATE : REG_TRIG_BITS_STATE_TYPE  ;
-------------------------------------------------------------------------------
	signal SELF_TRIG_EXT		:  std_logic;     --self trig needs to be clocked to sync across boards!!
	signal SELF_TRIG_EXT_HI	:	std_logic;		--clock in on rising edge
	signal SELF_TRIG_EXT_LO	:  std_logic;		--clock in on falling edge
	signal CC_TRIG				:	std_logic;		--trigger signal over LVDS
	signal CC_TRIG_START_ADC:  std_logic;
	signal DC_TRIG				: 	std_logic  := '0';		--trigger from AC/DC SMA input
	signal CLK_40				:  std_logic;
	
	signal SELF_TRIGGER   				: std_logic_vector (29 downto 0); 	-- self trigger bits
	signal SCALER_LATCH					: std_logic_vector (29 downto 0);	
	signal SELF_TRIGGER_LATCHED		: std_logic_vector (29 downto 0); 	-- latched self trigger bits
	signal SELF_TRIGGER_CLOCKED		: std_logic_vector (29 downto 0); 	-- latched self trigger bits

	signal SELF_TRIGGER_LATCHED_OR	: std_logic;
	signal SELF_TRIGGER_CLOCKED_OR	: std_logic;

	
	signal SELF_TRIGGER_MASK 			: std_logic_vector (29 downto 0); -- self trigger mask bits
	signal SELF_TRIGGER_NO_COINCIDNT : std_logic_vector (4 downto 0);  -- number of coincident triggers (target)
	signal SELF_TRIGGER_NO				: std_logic_vector (2 downto 0);  -- number of coincident triggers
	signal SELF_TRIGGER_OR				: std_logic;
	signal SELF_TRIGGER_START_ADC		: std_logic;
	
	signal SELF_COUNT_RATE				: rate_count_array;
	signal SELF_COUNT_RATE_LATCH		: rate_count_array;
	
	--rate count state-machine indicators:
	signal SELF_COUNT_sig				: std_logic;
	signal SELF_COUNT_LATCH_sig		: std_logic;
	signal SELF_COUNT_RESET_sig		: std_logic;
	
	signal RESET_TRIG_FROM_SOFTWARE	:	std_logic := '0';      -- trig clear signals
	signal RESET_TRIG_COUNT				:	std_logic := '1';      -- trig clear signals
	signal RESET_TRIG_FROM_FIRMWARE_FLAG :  std_logic;
	signal SELF_TRIG_CLR					:  std_logic;
	signal SELFTRIG_CLEAR            :  std_logic;
	signal reset_trig_from_scaler_mode: std_logic;
	
	signal SELF_WAIT_FOR_SYS_TRIG    : std_logic;
	signal SELF_TRIG_RATE_ONLY 		: std_logic;
	signal SELF_TRIG_EN					: std_logic;
	
	signal trig_latch1					: std_logic_vector (29 downto 0); 
	signal trig_latch2					: std_logic_vector (29 downto 0); 
	signal trig_latch3					: std_logic_vector (29 downto 0);
	signal trig_latch4					: std_logic_vector (29 downto 0); 

	signal COUNT_RATE						: std_logic;

	signal EVENT_CNT			:	std_logic_vector(31 downto 0);	
	
	signal BIN_COUNT_START 	: 	std_logic := '0';
	signal BIN_COUNT_START2 :  std_logic := '0';
	signal BIN_COUNT			:	std_logic_vector(3 downto 0) := "0000";
	signal BIN_COUNT_SAVE	:	std_logic_vector(3 downto 0) := "0000";
		
	signal BIN_COUNT2			:	std_logic_vector(3 downto 0) := "0000";
	signal BIN_COUNT_SAVE2  :	std_logic_vector(3 downto 0) := "0000";
	
	signal TRIG_VALID_HI						: std_logic_vector(2 downto 0) := (others=>'0'); -- transfer clock domain
	signal TRIG_VALID_LO						: std_logic_vector(2 downto 0) := (others=>'0'); -- transfer clock domain
	signal clock_dll_reset_hi		      : std_logic;--_vector(2 downto 0) := (others=>'0');
	signal clock_dll_reset_lo			   : std_logic;--_vector(2 downto 0) := (others=>'0');
	signal clock_dll_reset_lo_lo		   : std_logic;--_vector(2 downto 0) := (others=>'0');
	signal clock_dll_reset_hi_hi		   : std_logic;--_vector(2 downto 0) := (others=>'0');
	signal self_trig_ext_registered     : std_logic_vector(2 downto 0) := (others=>'0');
	signal clock_cc_trig_hi			      : std_logic;
	signal clock_cc_trig_lo			      : std_logic;
	signal clear_all_registered_hi      : std_logic_vector(2 downto 0) := (others=>'0'); -- transfer clock domain
	signal clear_all_registered_lo      : std_logic_vector(2 downto 0) := (others=>'0'); -- transfer clock domain
	signal clear_all_latch					: std_logic;

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
	SELF_TRIG_EXT  <= SELF_TRIG_EXT_HI or SELF_TRIG_EXT_LO;
	---------------------------------------------------------------
	--this is the PSEC4 combined trigger signal!!!!!!!!!!!!!!!!!!!!
	xTRIGGER_OUT	<= CC_TRIG or ((SELF_TRIG_EXT_HI or SELF_TRIG_EXT_LO) and SELF_TRIG_EN);
	---------------------------------------------------------------
	CLK_40			<= xMCLK;
	--
	xSTART_ADC <= CC_TRIG_START_ADC or SELF_TRIGGER_START_ADC;
	--
	SELF_TRIG_CLR <= xCLR_ALL or (not xDLL_RESET);
	SELFTRIG_CLEAR <= SELF_TRIG_CLR or RESET_TRIG_FROM_SOFTWARE or reset_trig_from_scaler_mode 
		or (SELF_TRIG_RATE_ONLY nor xTRIG_VALID) ;	
	
	xSELFTRIG_CLEAR <= SELFTRIG_CLEAR;
	--
	xSELF_TRIG_RATES <= SELF_COUNT_RATE_LATCH;
	--
----------------------------------------------------------
--packet-ize some meta-data
----------------------------------------------------------
xPSEC4_TRIGGER_INFO_1(0)(3 downto 0)  <= BIN_COUNT_SAVE;  --fine timestamp (rising)
xPSEC4_TRIGGER_INFO_1(0)(7 downto 4)  <= BIN_COUNT_SAVE2; --fine timestamp (falling)
xPSEC4_TRIGGER_INFO_1(0)(15 downto 8) <= (others=> '0');
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
----------------------------------------------------------
process(xMCLK, xDONE, xCLR_ALL, xCC_TRIG)
	begin
		if xDONE = '1' or xCLR_ALL = '1'  then
			CC_TRIG <= '0';
			CC_TRIG_START_ADC <= '0';
		elsif rising_edge(xCC_TRIG) then
			CC_TRIG <= '1';
			CC_TRIG_START_ADC <= '1';
		end if;
end process;
----------------------------------------------------------
--clock domain transfers
----------------------------------------------------------
----------------------------------------------------------	
--trigger 'binning' firmware
--poor man's TDC
----------------------------------------------------------
--fine 'binning' counter cycle:
rise_edge_bin:process(xTRIG_CLK, clock_dll_reset_hi)
begin
	if clock_dll_reset_hi = '0' then
		BIN_COUNT<= (others => '0');
	elsif rising_edge(xTRIG_CLK) and clock_dll_reset_hi = '1' then 
		BIN_COUNT <= BIN_COUNT2 + 1;	
	end if;
end process;
fall_edge_bin:process(xTRIG_CLK, clock_dll_reset_hi)
begin
	if clock_dll_reset_hi = '0' then
		BIN_COUNT2<= (others => '0');
	elsif falling_edge(xTRIG_CLK) and clock_dll_reset_hi = '1' then 
		BIN_COUNT2 <= BIN_COUNT2 + 1;	
	end if;
end process;
process(SELF_TRIG_EXT_HI)
begin
	if rising_edge(SELF_TRIG_EXT_HI) then
		BIN_COUNT_SAVE2 <= BIN_COUNT2;
		BIN_COUNT_SAVE  <= BIN_COUNT2;
	end if;
end process;
--end binning
process (xCLR_ALL, xTRIG_CLK )
begin
	if xCLR_ALL = '1' then
		clock_dll_reset_hi <= '0';
	elsif rising_edge(xTRIG_CLK) then
		clock_dll_reset_hi <= xDLL_RESET;
	end if;
end process;

--generic clock domain transfer for slower signals
process(xMCLK)
begin
	if rising_edge(xMCLK) then
		clear_all_registered_hi <= clear_all_registered_hi(1 downto 0)&xCLR_ALL;
	end if;
end process;
process(xMCLK)
begin
	if falling_edge(xMCLK) then
		self_trig_ext_registered <= self_trig_ext_registered(1 downto 0)&SELF_TRIG_EXT_HI;
		clear_all_registered_lo <= clear_all_registered_lo(1 downto 0)&xCLR_ALL;
	end if;
end process;
	
----------------------------------------------------------
---self triggering firmware:
----------------------------------------------------------
----------------------------------------------------------
---interpret self_trigger_settings
----------------------------------------------------------
SELF_TRIGGER_MASK       <= xSELF_TRIGGER_MASK;
SELF_TRIG_EN 				<= xSELF_TRIGGER_SETTING(0);
SELF_WAIT_FOR_SYS_TRIG 	<= xSELF_TRIGGER_SETTING(1);
SELF_TRIG_RATE_ONLY 		<= xSELF_TRIGGER_SETTING(2);
xRATE_ONLY 					<= SELF_TRIG_RATE_ONLY;
xSELF_TRIG_SIGN			<= xSELF_TRIGGER_SETTING(3);
----------------------------------------------------------
SELF_TRIGGER <= xSELFTRIG_4 & xSELFTRIG_3 & xSELFTRIG_2 & xSELFTRIG_1 & xSELFTRIG_0;
----------------------------------------------------------
--now, send in self trigger:	
----------------------------------------------------------
process( xTRIG_CLK, SELF_TRIGGER_LATCHED_OR,
			xCLR_ALL, xDONE, SELFTRIG_CLEAR, xTRIG_VALID)
begin	
	if xCLR_ALL = '1' or (xDONE = '1' and SELF_TRIG_EN = '0') 
		or SELFTRIG_CLEAR = '1' or SELF_TRIG_RATE_ONLY = '1' then
		--
		SELF_TRIG_EXT_HI <= '0';
		SELF_TRIG_EXT_LO <= '0';
		--
	--latch self-trigger signal from SELF_TRIGGER_WRAPPER or tag system trigger, depending on source
	elsif rising_edge(xTRIG_CLK) and ((SELF_TRIGGER_LATCHED_OR = '1' and xTRIG_VALID= '1') or CC_TRIG = '1') then
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
	if xCLR_ALL = '1' or xDONE = '1' or self_trig_ext_registered(2) = '0' or
		SELF_TRIG_RATE_ONLY = '1' then
		i := 0;
		SELF_TRIGGER_START_ADC <= '0';
		RESET_TRIG_FROM_FIRMWARE_FLAG <= '0';
		HANDLE_TRIG_STATE <= WAIT_FOR_COINCIDENCE;

	elsif rising_edge(CLK_40) then	
		case HANDLE_TRIG_STATE is
			
			when WAIT_FOR_COINCIDENCE =>
				--if SELF_TRIGGER_NO >= SELF_TRIGGER_NO_COINCIDNT then
				--	i := 0;
				if SELF_WAIT_FOR_SYS_TRIG = '1' and self_trig_ext_registered(2) = '1'  then
					HANDLE_TRIG_STATE <= WAIT_FOR_SYSTEM;
				elsif self_trig_ext_registered(2) = '1' and SELF_WAIT_FOR_SYS_TRIG = '0' then
					HANDLE_TRIG_STATE <= SELF_START_ADC;
				else
					HANDLE_TRIG_STATE <= WAIT_FOR_COINCIDENCE;
				end if;
				
			when WAIT_FOR_SYSTEM => 
				if CC_TRIG = '1' then
					i := 0;
					HANDLE_TRIG_STATE <= SELF_START_ADC;
				elsif i >= 3 then -- wait roughly 100 ns based of 320 MHz clock
					i := 0;
					HANDLE_TRIG_STATE <= SELF_RESET;
				else
					i := i + 1;
				end if;
				
			when SELF_START_ADC =>
				SELF_TRIGGER_START_ADC <= '1';
				---ends case
							
			when SELF_RESET =>
				if i > 2 then
					i := 0;
					HANDLE_TRIG_STATE <= SELF_DONE;
				else
					RESET_TRIG_FROM_FIRMWARE_FLAG <= '1';
					i := i + 1;
				end if;
				
			when SELF_DONE =>
				RESET_TRIG_FROM_FIRMWARE_FLAG <= '0';
				---ends case
			
		end case;
	end if;
end process;

----------------------------------------------------------	
--process to measure trigger rates ('scaler' mode)
process(xCLR_ALL, CLK_40, SELF_TRIG_RATE_ONLY, SELF_COUNT_sig, 
		SELF_COUNT_LATCH_sig)
variable i : integer range 100 downto -1  := 0;
begin
	if xCLR_ALL = '1' then
		i:=0;
		for ii in 29 downto 0 loop
			SELF_COUNT_RATE(ii)(15 downto 0) <= (others=>'0');
			SELF_COUNT_RATE_LATCH(ii)(15 downto 0) <= (others=>'0');
		end loop;
		SCALER_MODE_STATE <= SELF_COUNT;
		SCALER_MODE_LATCH_STATE <= SELF_COUNT;
		reset_trig_from_scaler_mode <= '0';
		
	-- 'counting mode':
 	elsif falling_edge(CLK_40) and SELF_COUNT_LATCH_sig = '0' and SELF_COUNT_sig = '1' then
		                          --SELF_COUNT_sig driven from process below w.r.t 1Hz slow counting clock
		SCALER_MODE_LATCH_STATE <= SELF_COUNT;

		case SCALER_MODE_STATE is
			when SELF_COUNT =>
				reset_trig_from_scaler_mode <= '0';
				--non-scaler mode: still count rates, wait for trigger signal
				if SELF_TRIG_RATE_ONLY = '0' and (CC_TRIG = '1' or SELF_TRIGGER_LATCHED_OR = '1') then
					SCALER_LATCH <= SELF_TRIGGER; --30 bit bus;
					SCALER_MODE_STATE <= SELF_COUNT_LATCH; 
				
				--scaler mode: wait 4 clock edges, and then look at all output bits
				elsif i > 3 and SELF_TRIG_RATE_ONLY = '1' then
					i:=0;
					SCALER_LATCH <= SELF_TRIGGER; --30 bit bus;
					SCALER_MODE_STATE <= SELF_COUNT_LATCH;
				elsif SELF_TRIG_RATE_ONLY = '1' then	
					i := i + 1;							
				end if;
			
			when SELF_COUNT_LATCH =>
				reset_trig_from_scaler_mode <= '0';
				--add up bits to rate counting array
				for ii in 29 downto 0 loop
					SELF_COUNT_RATE(ii)(15 downto 0) <= SELF_COUNT_RATE(ii)(15 downto 0) + 
					("00000000000000"&SCALER_LATCH(ii));
				end loop;
				case SELF_TRIG_RATE_ONLY is
					--non-scaler mode: go back to looking for trigger
					when '0' =>
						SCALER_MODE_STATE <= SELF_COUNT;
					--scaler mode: pulse a self-trig reset before going back to looking for trigger
					when '1' =>
						SCALER_MODE_STATE <= SELF_COUNT_RESET;
				end case;
			when SELF_COUNT_RESET =>
				reset_trig_from_scaler_mode <= '1';
				SCALER_MODE_STATE <= SELF_COUNT;
				
		end case;
	-- latch and reset rate counter mode:
	elsif falling_edge(CLK_40) and SELF_COUNT_LATCH_sig = '1' and SELF_COUNT_sig = '0' then
		SCALER_MODE_STATE <= SELF_COUNT;

		case SCALER_MODE_LATCH_STATE is
			when SELF_COUNT =>
				i:=0;
				SELF_COUNT_RATE_LATCH <= SELF_COUNT_RATE;
				SCALER_MODE_LATCH_STATE <= SELF_COUNT_LATCH;
			
			when SELF_COUNT_LATCH =>
				for ii in 29 downto 0 loop
					SELF_COUNT_RATE(ii)(15 downto 0) <= (others=>'0');
				end loop;
				SCALER_MODE_LATCH_STATE <= SELF_COUNT_RESET;
				
			when SELF_COUNT_RESET =>
				--nothing to do, wait until SELF_COUNT_sig is toggled hi, go back to SCALER_MODE_STATE
		end case;
	end if;
end process;	
--generate signals to toggle above process w.r.t. slow 1Hz clock
process(xCLR_ALL, COUNT_RATE, xSLOW_CLK, SELF_TRIGGER_LATCHED)
begin
	if xCLR_ALL = '1' or xDONE = '1' then 
		SELF_COUNT_LATCH_sig <= '0';
		SELF_COUNT_RESET_sig <= '0';
		SELF_COUNT_sig       <= '0';
		COUNT_RATE_OF_SELFTRIG <= SELF_COUNT;
	elsif rising_edge(xSLOW_CLK) then
		case COUNT_RATE_OF_SELFTRIG is
			when SELF_COUNT =>
				SELF_COUNT_sig       <= '1';
				SELF_COUNT_LATCH_sig <= '0';
				SELF_COUNT_RESET_sig <= '0';
				COUNT_RATE_OF_SELFTRIG <= SELF_COUNT_LATCH;
			when SELF_COUNT_LATCH =>
				SELF_COUNT_sig       <= '0';
				SELF_COUNT_LATCH_sig <= '1';
				SELF_COUNT_RESET_sig <= '0';
				COUNT_RATE_OF_SELFTRIG <= SELF_COUNT;
			when others=>
				SELF_COUNT_LATCH_sig <= '0';
				SELF_COUNT_RESET_sig <= '0';
				SELF_COUNT_sig       <= '0';
				--change 20-11-2014 only toggle between count and latch states
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
			elsif rising_edge(xMCLK) and (xRESET_TRIG_FLAG = '1' or RESET_TRIG_FROM_FIRMWARE_FLAG = '1') then
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
			xTRIG_CLK				=> xTRIG_CLK,
			xMCLK						=> xMCLK,
			xCLR_ALL					=> xCLR_ALL,
			xDONE						=> xDONE,
			xSLOW_CLK				=> xSLOW_CLK,
			
			xSELF_TRIGGER			=> SELF_TRIGGER,
			
			xSELF_TRIG_CLEAR		=> SELF_TRIG_CLR or RESET_TRIG_FROM_SOFTWARE,
			xSELF_TRIG_ENABLE		=> SELF_TRIG_EN, 
			xSELF_TRIG_MASK		=> SELF_TRIGGER_MASK,
	
			xSELF_TRIG_CLOCKED_OR => SELF_TRIGGER_CLOCKED_OR,
			xSELF_TRIG_LATCHED_OR => SELF_TRIGGER_LATCHED_OR,  
			xSELF_TRIG_BITSUM		 => SELF_TRIGGER_NO,
			xSELF_TRIG_CLOCKED	=> SELF_TRIGGER_CLOCKED,
			xSELF_TRIG_LATCHED	=> SELF_TRIGGER_LATCHED);

---end internal trigger---------------------
--------------------------------------------
end Behavioral;
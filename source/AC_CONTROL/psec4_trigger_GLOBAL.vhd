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
			
			xSELF_TRIGGER_MASK	: in 	std_logic_vector(11 downto 0);
			xSELF_TRIGGER_SETTING: in	std_logic_vector(11 downto 0); --open dataspace for config of this block

			xRESET_TRIG_FLAG		: in	std_logic;
			
			xDLL_RESET				: in	std_logic;
			xPLL_LOCK				: in	std_logic;
			
			xTRIGGER_OUT			: out	std_logic;
			xSTART_ADC				: out std_logic;

			xSELFTRIG_CLEAR		: out	std_logic;
			
			xRATE_ONLY           : out std_logic;
				
			xEVENT_CNT				: out std_logic_vector(EVT_CNT_SIZE-1 downto 0);
			xSAMPLE_BIN				: out	std_logic_vector(3 downto 0);
			xSELF_TRIG_RATES		: out rate_count_array;
			xSELF_TRIG_SIGN		: out std_logic);
	end psec4_trigger_GLOBAL;

architecture Behavioral of psec4_trigger_GLOBAL is
-------------------------------------------------------------------------------
-- SIGNALS 
-------------------------------------------------------------------------------	
	type 	HANDLE_TRIG_TYPE	is (WAIT_FOR_COINCIDENCE, WAIT_FOR_SYSTEM, SELF_RATE_ONLY,
											SELF_START_ADC, SELF_RESET, SELF_DONE);
	signal	HANDLE_TRIG_STATE	:	HANDLE_TRIG_TYPE;
	
	type 	RESET_TRIG_TYPE	is (RESETT, RELAXT);
	signal	RESET_TRIG_STATE:	RESET_TRIG_TYPE;
	
	type COUNT_RATE_TYPE    is (SELF_COUNT, SELF_COUNT_LATCH, SELF_COUNT_RESET);
	signal	COUNT_RATE_OF_SELFTRIG :	COUNT_RATE_TYPE;

-------------------------------------------------------------------------------
	signal EXT_TRIG			:	std_logic;   				--trigger signal output to firmware
	signal SELF_TRIG_EXT		:  std_logic;
	signal TRIG_CHANNEL		: 	std_logic_vector(5 downto 0);
	signal CC_TRIG				:	std_logic;		--trigger signal over LVDS
	signal CC_TRIG_START_ADC:  std_logic;
	signal DC_TRIG				: 	std_logic  := '0';		--trigger from AC/DC SMA input
	signal SELF_TRIG_OR_0	:	std_logic;
	signal SELF_TRIG_OR_1	:	std_logic;
	signal SELF_TRIG_OR_2	:	std_logic;
	signal SELF_TRIG_OR_3	:	std_logic;
	signal SELF_TRIG_OR_4	:	std_logic;	
	signal TRIG_CLEAR			:	std_logic := '0';
	
	signal SELF_TRIGGER   				: std_logic_vector (29 downto 0); 	-- self trigger bits
	signal SELF_TRIGGER_LATCHED		: std_logic_vector (29 downto 0); 	-- latched self trigger bits
	signal SELF_TRIGGER_LATCHED_OR	: std_logic;
	signal EXT_TRIG_SELF					: std_logic;								-- self trigger out
	
	signal SELF_TRIGGER_MASK 			: std_logic_vector (29 downto 0); -- self trigger mask bits
	signal SELF_TRIGGER_NO_COINCIDNT : std_logic_vector (4 downto 0);  -- number of coincident triggers (target)
	signal SELF_TRIGGER_NO				: std_logic_vector (2 downto 0);  -- number of coincident triggers
	signal SELF_TRIGGER_OR				: std_logic;
	signal SELF_TRIGGER_START_ADC		: std_logic;
	
	signal SELF_COUNT_RATE				: rate_count_array;
	signal SELF_COUNT_RATE_LATCH		: rate_count_array;
	signal SELF_COUNT_sig				: std_logic;
	signal SELF_COUNT_LATCH_sig		: std_logic;
	signal SELF_COUNT_RESET_sig		: std_logic;
	
	
	signal RESET_TRIG_FROM_SOFTWARE	:	std_logic := '0';      -- trig clear signals
	signal RESET_TRIG_COUNT				:	std_logic := '1';      -- trig clear signals
	signal RESET_TRIG_FROM_FIRMWARE_FLAG :  std_logic;
	signal SELF_TRIG_CLR					:  std_logic;
	
	signal SELF_WAIT_FOR_SYS_TRIG    : std_logic;
	signal SELF_TRIG_RATE_ONLY 		: std_logic;
	signal SELF_TRIG_EN					: std_logic;
	
	signal COUNT_RATE						: std_logic;
	
	signal EVENT_CNT			:	std_logic_vector(EVT_CNT_SIZE-1 downto 0);	
	signal BIN_COUNT			:	std_logic_vector(3 downto 0) := "0000";
	signal MASK_FLAG			:	std_logic := '0';
	signal BIN_COUNT_START 	: 	std_logic := '0';
	signal BIN_COUNT_SAVE	:	std_logic_vector(3 downto 0);

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
			
			xSELF_TRIG_OR			: out std_logic;
			xSELF_TRIG_LATCHED_OR: out	std_logic;
			xSELF_TRIG_BITSUM		: out std_logic_vector(2 downto 0);
			xSELF_TRIG_LATCHED	: out std_logic_vector(29 downto 0));
end component;
-------------------------------------------------------------------------------  
begin  -- Behavioral
-------------------------------------------------------------------------------	
	xEVENT_CNT 		<= EVENT_CNT;
	xSAMPLE_BIN		<= "0" & BIN_COUNT_SAVE(2 downto 0);
	
	EXT_TRIG			<= CC_TRIG or (SELF_TRIG_EXT and SELF_TRIG_EN);
	xTRIGGER_OUT	<= EXT_TRIG;
	
	xSTART_ADC <= CC_TRIG_START_ADC or SELF_TRIGGER_START_ADC;
	
	xSELFTRIG_CLEAR <= SELF_TRIG_CLR or RESET_TRIG_FROM_SOFTWARE;	
	
	xSELF_TRIG_RATES <= SELF_COUNT_RATE_LATCH;
	
----------------------------------------------------------	
--implement crude event counter
process(xCLR_ALL,EXT_TRIG) 
begin
	if xCLR_ALL = '1' then
		EVENT_CNT <= (others => '0');
	elsif rising_edge(EXT_TRIG) then
		EVENT_CNT <= EVENT_CNT + 1;
	end if;
end process;

----------------------------------------------------------
--trigger 'binning' firmware-----
--for self-triggering option only --
----------------------------------------------------------
process(xMCLK, xCLR_ALL, xPLL_LOCK)
begin	
	if xCLR_ALL = '1' or xPLL_LOCK = '0' then
		BIN_COUNT_START <= '0';
	elsif rising_edge(xMCLK) and xPLL_LOCK = '1' then
		BIN_COUNT_START <= '1';
	end if;
end process;
--fine 'binning' counter cycle:
process(xCLR_ALL, xTRIG_CLK, xDLL_RESET, BIN_COUNT_START)
begin
	if xDLL_RESET = '0' or BIN_COUNT_START = '0' then
		BIN_COUNT <= (others => '0');
	elsif rising_edge(xTRIG_CLK) and xDLL_RESET = '1' and BIN_COUNT_START = '1' then
		BIN_COUNT <= BIN_COUNT + 1;
	end if;
end process;
--
process(xCLR_ALL, xDONE, EXT_TRIG)
begin
	if xCLR_ALL = '1' or xDONE = '1' then
		BIN_COUNT_SAVE <= (others => '0');
	elsif rising_edge(SELF_TRIG_EXT) then
		BIN_COUNT_SAVE <= BIN_COUNT;
	end if;
end process;
-----
--end binning
----------------------------------------------------------

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
---self triggering firmware:
----------------------------------------------------------
process(xSELF_TRIGGER_MASK)
begin
case xSELF_TRIGGER_MASK is
	when x"000" =>
		SELF_TRIGGER_MASK <= (others => '0');
		SELF_TRIGGER_NO_COINCIDNT <= "11111";
	when x"001" => 
		SELF_TRIGGER_MASK <= "000000000000000000000000000001";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"002" => 
		SELF_TRIGGER_MASK <= "000000000000000000000000000010";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"003" => 
		SELF_TRIGGER_MASK <= "000000000000000000000000000100";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"004" => 
		SELF_TRIGGER_MASK <= "000000000000000000000000001000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"005" => 
		SELF_TRIGGER_MASK <= "000000000000000000000000010000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"006" => 
		SELF_TRIGGER_MASK <= "000000000000000000000000100000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"007" => 
		SELF_TRIGGER_MASK <= "000000000000000000000001000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"008" => 
		SELF_TRIGGER_MASK <= "000000000000000000000010000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"009" => 
		SELF_TRIGGER_MASK <= "000000000000000000000100000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"00A" => 
		SELF_TRIGGER_MASK <= "000000000000000000001000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"00B" => 
		SELF_TRIGGER_MASK <= "000000000000000000010000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"00C" => 
		SELF_TRIGGER_MASK <= "000000000000000000100000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"00D" => 
		SELF_TRIGGER_MASK <= "000000000000000001000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"00E" => 
		SELF_TRIGGER_MASK <= "000000000000000010000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"00F" => 
		SELF_TRIGGER_MASK <= "000000000000000100000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"010" => 
		SELF_TRIGGER_MASK <= "000000000000001000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"011" => 
		SELF_TRIGGER_MASK <= "000000000000010000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"012" => 
		SELF_TRIGGER_MASK <= "000000000000100000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"013" => 
		SELF_TRIGGER_MASK <= "000000000001000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"014" => 
		SELF_TRIGGER_MASK <= "000000000010000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"015" => 
		SELF_TRIGGER_MASK <= "000000000100000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"016" => 
		SELF_TRIGGER_MASK <= "000000001000000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"017" => 
		SELF_TRIGGER_MASK <= "000000010000000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"018" => 
		SELF_TRIGGER_MASK <= "000000100000000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"019" => 
		SELF_TRIGGER_MASK <= "000001000000000000000000000000";		
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"01A" => 
		SELF_TRIGGER_MASK <= "000010000000000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"01B" => 
		SELF_TRIGGER_MASK <= "000100000000000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"01C" => 
		SELF_TRIGGER_MASK <= "001000000000000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"01D" => 
		SELF_TRIGGER_MASK <= "010000000000000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"01E" => --30
		SELF_TRIGGER_MASK <= "100000000000000000000000000000";
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"01F" => --31
		SELF_TRIGGER_MASK <= (others => '1');
		SELF_TRIGGER_NO_COINCIDNT <= "00001";
	when x"020" => --32
		SELF_TRIGGER_MASK <= (others => '1');
		SELF_TRIGGER_NO_COINCIDNT <= "00010";		
	when x"021" => --33
		SELF_TRIGGER_MASK <= (others => '1');	
		SELF_TRIGGER_NO_COINCIDNT <= "00011";		
	when others=>
		SELF_TRIGGER_MASK <= (others => '0');
		SELF_TRIGGER_NO_COINCIDNT <= "00001";		
	end case;
end process;

----------------------------------------------------------
---interpret self_trigger_settings
----------------------------------------------------------
SELF_TRIG_EN <= xSELF_TRIGGER_SETTING(0);
SELF_WAIT_FOR_SYS_TRIG <= xSELF_TRIGGER_SETTING(1);
SELF_TRIG_RATE_ONLY <= xSELF_TRIGGER_SETTING(2);
xRATE_ONLY <= SELF_TRIG_RATE_ONLY;
xSELF_TRIG_SIGN	<= xSELF_TRIGGER_SETTING(3);
----------------------------------------------------------

SELF_TRIGGER <= xSELFTRIG_4 & xSELFTRIG_3 & xSELFTRIG_2 & xSELFTRIG_1 & xSELFTRIG_0;
	
----------------------------------------------------------
--now, send in self trigger:	
----------------------------------------------------------
process( SELF_TRIGGER_LATCHED,
			SELF_TRIG_EN, xCLR_ALL, xDONE, SELF_TRIG_CLR)
begin	
	if xCLR_ALL = '1'  or xDONE = '1' or SELF_TRIG_EN = '0' or SELF_TRIG_CLR = '1' 
		or RESET_TRIG_FROM_SOFTWARE = '1' then
		--
		SELF_TRIG_EXT <= '0';
		--
	--elsif rising_edge(SELF_TRIGGER_OR) then
	--elsif rising_edge(xTRIG_CLK) and SELF_TRIGGER_OR = '1' then
	--elsif (SELF_TRIGGER_NO >= 1) then
		--						
	--	SELF_TRIG_EXT <= 	'1';     
	elsif SELF_TRIGGER_LATCHED_OR = '1' then
		--						
		SELF_TRIG_EXT <= 	'1';    
	
	end if;
end process;
----------------------------------------------------------
--process to determine whether to start ADC or 
--release trigger signal
----------------------------------------------------------
process(xTRIG_CLK, xCLR_ALL, xDONE)
variable i : integer range 100 downto -1 := 0;
begin
	if xCLR_ALL = '1' or xDONE = '1' or SELF_TRIG_EXT = '0' then
		i := 0;
		SELF_TRIGGER_START_ADC <= '0';
		RESET_TRIG_FROM_FIRMWARE_FLAG <= '0';
		COUNT_RATE <= '0';
		HANDLE_TRIG_STATE <= WAIT_FOR_COINCIDENCE;

	elsif rising_edge(xTRIG_CLK) then	
		case HANDLE_TRIG_STATE is
			
			when WAIT_FOR_COINCIDENCE =>
				--if SELF_TRIGGER_NO >= SELF_TRIGGER_NO_COINCIDNT then
				--	i := 0;
				if SELF_WAIT_FOR_SYS_TRIG = '1' and SELF_TRIG_EXT = '1'  then
					HANDLE_TRIG_STATE <= WAIT_FOR_SYSTEM;
				elsif SELF_TRIG_RATE_ONLY = '1' and SELF_TRIG_EXT = '1'then
					HANDLE_TRIG_STATE <= SELF_RATE_ONLY;
				else
					HANDLE_TRIG_STATE <= SELF_START_ADC;
				--end if;
				--elsif i >= 6 then
				--	i := 0;
				--	HANDLE_TRIG_STATE <= SELF_RESET;
				--else
				--	i := i + 1;
				end if;
				
			when WAIT_FOR_SYSTEM => 
				if CC_TRIG = '1' then
					i := 0;
					HANDLE_TRIG_STATE <= SELF_START_ADC;
				elsif i >= 32 then -- wait roughly 100 ns based of 320 MHz clock
					i := 0;
					HANDLE_TRIG_STATE <= SELF_RESET;
				else
					i := i + 1;
				end if;
				
			when SELF_START_ADC =>
				SELF_TRIGGER_START_ADC <= '1';
				---ends case
				
			when SELF_RATE_ONLY =>
				if i >= 3 then
					i := 0;
					HANDLE_TRIG_STATE <= SELF_RESET;
				else
					i := i + 1;
					COUNT_RATE <= '1';
				end if;
				
			when SELF_RESET =>
				if i >= 10 then
					i := 0;
					HANDLE_TRIG_STATE <= SELF_DONE;
				else
					RESET_TRIG_FROM_FIRMWARE_FLAG <= '1';
					i := i + 1;
				end if;
				
			when SELF_DONE =>
				COUNT_RATE <= '0';
				RESET_TRIG_FROM_FIRMWARE_FLAG <= '0';
				---ends case
			
		end case;
	end if;
end process;

----------------------------------------------------------	
--process to measure trigger rates ('scaler' mode)
process(xCLR_ALL, COUNT_RATE, SELF_COUNT_sig, 
		SELF_COUNT_LATCH_sig, SELF_COUNT_RESET_sig, 
		SELF_TRIGGER_LATCHED)
begin
	if xCLR_ALL = '1' or SELF_TRIG_RATE_ONLY = '0' then
		for ii in 29 downto 0 loop
			SELF_COUNT_RATE(ii)(15 downto 0) <= (others=>'0');
			SELF_COUNT_RATE_LATCH(ii)(15 downto 0) <= (others=>'0');
		end loop;
	elsif SELF_COUNT_sig = '1' then
		if rising_edge(COUNT_RATE) then 
			for ii in 29 downto 0 loop
				SELF_COUNT_RATE(ii)(15 downto 0) <= SELF_COUNT_RATE(ii)(15 downto 0) + ("00000000000000"&SELF_TRIGGER_LATCHED(ii));
			end loop;
		end if;
	
	elsif (SELF_COUNT_sig = '0' and SELF_COUNT_LATCH_sig = '1' 
		and SELF_COUNT_RESET_sig = '0') then
		
		SELF_COUNT_RATE_LATCH <= SELF_COUNT_RATE;
	
	elsif SELF_COUNT_sig = '0' and SELF_COUNT_LATCH_sig = '0' 
			and SELF_COUNT_RESET_sig = '1' then
		
			for ii in 29 downto 0 loop
				SELF_COUNT_RATE(ii)(15 downto 0) <= (others=>'0');
			end loop;
	end if;
end process;

--generate signals to toggle above process w.r.t. slow 1Hz clock
process(xCLR_ALL, COUNT_RATE, xSLOW_CLK, SELF_TRIGGER_LATCHED)
begin
	if xCLR_ALL = '1' or xDONE = '1' or SELF_TRIG_RATE_ONLY = '0' then 
		SELF_COUNT_LATCH_sig <= '0';
		SELF_COUNT_RESET_sig <= '0';
		SELF_COUNT_sig       <= '0';
		COUNT_RATE_OF_SELFTRIG <= SELF_COUNT;
	elsif rising_edge(xSLOW_CLK) and SELF_TRIG_RATE_ONLY = '1' then
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
				COUNT_RATE_OF_SELFTRIG <= SELF_COUNT_RESET;
			when SELF_COUNT_RESET =>
				SELF_COUNT_sig       <= '0';
				SELF_COUNT_LATCH_sig <= '0';
				SELF_COUNT_RESET_sig <= '1';
				COUNT_RATE_OF_SELFTRIG <= SELF_COUNT;
		end case;
	end if;
end process;
----------------------------------------------------------

--clearing trigger
process(xCLR_ALL, xDONE, SELF_TRIG_EXT )

begin 
	if xCLR_ALL = '1'  --or xDONE = '1' 
		or xDLL_RESET = '0' then
		SELF_TRIG_CLR <= '1';
	
	elsif xCLR_ALL = '0'  --and xDONE = '0' 
			and xDLL_RESET = '1' then
		SELF_TRIG_CLR <= '0';		
	end if;
end process;
							
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
						if i > 10 then
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
			
			xSELF_TRIG_OR			 => open,
			xSELF_TRIG_LATCHED_OR => SELF_TRIGGER_LATCHED_OR,
			xSELF_TRIG_BITSUM		 => SELF_TRIGGER_NO,
			xSELF_TRIG_LATCHED	 => SELF_TRIGGER_LATCHED);

---end internal trigger---------------------
--------------------------------------------
end Behavioral;
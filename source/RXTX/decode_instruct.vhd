--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	decode_instruct
-- author		: 	ejo
-- date			: 	6/2012
-- description	:  INSTRUCTIONS
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.Definition_Pool.all;

entity decode_instruct is
	port(
		xCLR_ALL				:		in 	std_logic;
		xINSTRUCT_FLAG		:		in		std_logic;
		xCLK_40MHz			:		in		std_logic;
		xINSTRUCT_WORD		:		in		std_logic_vector(31 downto 0);
		xALIGN_SUCCESS		:		in		std_logic;
		xTRIGGER				: 		in		std_logic;
		xPLL_LOCK			:     in    std_logic;
		
		xALIGN_ACTIVE     :     in		std_logic;
		xTRIG_FROM_SYS    :		in		std_logic;
		
		xADC_WAS_INIT		: 		in		std_logic;
		
		xRESET_DLL_FLAG	:		out	std_logic_vector(4 downto 0);
		xSET_TRIG_THRESH	:		out	Word_array;
		xSET_VBIAS			:		out	Word_array;
		xADJUST_RO_TARGET :		out	Word_array;
		xOPEN					:		out	std_logic_vector(11 downto 0);
		xRESET_SELF_TRIG	:		out	std_logic;
		xSELF_TRIG_MASK	:		out	std_logic_vector(29 downto 0);
		xSET_PSEC_MASK		:		out	std_logic_vector(4 downto 0);
		xINSTRUCT_BUSY		: 		out	std_logic;
		xFROM_SYSTEM_DONE	: 		out	std_logic;
		xENABLE_LED			:		out	std_logic;
		xENABLE_CAL_SWITCH:		out   std_logic_vector(14 downto 0);
		xSYSTEM_CLOCK_COUNTER:  out	Word_array;
		xSYSTEM_INSTRUCTION	:	out	Word_array;
		xSET_DLL_VDD			:	out	Word_array;
		xGLOBAL_RESET			: 	out	std_logic;
		xTRIG_VALID				:  out   std_logic;
		xSELF_TRIG_SETTINGS_0:	out	std_logic_vector(10 downto 0);
		xSELF_TRIG_SETTINGS_1:	out	std_logic_vector(10 downto 0);
		xEVENT_AND_TIME_RESET:	out	std_logic;
		xPULL_RAM_AND_META	:  out	std_logic;
		xPLL_SAMPLE_MODE		:  out 	std_logic_vector(1 downto 0));
end decode_instruct;

architecture Behavioral of decode_instruct is
	type GET_INSTRUCTION_STATE_TYPE is (WAIT_FOR_INSTRUCT, PARSE_INSTRUCT, WAITING, TARGET, DELAY);
	signal GET_INSTRUCTION_STATE	:		GET_INSTRUCTION_STATE_TYPE;
	
		signal INSTRUCT_VALUE		:		std_logic_vector(11 downto 0);
		signal INSTRUCT_PSEC_MASK	:		std_logic_vector(4 downto 0);
		signal INSTRUCT_CHAN_MASK	:		std_logic_vector(5 downto 0);
		signal INSTRUCTION			:		std_logic_vector(3 downto 0);
		signal INSTRUCTION_OPT		:		std_logic_vector(3 downto 0);

		signal RESET_DLL_FLAG		:		std_logic_vector(4 downto 0);
		signal SET_TRIG_THRESH		:		Word_array;
		signal SET_VBIAS				:		Word_array;
		signal ADJUST_RO_TARGET 	:		Word_array;
		signal SET_DLL_VDD			:		Word_array;
		signal SELF_TRIG_SETTINGS_0	:		std_logic_vector(10 downto 0);
		signal SELF_TRIG_SETTINGS_1	:		std_logic_vector(10 downto 0);
		signal RESET_SELF_TRIG		:		std_logic;
		signal SELF_TRIG_MASK		:		std_logic_vector(29 downto 0);
		signal SET_PSEC_MASK			:		std_logic_vector(4 downto 0);
		signal INSTRUCT_BUSY			:		std_logic;
		signal CC_FIFO_STATUS		:		std_logic_vector(4 downto 0);
		signal ENABLE_LED				:		std_logic;
		signal ENABLE_CAL_SWITCH	:		std_logic_vector(14 downto 0);
		signal SYSTEM_CLOCK_COUNTER:		std_logic_vector(47 downto 0);
		signal LATCHED_SYSTEM_CLOCK:		std_logic_vector(47 downto 0);
		signal LATCHED_DIGITIZED_SYSTEM_CLOCK:		std_logic_vector(47 downto 0);
		signal LAST_INSTRUCTION		:		std_logic_vector(31 downto 0);
		signal LAST_LAST_INSTRUCTION:		std_logic_vector(31 downto 0);
		signal EVENT_COUNT			:		std_logic_vector(31 downto 0);
		signal DIGITIZED_EVENT_COUNT:		std_logic_vector(31 downto 0);
		signal LATCHED_TIME_FROM_TRIG_VALID_TO_EVENT : std_logic_vector(15 downto 0);
		signal TIME_FROM_TRIG_VALID_TO_EVENT 			: std_logic_vector(15 downto 0);
		signal GLOBAL_RESET			: 		std_logic;
		signal TRIG_VALID				: 		std_logic;
		signal EVENT_AND_TIME_RESET: 		std_logic;
		signal TRIGGER					:     std_logic;
		signal TRIGGER_DIG			:     std_logic;
		signal ASYNCH_RESET			:		std_logic;
		signal CC_EVENT_RESET		: 		std_logic;
		signal PULL_META_AND_DATA_FROM_RAM  : std_logic;
		signal PLL_SAMPLE_MODE		:  std_logic_vector(1 downto 0) := "00";
		
		
begin

		xRESET_DLL_FLAG				<= RESET_DLL_FLAG;
		xSET_TRIG_THRESH				<= SET_TRIG_THRESH;
		xSET_VBIAS						<= SET_VBIAS;
		xSET_DLL_VDD 					<= SET_DLL_VDD;
		xADJUST_RO_TARGET 			<= ADJUST_RO_TARGET;
		xRESET_SELF_TRIG				<= RESET_SELF_TRIG;
		xSET_PSEC_MASK	   			<= SET_PSEC_MASK;
		xINSTRUCT_BUSY					<= INSTRUCT_BUSY;
		xENABLE_LED 					<= ENABLE_LED;
		xENABLE_CAL_SWITCH			<= ENABLE_CAL_SWITCH;
		xSELF_TRIG_SETTINGS_0		<= SELF_TRIG_SETTINGS_0;
		xSELF_TRIG_SETTINGS_1		<= SELF_TRIG_SETTINGS_1;
		xSELF_TRIG_MASK				<= SELF_TRIG_MASK;	
		xSYSTEM_CLOCK_COUNTER(0) 	<= LATCHED_SYSTEM_CLOCK(15 downto 0);
		xSYSTEM_CLOCK_COUNTER(1) 	<= LATCHED_SYSTEM_CLOCK(31 downto 16);
		xSYSTEM_CLOCK_COUNTER(2) 	<= LATCHED_SYSTEM_CLOCK(47 downto 32);
		xSYSTEM_CLOCK_COUNTER(3) 	<= EVENT_COUNT(15 downto 0);
		xSYSTEM_CLOCK_COUNTER(4) 	<= EVENT_COUNT(31 downto 16);
		--xSYSTEM_INSTRUCTION(0) 		<= LAST_INSTRUCTION(15 downto 0);
		--xSYSTEM_INSTRUCTION(1) 		<= LAST_INSTRUCTION(31 downto 16);
		--xSYSTEM_INSTRUCTION(2) 		<= LAST_LAST_INSTRUCTION(15 downto 0);
		--xSYSTEM_INSTRUCTION(3) 		<= LAST_LAST_INSTRUCTION(31 downto 16);
		--xSYSTEM_INSTRUCTION(4) 		<= (others => '0');
		xSYSTEM_INSTRUCTION(0) 		<= LATCHED_DIGITIZED_SYSTEM_CLOCK(15 downto 0);
		xSYSTEM_INSTRUCTION(1) 		<= LATCHED_DIGITIZED_SYSTEM_CLOCK(31 downto 16);
		xSYSTEM_INSTRUCTION(2) 		<= LATCHED_TIME_FROM_TRIG_VALID_TO_EVENT(7 downto 0) & LATCHED_DIGITIZED_SYSTEM_CLOCK(39 downto 32);
		xSYSTEM_INSTRUCTION(3) 		<= DIGITIZED_EVENT_COUNT(15 downto 0);
		xSYSTEM_INSTRUCTION(4) 		<= DIGITIZED_EVENT_COUNT(31 downto 16);
		ASYNCH_RESET					<= xALIGN_ACTIVE and xTRIG_FROM_SYS; --hard reset
		xGLOBAL_RESET					<= GLOBAL_RESET or ASYNCH_RESET ;
		xTRIG_VALID  					<= TRIG_VALID;
		xFROM_SYSTEM_DONE				<=	CC_EVENT_RESET;
		xEVENT_AND_TIME_RESET		<=	EVENT_AND_TIME_RESET;
		xPULL_RAM_AND_META			<= PULL_META_AND_DATA_FROM_RAM;
		xPLL_SAMPLE_MODE				<= PLL_SAMPLE_MODE;
		
--driver for 48 bit system clock/timestamp mangement
process(xCLR_ALL, xCLK_40MHz, RESET_DLL_FLAG)
begin
	if xCLR_ALL = '1' or RESET_DLL_FLAG(0) = '1' or xPLL_LOCK = '0' or EVENT_AND_TIME_RESET = '1' then
		SYSTEM_CLOCK_COUNTER <= (others => '0');
	elsif rising_edge(xCLK_40MHz) then
		SYSTEM_CLOCK_COUNTER <= SYSTEM_CLOCK_COUNTER + 1;
	end if;
end process;
process(xCLK_40MHz)
begin
	if falling_edge(xCLK_40MHz) then
		TRIGGER <= xTRIGGER;
	end if;
end process;
process(xCLK_40MHz)
begin
	if falling_edge(xCLK_40MHz)  then
		TRIGGER_DIG <= xADC_WAS_INIT;
	end if;
end process;
process(xCLR_ALL,xTRIGGER)
begin
	if xCLR_ALL = '1' or RESET_DLL_FLAG(0) = '1' or xPLL_LOCK = '0' or EVENT_AND_TIME_RESET = '1' then
		LATCHED_SYSTEM_CLOCK <= (others => '0');
		EVENT_COUNT <= (others => '0');
	elsif rising_edge(TRIGGER) then	
		LATCHED_SYSTEM_CLOCK <= SYSTEM_CLOCK_COUNTER;
		EVENT_COUNT <= EVENT_COUNT + 1;
	end if;
end process;
process(xCLR_ALL,xTRIGGER)
begin
	if xCLR_ALL = '1' or RESET_DLL_FLAG(0) = '1' or xPLL_LOCK = '0' or EVENT_AND_TIME_RESET = '1' then
		LATCHED_DIGITIZED_SYSTEM_CLOCK <= (others => '0');
		DIGITIZED_EVENT_COUNT <= (others => '0');
		LATCHED_TIME_FROM_TRIG_VALID_TO_EVENT <= (others => '0');
	elsif rising_edge(TRIGGER_DIG) then	
		LATCHED_DIGITIZED_SYSTEM_CLOCK <= SYSTEM_CLOCK_COUNTER;
		DIGITIZED_EVENT_COUNT <= DIGITIZED_EVENT_COUNT + 1;
		LATCHED_TIME_FROM_TRIG_VALID_TO_EVENT <= TIME_FROM_TRIG_VALID_TO_EVENT;
	end if;
end process;
process(xCLR_ALL, xCLK_40MHz)
begin
	if xCLR_ALL = '1' or RESET_DLL_FLAG(0) = '1' or xPLL_LOCK = '0' or EVENT_AND_TIME_RESET = '1' or TRIG_VALID = '0' then
		TIME_FROM_TRIG_VALID_TO_EVENT <= (others=>'0');
	elsif rising_edge(xCLK_40MHz) and TRIG_VALID = '1' then
		TIME_FROM_TRIG_VALID_TO_EVENT <= TIME_FROM_TRIG_VALID_TO_EVENT + 1;
	end if;
end process;
		
process(xCLR_ALL, xCLK_40MHz, xINSTRUCT_FLAG)
variable i : integer range 100 downto 0;
begin
	if xCLR_ALL = '1' then  --set default start-up values...
		SET_TRIG_THRESH(0)<= x"0000";
		SET_TRIG_THRESH(1)<= x"0000";
		SET_TRIG_THRESH(2)<= x"0000";
		SET_TRIG_THRESH(3)<= x"0000";
		SET_TRIG_THRESH(4)<= x"0000";
		SET_VBIAS(0)		<= x"0800";
		SET_VBIAS(1)		<= x"0800";
		SET_VBIAS(2)		<= x"0800";
		SET_VBIAS(3)		<= x"0800";
		SET_VBIAS(4)		<= x"0800";
		SET_DLL_VDD(0)		<= x"0CFF"; --x"FFFF";
		SET_DLL_VDD(1)		<= x"0CFF"; --x"FFFF";
		SET_DLL_VDD(2)		<= x"0CFF"; --x"FFFF";
		SET_DLL_VDD(3)		<= x"0CFF"; --x"FFFF";
		SET_DLL_VDD(4)		<= x"0CFF"; --x"FFFF";
		ADJUST_RO_TARGET(0)	<= RO1;
		ADJUST_RO_TARGET(1)	<= RO2;
		ADJUST_RO_TARGET(2)	<= RO3;		
		ADJUST_RO_TARGET(3)	<= RO4;
		ADJUST_RO_TARGET(4)	<= RO5;
		SELF_TRIG_MASK			<=	(others=>'0');
		SELF_TRIG_SETTINGS_0	<=	"00000000000";
		SELF_TRIG_SETTINGS_1	<=	"00000000000";
		RESET_DLL_FLAG		<= "00000";
		RESET_SELF_TRIG	<= '0';
		GLOBAL_RESET      <= '0';
		ENABLE_LED 			<= '1';
		EVENT_AND_TIME_RESET <= '0';
		TRIG_VALID			<= '0';
		ENABLE_CAL_SWITCH <= (others => '0'); 
		SET_PSEC_MASK     <= "11111";
		CC_EVENT_RESET		<= '0';
		PULL_META_AND_DATA_FROM_RAM <= '0';
		INSTRUCT_VALUE		<= (others=>'0');
		INSTRUCT_PSEC_MASK<= (others=>'0');
		INSTRUCT_CHAN_MASK<= (others=>'1');
		INSTRUCTION			<= (others=>'0');
		INSTRUCTION_OPT	<= (others=>'0');
		LAST_INSTRUCTION  <= (others=>'0');
		INSTRUCT_BUSY		<= '0';
		i := 0;
		GET_INSTRUCTION_STATE <= WAIT_FOR_INSTRUCT;
	
	elsif falling_edge(xCLK_40MHz) and xALIGN_SUCCESS = '1' then
		case GET_INSTRUCTION_STATE is
		
			when WAIT_FOR_INSTRUCT =>
				i:=0;
				RESET_DLL_FLAG		<= "00000";
				RESET_SELF_TRIG	<= '0'; 
				INSTRUCT_BUSY     <= '0';
				INSTRUCT_PSEC_MASK<= (others=>'0');
				GLOBAL_RESET   <= '0';
				EVENT_AND_TIME_RESET <= '0';
				CC_EVENT_RESET		<= '0';
				PULL_META_AND_DATA_FROM_RAM <= '0';

				if xINSTRUCT_FLAG = '1' then
					INSTRUCT_BUSY			 <= '1';
					GET_INSTRUCTION_STATE <= PARSE_INSTRUCT;
				else
					GET_INSTRUCTION_STATE <= WAIT_FOR_INSTRUCT;
				end if;
				
			when PARSE_INSTRUCT =>					
				-----------------------------------------------------------
				--parse 32 bit instruction word:
				INSTRUCT_PSEC_MASK	<= xINSTRUCT_WORD(24 downto 20);
				INSTRUCTION   			<= xINSTRUCT_WORD(19 downto 16);
				INSTRUCTION_OPT		<= xINSTRUCT_WORD(15 downto 12);
				INSTRUCT_VALUE 		<= xINSTRUCT_WORD(11 downto 0);
				-----------------------------------------------------------
				GET_INSTRUCTION_STATE <= WAITING;

			when WAITING =>	
				GET_INSTRUCTION_STATE <= TARGET;
				
			when TARGET =>
				case INSTRUCTION(3 downto 0) is	
					when set_dll_vdd_instruct =>
						for j in 4 downto 0 loop
							case INSTRUCT_PSEC_MASK(j) is
								when '1' =>
									SET_DLL_VDD(j) <= x"0" & INSTRUCT_VALUE(11 downto 0);
								when others =>
									SET_DLL_VDD(j) <= SET_DLL_VDD(j);
							end case;
						end loop;
						GET_INSTRUCTION_STATE <= DELAY;

					when set_cal_switch_instruct =>		
						ENABLE_CAL_SWITCH <= INSTRUCTION_OPT(2 downto 0) & INSTRUCT_VALUE(11 downto 0);
						GET_INSTRUCTION_STATE <= DELAY;	
						
					when set_ped_instruct =>   
						for j in 4 downto 0 loop
							case INSTRUCT_PSEC_MASK(j) is
								when '1' =>
									SET_VBIAS(j) <= x"0" & INSTRUCT_VALUE(11 downto 0);
								when others =>
									SET_VBIAS(j) <= SET_VBIAS(j);
							end case;
						end loop;
--						SET_VBIAS(0) <= x"0" & INSTRUCT_VALUE(11 downto 0);
--						SET_VBIAS(1) <= x"0" & INSTRUCT_VALUE(11 downto 0);
--						SET_VBIAS(2) <= x"0" & INSTRUCT_VALUE(11 downto 0);
--						SET_VBIAS(3) <= x"0" & INSTRUCT_VALUE(11 downto 0);
--						SET_VBIAS(4) <= x"0" & INSTRUCT_VALUE(11 downto 0);

						GET_INSTRUCTION_STATE <= DELAY;
						
					when set_reset_instruct =>
						case INSTRUCTION_OPT is
							when set_reset_instruct_opt_dll =>
								RESET_DLL_FLAG <= (others=>'1');
								GET_INSTRUCTION_STATE <= DELAY;								
							when set_reset_instruct_opt_trig =>
								RESET_SELF_TRIG <= '1';
								GET_INSTRUCTION_STATE <= DELAY;							
							when set_reset_instruct_opt_all =>
								GLOBAL_RESET <= '1';
								GET_INSTRUCTION_STATE <= DELAY;	
							when set_reset_instruct_opt_time =>
								EVENT_AND_TIME_RESET <= '1';
								GET_INSTRUCTION_STATE <= DELAY;	
							when others =>
								GET_INSTRUCTION_STATE <= DELAY;
						end case;		
						
					when set_trig_mask_instruct =>
						case INSTRUCTION_OPT(3) is
							when set_trig_mask_instruct_opt_hi =>
								SELF_TRIG_MASK(29 downto 15) <= INSTRUCTION_OPT(2 downto 0) & INSTRUCT_VALUE(11 downto 0);
								GET_INSTRUCTION_STATE <= DELAY;
							when set_trig_mask_instruct_opt_lo =>
								SELF_TRIG_MASK(14 downto 0)  <= INSTRUCTION_OPT(2 downto 0) & INSTRUCT_VALUE(11 downto 0);
								GET_INSTRUCTION_STATE <= DELAY;
							when others =>
								GET_INSTRUCTION_STATE <= DELAY;
						end case;
						
					when set_trig_settng_instruct =>
						case INSTRUCT_VALUE(11) is
							when '0' =>
								SELF_TRIG_SETTINGS_0 <= INSTRUCT_VALUE(10 downto 0);
							when '1' =>
								SELF_TRIG_SETTINGS_1 <= INSTRUCT_VALUE(10 downto 0);
							end case;
						GET_INSTRUCTION_STATE <= DELAY;
						
					when set_trig_thresh_instruct =>   
						for j in 4 downto 0 loop
							case INSTRUCT_PSEC_MASK(j) is
								when '1'  =>
									SET_TRIG_THRESH(j) <= x"0" & INSTRUCT_VALUE(11 downto 0);
								when others =>
									SET_TRIG_THRESH(j) <= SET_TRIG_THRESH(j);
							end case;
						end loop;
						--SET_TRIG_THRESH(0) <= x"0" & INSTRUCT_VALUE(11 downto 0);
						--SET_TRIG_THRESH(1) <= x"0" & INSTRUCT_VALUE(11 downto 0);
						--SET_TRIG_THRESH(2) <= x"0" & INSTRUCT_VALUE(11 downto 0);
						--SET_TRIG_THRESH(3) <= x"0" & INSTRUCT_VALUE(11 downto 0);
						--SET_TRIG_THRESH(4) <= x"0" & INSTRUCT_VALUE(11 downto 0);
						GET_INSTRUCTION_STATE <= DELAY;
					
					when set_ro_feedback_instruct =>   
						for j in 4 downto 0 loop
							case INSTRUCT_PSEC_MASK(j) is
								when '1' =>
									ADJUST_RO_TARGET(j) <= 	INSTRUCT_VALUE(11 downto 0) & x"0";
								when others=>
									ADJUST_RO_TARGET(j) <= 	ADJUST_RO_TARGET(j);
							end case;
						end loop;
						GET_INSTRUCTION_STATE <= DELAY;
					 
					when set_led_enable_instruct =>
						case INSTRUCT_VALUE(2) is
							when '1' =>
								PULL_META_AND_DATA_FROM_RAM <= INSTRUCT_VALUE(1);
							when others=>
								ENABLE_LED <= INSTRUCT_VALUE(0);
						end case;
						
						case INSTRUCT_VALUE(5) is
							when '1' =>
								PLL_SAMPLE_MODE <= INSTRUCT_VALUE(4 downto 3);
							when others=>
								PLL_SAMPLE_MODE <= PLL_SAMPLE_MODE;
						end case;
						GET_INSTRUCTION_STATE <= DELAY;
	
					when system_setting_manage =>
						case INSTRUCT_VALUE(2) is
							when '1' =>
								TRIG_VALID 		<= INSTRUCT_VALUE(1);
							when '0' => 
								CC_EVENT_RESET <= INSTRUCT_VALUE(0);
						end case;
						GET_INSTRUCTION_STATE <= DELAY;
	
					when system_setting_instruct =>
--						case INSTRUCT_VALUE(2 downto 0) is 
--							when "111" => 
--								TRIG_VALID <= '1';
--								GET_INSTRUCTION_STATE <= DELAY;
--
--							when others =>
--								TRIG_VALID <= '0';
								GET_INSTRUCTION_STATE <= DELAY;
						--end case;
						
					when others =>
						i := i + 1;
						if i > 8 and xINSTRUCT_FLAG = '0' then
							i := 0;
							GET_INSTRUCTION_STATE <= WAIT_FOR_INSTRUCT;		
						end if;	
				
				end case;
				
			when DELAY =>
				if INSTRUCTION /= system_setting_instruct then
					LAST_INSTRUCTION <= xINSTRUCT_WORD;
				end if;
				i := i + 1;
				if i > 8 and xINSTRUCT_FLAG = '0' then
					i := 0;
					GET_INSTRUCTION_STATE <= WAIT_FOR_INSTRUCT;
				end if;
		end case;
	end if;
end process;

end Behavioral;
				
				
		
		
--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	lvds_com
-- author		: 	ejo
-- date			: 	6/2012
-- description	:  lvds xfer manager
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; -- this should not be used!

use work.Definition_Pool.all;

entity lvds_com is
	port(
			xSTART		 		: in   	std_logic_vector(4 downto 0);
			xDONE		 			: out   	std_logic_vector(4 downto 0);
			xCLR_ALL	 			: in   	std_logic;
			xRX_LVDS_CLK	 	: in		std_logic;
			xALIGN_SUCCESS		: out		std_logic;
			 
			xADC					: in   ChipData_array;
			xINFO1				: in   ChipData_array;
			xINFO2				: in   ChipData_array;
			xINFO3				: in   ChipData_array;
			xINFO4				: in   ChipData_array;
			xINFO5				: in   ChipData_array;
			xINFO6				: in   ChipData_array;
			xINFO7				: in   ChipData_array;
			xINFO8				: in   ChipData_array;
			xINFO9				: in   ChipData_array;
			xINFO10				: in   ChipData_array;
			xINFO11				: in   ChipData_array;
			xINFO12				: in   ChipData_array;
			xINFO13				: in 	 ChipData_array;
			
			xEVT_CNT				: in   EvtCnt_array;
			
				
			xCLK_40MHz			: in		std_logic;
			xRX_LVDS_DATA	 	: in		std_logic;
			xINSTRUCTION		: out		std_logic_vector(31 downto 0);
			xINSTRUCT_READY	: out		std_logic;
			xPSEC_MASK			: in 		std_logic_vector(4 downto 0);
			xFPGA_PLL_LOCK		: in		std_logic;
			xEXTERNAL_DONE		: in		std_logic;
			
			xREAD_ADC_DATA		: in		std_logic;
			
			xREAD_TRIG_RATE_ONLY  	: in	std_logic;
			xSELF_TRIG_RATE_COUNT 	: in rate_count_array;
				
			xSYSTEM_IS_CLEAR			: in	std_logic;
			xPULL_RAM_DATA				: in  std_logic;
			xCLK_COMS					: in  std_logic;
			
			xTX_LVDS_DATA		: out		std_logic_vector(1 downto 0);

			xRADDR				: out  	std_logic_vector (RAM_ADR_SIZE-1 downto 0);
			xRAM_READ_EN		: out		std_logic_vector(4 downto 0);
			xDC_XFER_DONE		: out		std_logic_vector(4 downto 0);
			xTX_BUSY				: out 	std_logic;
			xRX_BUSY				: out		std_logic;
			xTX_LVDS_CLK		: out		std_logic);
			
end lvds_com;

architecture Behavioral of lvds_com is 


COMPONENT lvds_tranceivers
	PORT
	(
		CLK					:	 IN STD_LOGIC;
		RST					:	 IN STD_LOGIC;
		CLK_COMS				:	 IN STD_LOGIC;
		RX_LVDS_DATA		:	 IN STD_LOGIC;
		TX_DATA				:	 IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		TX_DATA_RDY			:	 IN STD_LOGIC;
		LINK_UP				:   OUT STD_LOGIC;
		REMOTE_UP			:	 OUT STD_LOGIC;
		REMOTE_VALID		:	 OUT STD_LOGIC;
		TX_BUF_FULL			:	 OUT STD_LOGIC;
		RX_ERROR				:	 OUT STD_LOGIC;
		RX_DATA_RDY			:	 OUT STD_LOGIC;
		RX_DATA				:	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
		TX_LVDS_DATA		:	 OUT STD_LOGIC
	);
END COMPONENT;

type 	GET_CC_INSTRUCT_TYPE is (IDLE, ONDECK, CATCH0, CATCH1, CATCH2, CATCH3, DELAY, READY);
--type 	GET_CC_INSTRUCT_TYPE is (IDLE, CATCH0, CATCH1, CATCH2, CATCH3, READY);
signal GET_CC_INSTRUCT_STATE	:	GET_CC_INSTRUCT_TYPE;

type LVDS_MESS_STATE_TYPE	is (MESS_START, INIT, ADC, INFO0, INFO1, INFO2, INFO3, 
										INFO4, INFO5, INFO6, INFO7, INFO8, INFO9, INFO10, INFO11, INFO12, INFO13,
										TRIG_RATE,
										PSEC_END, MESS_END, CC_DONE, GND_STATE, GND_STATE_END);
signal LVDS_MESS_STATE			:  LVDS_MESS_STATE_TYPE := MESS_START;

signal GOOD_DATA_RDY 			:  std_logic;
signal TX_BUF_FULL 				:  std_logic;
signal RX_DATA_RDY				:  std_logic;
signal RX_DATA						:	std_logic_vector(7 downto 0);
signal CHECK_WORD					:	std_logic_vector(7 downto 0);
signal ALIGN_SUCCESS				:  std_logic := '0';
signal GOOD_DATA					:  std_logic_vector(15 downto 0);
signal LINK_UP						:  std_logic;
signal REMOTE_UP					:  std_logic;
signal REMOTE_VALID				:  std_logic;
signal RX_ERROR					:  std_logic;

signal INSTRUCTION				:	std_logic_vector(31 downto 0);
signal INSTRUCT_READY			:	std_logic := '0';

signal PSEC_MASK					:	std_logic_vector(4 downto 0);
signal MASK_COUNT_VECTOR		:	std_logic_vector(2 downto 0);
 
signal RADDR						: std_logic_vector(RAM_ADR_SIZE-1 downto 0);
signal RAM_READ_EN				: std_logic_vector(4 downto 0);
signal RX_BUSY						: std_logic := '0';
signal DONE							: std_logic := '0';
signal START						: std_logic;
signal INTERNAL_DONE				: std_logic_vector(4 downto 0) := "00000";
signal internal_done_bit		: std_logic;
signal mess_busy					: std_logic := '0';
signal SYSTEM_TIME_COUNTER		: std_logic_vector(48 downto 0) := (others=>'0');
signal SYSTEM_START				: std_logic;


begin

ALIGN_SUCCESS		<= '1' when (LINK_UP = '1') else '0';

xALIGN_SUCCESS 	<= ALIGN_SUCCESS;
xRAM_READ_EN	  	<= RAM_READ_EN;
xRADDR				<= RADDR;
xDC_XFER_DONE		<= INTERNAL_DONE;
xTX_BUSY				<= mess_busy;
xRX_BUSY				<=	RX_BUSY;

xINSTRUCT_READY	<= INSTRUCT_READY;
xINSTRUCTION 		<= INSTRUCTION;

PSEC_MASK			<= xPSEC_MASK;	
START					<= (xSTART(0) and xSTART(1) and xSTART(2) and 
							xSTART(3) and xSTART(4)) and ALIGN_SUCCESS;
							

process(xCLK_40MHz, ALIGN_SUCCESS, xCLR_ALL)
variable i : integer range 50 downto 0;	
begin
	if xCLR_ALL = '1' or ALIGN_SUCCESS = '0' then
		INSTRUCTION <= (others=>'0');
		--CC_INSTRUCTION_READY <= (others=>'0');
		INSTRUCT_READY <= '0';
		--INSTRUCT_READY_REGISTERED <= '0';
		i := 0;
		RX_BUSY <= '0';
		GET_CC_INSTRUCT_STATE <= IDLE;
		
	elsif rising_edge(xCLK_40MHz) and ALIGN_SUCCESS = '1' then
		case GET_CC_INSTRUCT_STATE is
			when IDLE =>
				i := 0;
				INSTRUCT_READY <= '0';
				RX_BUSY <= '0';
				if RX_DATA_RDY = '1' AND RX_DATA = STARTWORD_8a then
					RX_BUSY <= '1';
					GET_CC_INSTRUCT_STATE <= ONDECK;
				end if;	
			when ONDECK => 
				if RX_DATA_RDY = '1' AND RX_DATA = STARTWORD_8b then
					GET_CC_INSTRUCT_STATE <= CATCH0;
				elsif RX_DATA_RDY = '1' then	
					GET_CC_INSTRUCT_STATE <= IDLE;
				end if;
				
			when CATCH0 =>
				if  RX_DATA_RDY = '1' then
					INSTRUCTION(31 downto 24) 	<= RX_DATA;
					GET_CC_INSTRUCT_STATE <= CATCH1;
				end if;
			when CATCH1 =>
				if  RX_DATA_RDY = '1' then
					INSTRUCTION(23 downto 16) 	<= RX_DATA;
					GET_CC_INSTRUCT_STATE <= CATCH2;
				end if;
			when CATCH2 =>
				if  RX_DATA_RDY = '1' then
					INSTRUCTION(15 downto 8) 	<= RX_DATA;
					GET_CC_INSTRUCT_STATE <= CATCH3;
				end if;
			when CATCH3 =>
				if  RX_DATA_RDY = '1' then
					INSTRUCTION(7 downto 0) 	<= RX_DATA;
					GET_CC_INSTRUCT_STATE <= READY;
				end if;
			when READY =>
				INSTRUCT_READY <= '1';
				RX_BUSY <= '0';
				GET_CC_INSTRUCT_STATE <= IDLE;
			when others =>  -- catch all.
				GET_CC_INSTRUCT_STATE <= IDLE;
		end case;
	end if;
	
end process;

--organize packets and send data along LVDS to CC

--process (xCLR_ALL, xCLK_40MHz, internal_done_bit)
--begin
--	if xCLR_ALL = '1' then	
--		DONE <= '0';
--		INTERNAL_DONE <= (others=> '0');
--	elsif rising_edge(xCLK_40MHz) and (internal_done_bit = '1' or xSYSTEM_IS_CLEAR = '1') then	
--		DONE <= '1';
--		INTERNAL_DONE <= (others=> '1');
--	elsif rising_edge(xCLK_40MHz) and internal_done_bit = '0' then	
--		DONE <= '0';
--		INTERNAL_DONE <= (others=> '0');
--	end if;
--end process;
process (xCLR_ALL, internal_done_bit)
begin
	if xCLR_ALL = '1' or xSYSTEM_IS_CLEAR = '1' then	
		DONE <= '0';
		INTERNAL_DONE <= (others=> '0');
	elsif rising_edge(internal_done_bit) then
		DONE <= '1';
		INTERNAL_DONE <= (others=> '1');
	end if;
end process;

process (xCLR_ALL, xPULL_RAM_DATA, DONE)
begin
	if xCLR_ALL = '1' or DONE = '1' or xSYSTEM_IS_CLEAR = '1' then
		SYSTEM_START <= '0';
	elsif rising_edge(xPULL_RAM_DATA) then
		SYSTEM_START <= '1';
	end if;
end process;

--DONE <= internal_done_bit;
process(xCLK_40MHz, START, xCLR_ALL, PSEC_MASK, xSYSTEM_IS_CLEAR )				
variable i : integer range 50 downto 0;	
variable mask_count : integer range 4 downto 0 := 0;
variable valid_data : std_logic;	
variable RAM_CNT	  : integer range 6 downto 0;
	begin
	if xCLR_ALL = '1' or DONE = '1' or ALIGN_SUCCESS = '0' then
		RADDR 				<= "00000000000000";--(others=>'0');
		GOOD_DATA 			<= (others=>'0');
		valid_data			:= '0';
		RAM_CNT				:= 0;
		internal_done_bit <= '0';
		mess_busy			<= '0';
		i 						:= 0;
		mask_count 			:= 0;
		LVDS_MESS_STATE 	<= MESS_START;

	elsif rising_edge(xCLK_40MHz) then
		if (TX_BUF_FULL = '0') and (START = '1'  or SYSTEM_START = '1') then		
			valid_data := '1';  -- valid output data, unless we set it otherwise later.
			case LVDS_MESS_STATE is
				
				when MESS_START =>	
				
					if i > 1 then
						i := 0;
						LVDS_MESS_STATE <= INIT;	
						valid_data := '0';
					else
						GOOD_DATA 		<= STARTWORD;
						mess_busy      <= '1';
						i := i+1;
					end if;
				
				when INIT =>
					--GOOD_DATA 	<= x"F005";
					if mask_count >= 5 then
						valid_data := '0';
						i:= 0;
							--LVDS_MESS_STATE <= MESS_END;
						LVDS_MESS_STATE <= TRIG_RATE;
					
				--	elsif PSEC_MASK(mask_count) = '0' then			
				--			mask_count := mask_count + 1;
				--			LVDS_MESS_STATE <= MESS_START;
						
					--elsif xREAD_ADC_DATA = '1' then
					else
						GOOD_DATA 	<= x"F005";
						RAM_CNT := RAM_CNT + 1;
						--RAM_CNT <= "0001";
						LVDS_MESS_STATE <= ADC;
					end if;
										
				when ADC =>	
					if RADDR > 1538 then       --256
						RADDR <= (others=>'0');
						LVDS_MESS_STATE  <= INFO0;	
						valid_data := '0';
					
					else
						GOOD_DATA <=  xADC(mask_count);
						--GOOD_DATA <=  xADC(0);
						RADDR <= RADDR + 1;
					end if;
				
				when INFO0 =>
					GOOD_DATA <= x"BA11";	
					LVDS_MESS_STATE <= INFO1;								
				when INFO1 =>
					GOOD_DATA <= xINFO1(mask_count);	
					LVDS_MESS_STATE <= INFO2;					
				when INFO2 =>	
					GOOD_DATA <= xINFO2(mask_count);	
					LVDS_MESS_STATE  <= INFO3;					
				when INFO3 =>	
					GOOD_DATA <= xINFO3(mask_count);	
					LVDS_MESS_STATE  <= INFO4;					
				when INFO4 =>	
					GOOD_DATA <= xINFO4(mask_count);	
					LVDS_MESS_STATE  <= INFO5;	
				when INFO5 =>	
					GOOD_DATA <= xINFO5(mask_count);	
					LVDS_MESS_STATE <= INFO6;					
				when INFO6 =>	
					GOOD_DATA <= xINFO6(mask_count);	
					LVDS_MESS_STATE <= INFO7;					
				when INFO7 =>	
					GOOD_DATA <= xINFO7(mask_count);	
					LVDS_MESS_STATE <= INFO8;											
				when INFO8 =>	
					GOOD_DATA <= xINFO8(mask_count);	
					LVDS_MESS_STATE <= INFO9;						
				when INFO9 =>	
					GOOD_DATA <= xINFO9(mask_count);	
					LVDS_MESS_STATE <= INFO10;		
				when INFO10 =>	
					GOOD_DATA <= xINFO10(mask_count);	
					LVDS_MESS_STATE <= INFO11;										
				when INFO11 =>	
					GOOD_DATA <= xINFO11(mask_count);	
					LVDS_MESS_STATE <= INFO12;	
				when INFO12 =>	
					GOOD_DATA <= xINFO12(mask_count);	
					LVDS_MESS_STATE <= INFO13;	
				when INFO13 =>	
					GOOD_DATA <= xINFO13(mask_count);	
					LVDS_MESS_STATE <= PSEC_END;	
					
				when PSEC_END =>
					GOOD_DATA <= PSEC_END_WORD;
					mask_count := mask_count + 1;
					LVDS_MESS_STATE <= INIT;
					--LVDS_MESS_STATE <= MESS_END;

				when TRIG_RATE =>
					GOOD_DATA <= xSELF_TRIG_RATE_COUNT(i)(15 downto 0);
					
					if i = 29 then
						i := 0;
						LVDS_MESS_STATE <= MESS_END;	
					else
						i := i+1;
					end if;
					
				when MESS_END =>	

					if i > 2 then
						i := 0;
						LVDS_MESS_STATE <= CC_DONE;
						valid_data := '0';
					
					else
						GOOD_DATA <= ENDWORD;	
						i := i+1;	
					end if;
						
				when CC_DONE =>
					GOOD_DATA <= (others=>'0');
					--if xSYSTEM_IS_CLEAR = '1' then
						LVDS_MESS_STATE <= GND_STATE;	
					--else
					--	LVDS_MESS_STATE <= CC_DONE;	
					--end if;
					
				when GND_STATE =>			
					if i > 4 then
						valid_data := '0';
						internal_done_bit <= '0';
						LVDS_MESS_STATE <= GND_STATE_END;
					else
						GOOD_DATA <= (others=>'0');
						internal_done_bit <= '1';
						i := i+1;
					end if;
					
				when GND_STATE_END =>
					valid_data := '0';
					--nothing to do, end of case, should have been reset by now
				
			end case;
			case RAM_CNT is
				when 0 =>
					RAM_READ_EN <= "00000";
				when 1 =>
					RAM_READ_EN <= "00001";
				when 2 =>
					RAM_READ_EN <= "00010";
				when 3 =>
					RAM_READ_EN <= "00100";
				when 4 =>
					RAM_READ_EN <= "01000";
				when 5 =>
					RAM_READ_EN <= "10000";
				when others =>
					RAM_READ_EN <= "00000";
			end case;
		else
			valid_data := '0';
		end if;
	end if;
	GOOD_DATA_RDY <= valid_data;
end process;		


xDC_lvds_tranceivers : lvds_tranceivers
port map(
			CLK				=>		xCLK_40MHz,
			RST				=>		xCLR_ALL,	
			CLK_COMS			=>		xCLK_COMS,
			RX_LVDS_DATA	=>		xRX_LVDS_DATA,
			TX_DATA			=>		GOOD_DATA,
			TX_DATA_RDY    =>		GOOD_DATA_RDY,
			LINK_UP			=>		LINK_UP,
			REMOTE_UP		=>		REMOTE_UP,
			REMOTE_VALID	=> 	REMOTE_VALID,
			TX_BUF_FULL 	=> 	TX_BUF_FULL,
			RX_DATA_RDY		=> 	RX_DATA_RDY,
			RX_DATA			=>		RX_DATA,
			RX_ERROR			=>		RX_ERROR,
			TX_LVDS_DATA	=>		xTX_LVDS_DATA(0));	

xTX_LVDS_DATA(1) <= '1';


end Behavioral;

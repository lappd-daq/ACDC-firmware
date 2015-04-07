--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	psec4_control
-- author		: 	ejo
-- date			: 	4/2012
-- description	:  timing control for single PSEC-4 ASIC
--						generate 5 such modules for analog card control (4 downto 0)
--------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Definition_Pool.all;

entity psec4_control is 
	port(
		xMCLK			:	in		std_logic;			--40MHz	
		xCLKFAST		:	in		std_logic;			--faster clock to register trigger signals (160M ?)
		xCHIPSELECT	:	in		std_logic;			--enable trigger to specified PSEC-4 ASIC
		xTRIG_FLAG	:	in		std_logic;			--signal generated from trigger module
		xCLR_ALL		: 	in		std_logic;			--global reset (clears high)
		xDONE			:	in		std_logic;			--USB, etc. write done signal

		xDLL_RESET_FLAG	:	in		std_logic;
		xDLL_CLOCK			:	in		std_logic;
		xDLL_RESET			:	out	std_logic;
		
		xDAC_CLK		:	in		std_logic;			--DAC SYNC clock
		xREFRSH_CLK	:	in		std_logic;			--slow refresh clock (1-10 Hz)
		xRO_MON		:	in		std_logic;			--ring oscillator mon bit
		xDESIRECOUNT:	in		std_logic_vector(15 downto 0);--set target ADC rate by this count
		xRESETFDBK	:	in		std_logic;			--feedback reset
      xCOUNT_VALUE: 	out 	std_logic_vector(15 downto 0);--output current count value
      xDAC_VALUE  : 	out 	std_logic_vector(11 downto 0);--send feedback DAC value to DAC firmware		
		
		xRAMP			:	out	std_logic;			--ramp start signal (active low)
		xCLEARADC	:	out	std_logic;			--clears ADC when high
		xRO_EN		:	out	std_logic;			--turn on/off ADC ring oscillator
		xADCLATCH	:	out	std_logic;			--optional function to send ADC'd data to digital buffer
		
		xRD_CLKIN	:	in		std_logic;			--Read clock from PLL (10-40 MHz typically)
		xCHANTOREAD	:  in		std_logic_vector(5 downto 0);	--channels to read from PSEC
		xRD_CLKOUT	:	out	std_logic;			--rebuffered read clock sent to board
		xRAM_CLK		:	in		std_logic;			--clock to read data from RAM block
--		xRAMW_EN		:	in		std_logic;			--enable write
		xRAMR_EN		:	in		std_logic;			--enable read from ram
		xRD_ADDRESS	:	in		std_logic_vector(RAM_ADR_SIZE-1 downto 0);	
		xRAWDATA		:	in		std_logic_vector(12 downto 0);--data from chips
		xSELF_TRIG_EN :in		std_logic;
		xTRIG_VALID	:  in		std_logic;
		xDONE_FROM_SYS:in		std_logic;
		xRAMDATA		:	out	std_logic_vector(15 downto 0);--data stored in RAM
		xTOK_IN1		:	out	std_logic;			--readout token 1 & 2
		xTOK_IN2		: 	out	std_logic;
		xCHAN_SEL	:	out	std_logic_vector(2 downto 0);			--channel select addr. (0-5)
		xBLOCK_SEL	:	out	std_logic_vector(2 downto 0);			--block select addr. (0-3)
		xSTART		:	out	std_logic;			--USB, etc. start write signal
		xVCDL_COUNT :  out   std_logic_vector(31 downto 0);
		xMONITOR		:	out	std_logic_vector(23 downto 0));
end psec4_control;

-------------------------------------------------------------
architecture BEHAVIORAL of psec4_control is
-------------------------------------------------------------
	type 	RESET_STATE_TYPE	is (RESET, RELAX);
	signal	RESET_STATE	:	RESET_STATE_TYPE;
	
	type READ_STATE_TYPE	is (IDLE, INSERT_TOK, WAIT_TOK, WRITE_RAM, DONE);
	signal STATE_READ	:	READ_STATE_TYPE;
	
	type ADC_STATE_TYPE is (INIT,  RAMPING, EXTLATCH_RISE, EXTLATCH_FALL,  RAMPDONE);
	signal STATE_ADC	:	ADC_STATE_TYPE;
	
	signal 	ADC_CLEAR	:	std_logic := '1';
	signal 	RAMP			:	std_logic := '1';
	signal 	RAMP_CNT		:	std_logic_vector(10 downto 0); --:= b"00000000000";
	signal 	RAMP_DONE	:	std_logic;
	signal	RO_EN			:	std_logic := '0';
	signal	ADCLATCH		:	std_logic;
	
	signal 	TOK_CNT		:	std_logic_vector(1 downto 0);
	signal   TOKIN1		:	std_logic := '0';
	signal	TOKIN2		:	std_logic := '0';
	signal	BLKSEL		:	std_logic_vector(2 downto 0);
	signal	CHANSEL		:	std_logic_vector(2 downto 0);
	signal   READ_CNT		:	std_logic_vector(6 downto 0);
	signal 	WADDR			:	std_logic_vector(RAM_ADR_SIZE-1 downto 0);
	signal 	WADDR_TEMP	:	std_logic_vector(RAM_ADR_SIZE-1 downto 0);
	signal 	W_EN			: 	std_logic;
	signal 	W_EN_TEMP	: 	std_logic;
	signal	START			:	std_logic;
	signal 	RD_CLK_EN	:	std_logic;

	signal	RESET_DLL_FROM_POWERUP	:	std_logic;	
	signal	RESET_DLL_FROM_SOFTWARE	:	std_logic	:=	'1';
	signal	RESET_COUNT					:	std_logic	:= '1';	
	signal	DLL_COUNTER					:	std_logic_vector(23 downto 0);
	signal	DLL_RESET					:  std_logic;
-------------------------------------------------------------
--	components
-------------------------------------------------------------	
	component RAM_16bit
	port( 	
			xW_EN			: in	std_logic;
			xR_EN			: in	std_logic;
			xWRAM_CLK	: in	std_logic;
			xRRAM_CLK	: in 	std_logic;
			xWR_ADDRESS	: in	std_logic_vector(RAM_ADR_SIZE-1 downto 0);
			xRD_ADDRESS	: in	std_logic_vector(RAM_ADR_SIZE-1 downto 0);
			xWRITE		: in	std_logic_vector(12 downto 0);
			xREAD			: out	std_logic_vector(15  downto 0));
	end component;	
	
	component Wilkinson_Feedback_Loop
	Port (
			ENABLE_FEEDBACK     : in std_logic;
			RESET_FEEDBACK      : in std_logic;
			REFRESH_CLOCK       : in std_logic; --One period of this clock defines how long we count Wilkinson rate pulses
			DAC_SYNC_CLOCK      : in std_logic; --This clock should be the same that is used for setting DACs, and should be used to avoid race conditions on setting the desired DAC values
			WILK_MONITOR_BIT    : in std_logic;
			DESIRED_COUNT_VALUE : in std_logic_vector(15 downto 0);
			CURRENT_COUNT_VALUE : out std_logic_vector(15 downto 0);
			DESIRED_DAC_VALUE   : out std_logic_vector(11 downto 0));
    end component;
	 
	component VCDL_Monitor_Loop
   Port (
                                RESET_FEEDBACK      : in std_logic;
                                REFRESH_CLOCK       : in std_logic; --One period of this clock defines how long we count Wilkinson rate pulses
                                VCDL_MONITOR_BIT    : in std_logic;
                                CURRENT_COUNT_VALUE : out std_logic_vector(31 downto 0));
	end component;
-------------------------------------------------------------
begin
-------------------------------------------------------------
	
	xRD_CLKOUT	<=		(xRD_CLKIN and RD_CLK_EN);
	xTOK_IN1 	<= 	TOKIN1;
	xTOK_IN2 	<= 	TOKIN2;
	xCHAN_SEL 	<= 	CHANSEL;
	xBLOCK_SEL 	<= 	BLKSEL;
	xRAMP 		<=		RAMP;
	xRO_EN		<=		RO_EN;
	xCLEARADC	<=		ADC_CLEAR;
	xSTART		<=		START;
	xADCLATCH	<= 	ADCLATCH;
	DLL_RESET	<=		(RESET_DLL_FROM_POWERUP and RESET_DLL_FROM_SOFTWARE);
	xDLL_RESET	<= 	(RESET_DLL_FROM_POWERUP and RESET_DLL_FROM_SOFTWARE);
	
	xMONITOR(0)	<=		not DLL_counter(22);
	
----------------------------------------------------------------
--PSEC-4 DLL MONITORING & RESET 
----------------------------------------------------------------
	process(xCLR_ALL)
		begin	
			if xCLR_ALL = '1' then
				RESET_DLL_FROM_POWERUP <= '0';
			else
				RESET_DLL_FROM_POWERUP <= '1';		
			end if;
	end process;
	
	process(xMCLK, xDLL_RESET_FLAG)
		begin
			if xCLR_ALL = '1' then
				RESET_DLL_FROM_SOFTWARE <= '1';
			elsif rising_edge(xMCLK) and (RESET_COUNT = '0') then
				RESET_DLL_FROM_SOFTWARE <= '1';
			elsif rising_edge(xMCLK) and xDLL_RESET_FLAG = '1' then
				RESET_DLL_FROM_SOFTWARE <= '0';
			end if;
	end process;
	
	process(xMCLK, RESET_DLL_FROM_SOFTWARE)
	variable i : integer range 300000001 downto -1 := 0;
		begin
			if falling_edge(xMCLK) and RESET_DLL_FROM_SOFTWARE = '1' then
				i := 0;
				RESET_STATE <= RESET;
				RESET_COUNT <= '1';
			elsif falling_edge(xMCLK) and RESET_DLL_FROM_SOFTWARE  = '0' then
				case RESET_STATE is
					when RESET =>
						i:=i+1;
						if i > 10000000 then
							i := 0;
							RESET_STATE <= RELAX;
						end if;
						
					when RELAX =>
						RESET_COUNT <= '0';

				end case;
			end if;
	end process;
	
	--observe DLL out from PSEC -> LED
	process(xCLR_ALL) 
	begin
		if xCLR_ALL = '1' or DLL_RESET = '0' then
			DLL_COUNTER	<=	(others => '0');
		elsif rising_edge(xDLL_CLOCK) then
			DLL_COUNTER <= DLL_COUNTER + 1;
		end if;
	end process;
	
--	process(xCLR_ALL,xREFRSH_CLK, DLL_RESET)
--	begin

----------------------------------------------------------------
--PSEC-4 WILK. ADC CONTROL
---------------------------------------------------------------- 		
	process(xMCLK, xCLR_ALL, xDONE, xTRIG_FLAG)
	variable i : integer range 50 downto 0;
	begin
		if xCLR_ALL = '1' or xDONE_FROM_SYS = '1' or
			xDONE = '1'	then 
			RAMP 			<='0';
			RAMP_DONE 	<= '0';
			RAMP_CNT 	<= (others => '0');
			STATE_ADC	<= INIT;
			ADC_CLEAR 	<= '1';
			ADCLATCH 	<= '0'; --latch follows trigger for now
			i 				:= 0;
			RO_EN 		<= '0';
			--RO_EN <= '1'; --test ADC power
		elsif falling_edge(xMCLK) and xTRIG_FLAG= '1'  then 
			case STATE_ADC is
			-------------------------	
				when INIT =>
					i	:= i+1;   -- some setup time
					ADCLATCH <= '1';
					RO_EN 	<= '1';
					RAMP 		<= '1';
					--if i = ADCSETUPCOUNT then
					if i = 12 then
						i	:= 0;
						RAMP 			<= '0';
						STATE_ADC	<= RAMPING;
					end if;
			-------------------------	
				when RAMPING =>					
					ADC_CLEAR 	<= '0';  	 -- ramp active low
					RAMP_CNT 	<= RAMP_CNT + 1;
					if RAMP_CNT = WILKRAMPCOUNT then  --set ramp length w.r.t. clock
						RAMP_CNT 	<= (others => '0');
						RO_EN 		<='0';
						STATE_ADC 	<= EXTLATCH_RISE;
					end if;
			-------------------------
			    when EXTLATCH_RISE =>   --latch tranparency pulse
					i 	:= i+1;
					if i = 1 then
						i	:= 0;
						--ADCLATCH 	<= '1';
						STATE_ADC 	<= EXTLATCH_FALL;
					end if;
					
				when EXTLATCH_FALL =>
					i	:= i+1;
					if i = 1  then	
						i	:= 0;
						--ADCLATCH 	<= '0';
						STATE_ADC	<= RAMPDONE;
					end if;
			-------------------------
				when RAMPDONE =>
					RAMP_DONE 	<= '1';
			-------------------------
				when others =>
					STATE_ADC 	<= INIT;
			end case;
		end if;
	end process;		

----------------------------------------------------------------
--PSEC-4 SERIAL DATA READOUT CONTROL
---------------------------------------------------------------- 
	process(TOK_CNT)   
	begin
		if TOK_CNT = 0 then
			TOKIN1 <= '0';
			TOKIN2 <= '0';
		elsif TOK_CNT = 1 then
			TOKIN1 <= '1';
			TOKIN2 <= '0';
		elsif TOK_CNT = 2 then
			TOKIN1 <= '0';
			TOKIN2 <= '1';
		else
			TOKIN1 <= '0';
			TOKIN2 <= '0';
		end if;
	end process;
		
	process(xRD_CLKIN, xDONE, xCLR_ALL, RAMP_DONE)
	begin
	
		if xCLR_ALL = '1' or xDONE_FROM_SYS = '1' or
			xDONE = '1'  then
			
			TOK_CNT 		<= "00";
			W_EN			<= '0';
			W_EN_TEMP 	<= '0';
			WADDR_TEMP	<= (others => '0');  --changed from '0' 18.6.2014
			WADDR 		<= (others => '0');	--changed from '0' 18.6.2014
			CHANSEL		<= "000";
			READ_CNT		<= (others => '0');
			BLKSEL 		<= "101"; -- clears ASIC token
			START 		<= '0';
			RD_CLK_EN   <= '0';
			STATE_READ	<= IDLE;
		
		elsif falling_edge(xRD_CLKIN) and RAMP_DONE = '1' then
			case STATE_READ is
				when IDLE =>
					RD_CLK_EN	<= '1';
					BLKSEL 		<= "001";
					CHANSEL 		<= CHANSEL + 1;
					STATE_READ	<= INSERT_TOK;
					
				when INSERT_TOK =>
					if CHANSEL = "111" then
						STATE_READ	<= DONE;
					elsif BLKSEL = "101" then
						STATE_READ 	<= IDLE;
					else
						if CHANSEL = "110" or CHANSEL = "100" or CHANSEL = "101" then
							TOK_CNT 		<=  "10";
							STATE_READ 	<= WAIT_TOK;
						else
							TOK_CNT 		<= "01";
							STATE_READ 	<= WAIT_TOK;
						end if;
					end if;
						
				when WAIT_TOK =>
					TOK_CNT 		<= "00";
					W_EN_TEMP 	<= '1';
					STATE_READ	<= WRITE_RAM;
					
				when WRITE_RAM=>	

					if READ_CNT > (BLOCKSIZE-1) then   
						W_EN_TEMP 	<= '0';
						READ_CNT		<= (others=>'0');
						BLKSEL 		<= BLKSEL + 1;
						STATE_READ	<= INSERT_TOK; 
					else
						WADDR_TEMP 	<= WADDR_TEMP + 1;
						READ_CNT 	<= READ_CNT + 1;
					
					end if;				
					
				when DONE =>
					RD_CLK_EN <= '0';
					START <= '1';
					
				when others =>
					STATE_READ 	<= IDLE;
				
			end case;

		elsif rising_edge(xRD_CLKIN) and RAMP_DONE = '1' then
			WADDR 	<= WADDR_TEMP;
			W_EN 		<= W_EN_TEMP;
		end if;
	end process;
	
	xRAM_16bit : RAM_16bit
	port map(
			xW_EN			=> W_EN,
			xR_EN			=> xRAMR_EN,
			xWRAM_CLK	=> xRD_CLKIN, --not(xRD_CLKIN),
			xRRAM_CLK   => xRAM_CLK,
			xWR_ADDRESS => WADDR,
			xRD_ADDRESS	=> xRD_ADDRESS,
			xWRITE		=> xRAWDATA,
			xREAD			=> xRAMDATA);

	xWILK_FDBK	:	Wilkinson_Feedback_Loop
	port map(
			ENABLE_FEEDBACK 		=> not(xCLR_ALL),     
         RESET_FEEDBACK 		=> xRESETFDBK,      
         REFRESH_CLOCK  		=> xREFRSH_CLK,     
         DAC_SYNC_CLOCK   		=> xDAC_CLK,   
         WILK_MONITOR_BIT   	=> xRO_MON, 
         DESIRED_COUNT_VALUE 	=> xDESIRECOUNT,
         CURRENT_COUNT_VALUE 	=> xCOUNT_VALUE,
         DESIRED_DAC_VALUE   	=> xDAC_VALUE);
			
    xVCDL_MON : VCDL_Monitor_Loop 
        port map(
                                RESET_FEEDBACK      => xRESETFDBK,
                                REFRESH_CLOCK       => xREFRSH_CLK,
                                VCDL_MONITOR_BIT    => xDLL_CLOCK,
                                CURRENT_COUNT_VALUE => xVCDL_COUNT);
						
end BEHAVIORAL;
	
		
		
--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	AC_control
-- author		: 	ejo
-- date			: 	4/2012
-- description	:  ASIC & DAC control for Analog card 
--						(5 psec-4's + 4 DAC's)
--------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Definition_Pool.all;

entity AC_CONTROL is 
	port(	
		xCLK_IN_40M_JC			:	in		std_logic;   	--40MHz clock from jitter cleaner
		xCLK_FAST				:	in		std_logic;	   	--faster clock (160M) from PLL
		xCLR_ALL				:	in		std_logic;		--global clear
		xDAC_CLK				:	in		std_logic;		--DAC clock from PLL (~500KHz)
		xREFRESH_CLK			:	in		std_logic;		--slow refresh clock (10 Hz);
		
		xCHIPSELECT				:	in		AC_bitarray;	--select chip to trigger
		xCC_TRIG					:	in		std_logic;		--trigger in from central card
		xDC_TRIG					:	in		std_logic;		--trigger in from digital card
		
		xRESET_WILK_FDBK		:	in			AC_bitarray;	--reset wilk fdbk
		xWILK_DESIRED_CNT_OUT:	out		Word_array;		--target count value (defined in defs)
		xWILK_DESIRED_CNT_IN	:	in		Word_array;			--target count value (defined in defs)
		xWILK_COUNT				:	out		Word_array;		--output current count value
		xRO_DAC_VALUE			: 	out		Word_array;		--servo-cntrl DAC value

		xCHANTOREAD				:	in		std_logic_vector(5 downto 0); --select channels to read 		
		
		--PSEC ASIC control signals--
		PSEC_A_overflow :  IN  STD_LOGIC;
		PSEC_B_overflow :  IN  STD_LOGIC;
		PSEC_C_overflow :  IN  STD_LOGIC;
		PSEC_D_overflow :  IN  STD_LOGIC;
		PSEC_E_overflow :  IN  STD_LOGIC;
		PSEC_A_RO_mon :  IN  STD_LOGIC;
		PSEC_B_RO_mon :  IN  STD_LOGIC;
		PSEC_C_RO_mon :  IN  STD_LOGIC;
		PSEC_D_RO_mon :  IN  STD_LOGIC;
		PSEC_E_RO_mon :  IN  STD_LOGIC;
		PSEC_A_DLout :  IN  STD_LOGIC;
		PSEC_B_DLout :  IN  STD_LOGIC;
		PSEC_C_DLout :  IN  STD_LOGIC;
		PSEC_D_DLout :  IN  STD_LOGIC;
		PSEC_E_DLout :  IN  STD_LOGIC;
		PSEC_A_data :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		PSEC_A_trig :  IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
		PSEC_B_data :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		PSEC_B_trig :  IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
		PSEC_C_data :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		PSEC_C_trig :  IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
		PSEC_D_data :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		PSEC_D_trig :  IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
		PSEC_E_data :  IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
		PSEC_E_trig :  IN  STD_LOGIC_VECTOR(5 DOWNTO 0);		
		PSEC_A_DLLreset :  OUT  STD_LOGIC;
		PSEC_B_DLLreset :  OUT  STD_LOGIC;
		PSEC_C_DLLreset :  OUT  STD_LOGIC;
		PSEC_D_DLLreset :  OUT  STD_LOGIC;
		PSEC_E_DLLreset :  OUT  STD_LOGIC;
		PSEC_A_trigCLEAR :  OUT  STD_LOGIC;
		PSEC_B_trigCLEAR :  OUT  STD_LOGIC;
		PSEC_C_trigCLEAR :  OUT  STD_LOGIC;
		PSEC_D_trigCLEAR :  OUT  STD_LOGIC;
		PSEC_E_trigCLEAR :  OUT  STD_LOGIC;
		PSEC_A_rampSTART :  OUT  STD_LOGIC;
		PSEC_B_rampSTART :  OUT  STD_LOGIC;
		PSEC_C_rampSTART :  OUT  STD_LOGIC;
		PSEC_D_rampSTART :  OUT  STD_LOGIC;
		PSEC_E_rampSTART :  OUT  STD_LOGIC;
		PSEC_A_RD_CLK :  OUT  STD_LOGIC;
		PSEC_B_RD_CLK :  OUT  STD_LOGIC;
		PSEC_C_RD_CLK :  OUT  STD_LOGIC;
		PSEC_D_RD_CLK :  OUT  STD_LOGIC;
		PSEC_E_RD_CLK :  OUT  STD_LOGIC;
		PSEC_A_EXT_trig :  OUT  STD_LOGIC;
		PSEC_B_EXT_trig :  OUT  STD_LOGIC;
		PSEC_C_EXT_trig :  OUT  STD_LOGIC;
		PSEC_D_EXT_trig :  OUT  STD_LOGIC;
		PSEC_E_EXT_trig :  OUT  STD_LOGIC;
		PSEC_A_clearADC :  OUT  STD_LOGIC;
		PSEC_B_clearADC :  OUT  STD_LOGIC;
		PSEC_C_clearADC :  OUT  STD_LOGIC;
		PSEC_D_clearADC :  OUT  STD_LOGIC;
		PSEC_E_clearADC :  OUT  STD_LOGIC;
		PSEC_A_RO_enable :  OUT  STD_LOGIC;
		PSEC_B_RO_enable :  OUT  STD_LOGIC;
		PSEC_C_RO_enable :  OUT  STD_LOGIC;
		PSEC_D_RO_enable :  OUT  STD_LOGIC;
		PSEC_E_RO_enable :  OUT  STD_LOGIC;		
		PSEC_A_ADClatch :  OUT  STD_LOGIC;
		PSEC_B_ADClatch :  OUT  STD_LOGIC;
		PSEC_C_ADClatch :  OUT  STD_LOGIC;
		PSEC_D_ADClatch :  OUT  STD_LOGIC;
		PSEC_E_ADClatch :  OUT  STD_LOGIC;
		PSEC_A_ChanDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_A_TokDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_A_TOKin :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		PSEC_B_ChanDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_B_TokDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_B_TOKin :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		PSEC_C_ChanDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_C_TokDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_C_TOKin :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		PSEC_D_ChanDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_D_TokDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_D_TOKin :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);
		PSEC_E_ChanDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_E_TokDECODE :  OUT  STD_LOGIC_VECTOR(2 DOWNTO 0);
		PSEC_E_TOKin :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0);		
		--end--
	
		xEVENT_CNT				:  	out		Word_array;	--internal event counter
			
		xTRIG_SIGN				:	out		std_logic;		--global trig sign
		xRO_FREQ					:	out		std_logic;		--global RO freq
															--(both set in def. pool)		
		xRAMR_EN				:	in		AC_bitarray;	--enable read from RAM
		xRAM_CLK				:	in		std_logic;		--RAM read clock
		xRD_ADDRESS				:	in		std_logic_vector(RAM_ADR_SIZE-1 downto 0);  --RAM read address
		xRD_CLK					:	in		std_logic;		--read clock in (from PLL) 10-40MHz		
		xRAMDATA				:	out		ChipData_array;	--13 bit RAM-stored data	
		xSTART					:	out		AC_bitarray;	--OK to start transfer 
		xDONE					:	in		AC_bitarray;	--transfer done
		
		xDAC_SPI_CLK1				:	out	std_logic;			--DAC contrl signals...
		xDAC_SPI_CLK2				:	out	std_logic;
		xDAC_SPI_CLK3				:  out	std_logic;
		xDAC_SPI_LD1				:	out 	std_logic;
		xDAC_SPI_LD2				:	out	std_logic;
		xDAC_SPI_LD3				:  out	std_logic;
		xDAC_SPI_CLR1				:	out	std_logic;
		xDAC_SPI_CLR2				:	out	std_logic;
		xDAC_SPI_CLR3				:  out	std_logic;
		xDAC_SPI_DATIN1			:	out	std_logic;
		xDAC_SPI_DATIN2			:	out	std_logic;
		xDAC_SPI_DATIN3			:  out	std_logic;
		xDAC_SPI_DATOUT1			:	in		std_logic;
		xDAC_SPI_DATOUT2			:	in		std_logic;			
		xDAC_SPI_DATOUT3			:  in		std_logic;
		
		xSET_TRIG_THRESH0		:	in	std_logic_vector(11 downto 0);
		xSET_TRIG_THRESH1		:	in	std_logic_vector(11 downto 0);
		xSET_TRIG_THRESH2		:	in	std_logic_vector(11 downto 0);
		xSET_TRIG_THRESH3		:	in	std_logic_vector(11 downto 0);
		xSET_TRIG_THRESH4		:	in	std_logic_vector(11 downto 0);
		
		xSET_VBIAS0				:	in	std_logic_vector(11 downto 0);
		xSET_VBIAS1				:	in	std_logic_vector(11 downto 0);
		xSET_VBIAS2				:	in	std_logic_vector(11 downto 0);
		xSET_VBIAS3				:	in	std_logic_vector(11 downto 0);
		xSET_VBIAS4				:	in	std_logic_vector(11 downto 0);	--...end
		
		xRESET_SELF_TRIG		:  in	std_logic;
		xDLL_RESET_FLAG		:  in AC_bitarray;
		
		xPLL_LOCK				:  in	std_logic;
		
		xSET_DLL_VDD0				:	in	std_logic_vector(11 downto 0);
		xSET_DLL_VDD1				:	in	std_logic_vector(11 downto 0);
		xSET_DLL_VDD2				:	in	std_logic_vector(11 downto 0);
		xSET_DLL_VDD3				:	in	std_logic_vector(11 downto 0);
		xSET_DLL_VDD4				:	in	std_logic_vector(11 downto 0);	--...end

		xSELF_TRIGGER_MASK		: in 	std_logic_vector(29 downto 0);
		xOPENSPACE	: in	std_logic_vector(11 downto 0); --open dataspace for config of this block
		
		xCLK_10Hz				: in	std_logic;
		xTRIG_VALID				: in 	std_logic;
		xDONE_SIGNAL_FROM_SYS: in	std_logic;
		
		xSELF_TRIGGER_SETTING_0 : in std_logic_vector(10 downto 0);
		xSELF_TRIGGER_SETTING_1 : in std_logic_vector(10 downto 0);

		xRESET_TIMESTAMPS		: in	std_logic;

		MONITOR_PSEC0	:	out	std_logic_vector(23 downto 0);
		MONITOR_PSEC1	:	out	std_logic_vector(23 downto 0);
		MONITOR_PSEC2	:	out	std_logic_vector(23 downto 0);
		MONITOR_PSEC3	:	out	std_logic_vector(23 downto 0);
		MONITOR_PSEC4	:	out	std_logic_vector(23 downto 0);
						
		xLATCHED_SELFTRIG_CHANNEL	: out SelfTrig_array;
		xSAMPLE_BIN_LOCATION			: out	SampleBin_array;
		
		xTRIG_THRESHES					: out	Word_array;
		xVBIASES							: out	Word_array;
		
		xTRIG_INFO						: out Word_array;
		xSAMPLE_INFO					: out Word_array;
		xSELF_TRIG_RATES				: out rate_count_array;
		xRATE_ONLY						: out std_logic;
		xDIG_TRIG						:  out	std_logic;
		xTRIG_SIGNAL_REG				: out	std_logic_vector(2 downto 0);
		xVCDL_COUNT						: out DWord_array);
		
end AC_CONTROL;

-------------------------------------------------------------
architecture BEHAVIORAL of AC_CONTROL is
-------------------------------------------------------------
	type Monitor_array is array(4 downto 0) of std_logic_vector(23 downto 0);
	type RawData_array is array(4 downto 0) of std_logic_vector(12 downto 0);
	signal MONITOR_ASIC		:	Monitor_array;
	signal SELFTRIG        	:  SelfTrig_array; --psec-4 internal trig outputs (not used currently) 	
	signal TRIG_FLAG			:	AC_bitarray;
	signal LATCHED_SELFTRIG_CHANNEL : SelfTrig_array;

	signal GLOB_SELF_TRIG_OR		:	std_logic;
	
	signal DLL_OUTCLOCK		:	AC_bitarray;
	signal DLL_RESET			:	AC_bitarray;
	signal SAMPLE_BIN_LOCATION	: SampleBin_array;
	
	signal RO_MON				: 	AC_bitarray;
	signal RESET_WILK_FDBK	:	AC_bitarray;
	signal RO_DAC_VALUE		: 	DAC_array;	
	signal RO_DESIRED_COUNT_VALUE : Word_array;
	
	signal start_adc_flag   : std_logic;
	signal trigger_flag		: std_logic;
	signal self_trigger_clear_flag : std_logic;
	signal SELF_TRIG_SIGN  : std_logic;
	
	signal RAMP					:	AC_bitarray;
	signal CLEARADC			:	AC_bitarray;
	signal RO_EN				: 	AC_bitarray;
	signal ADCLATCH			:	AC_bitarray;
	signal RD_CLKOUT			:	AC_bitarray;
	signal RAMR_EN				:	AC_bitarray;
	signal RAWDATA				:	RawData_array;

	signal TOKIN1				:	AC_bitarray;
	signal TOKIN2				:	AC_bitarray;

	signal CHAN_SEL			:	Address_array;
	signal BLOCK_SEL			:	Address_array;

	signal CLK_FAST			:	std_logic;
	signal MCLK					:	std_logic;
	signal EXTTRIG				:	std_logic;
-------------------------------------------------------------
--	components
-------------------------------------------------------------	
component psec4_control 
	port(
		xMCLK			:	in		std_logic;			--40MHz	
		xCLKFAST		:	in		std_logic;			--faster clock to register trigger signals (160M ?)
		xCHIPSELECT	:	in		std_logic;			--enable trigger to specified PSEC-4 ASIC
		xTRIG_FLAG	:	in		std_logic;			
		xCLR_ALL		: 	in		std_logic;			--global reset (clears high)
		xDONE			:	in		std_logic;			--USB, etc. write done signal

		xDLL_RESET_FLAG	: in	std_logic;
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
end component;

component psec4_trigger_GLOBAL
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
			xSELF_TRIGGER_SETTING_0: in	std_logic_vector(10 downto 0); --open dataspace for config of this block
			xSELF_TRIGGER_SETTING_1: in	std_logic_vector(10 downto 0); --open dataspace for config of this block
			
			xRESET_TRIG_FLAG		: in	std_logic;
			
			xDLL_RESET				: in	std_logic;
			xPLL_LOCK				: in	std_logic;
			xTRIG_VALID   			: in	std_logic;
			xDONE_FROM_SYS			: in	std_logic;
			
			xTRIGGER_OUT			: out	std_logic;
			xSTART_ADC				: out std_logic;
			xTRIG_SIGNAL_REG		: out	std_logic_vector(2 downto 0);
			xRESET_TIMESTAMPS		: in	std_logic;

			xSELFTRIG_CLEAR		: out	std_logic;
			
			xRATE_ONLY				: out std_logic;

			xPSEC4_TRIGGER_INFO_1: out Word_array;
			xPSEC4_TRIGGER_INFO_2: out Word_array;
			xPSEC4_TRIGGER_INFO_3: out Word_array;
			
			xSAMPLE_BIN				: out	std_logic_vector(3 downto 0);
			xSELF_TRIG_RATES		: out rate_count_array;
			xSELF_TRIG_SIGN		: out std_logic);
			
end component;

component dac_main_daisychain
	port(
			xCLKDAC				: in 		std_logic;  	--internal DACclk
			xCLK_REFRESH		: in		std_logic;  	--internal REFRESHclk
			xCLR_ALL			: in		std_logic;
			xSDATOUT1			: in		std_logic;
			xSDATOUT2			: in		std_logic;
			xSDATOUT3			: in		std_logic;
			
			xTRIG_THRESH0		: in		std_logic_vector (11 downto 0);
			xTRIG_THRESH1		: in		std_logic_vector (11 downto 0);
			xTRIG_THRESH2		: in		std_logic_vector (11 downto 0);
			xTRIG_THRESH3		: in		std_logic_vector (11 downto 0);
			xTRIG_THRESH4		: in		std_logic_vector (11 downto 0);
			
			xVBIAS0				: in		std_logic_vector (11 downto 0);
			xVBIAS1				: in		std_logic_vector (11 downto 0);
			xVBIAS2				: in		std_logic_vector (11 downto 0);
			xVBIAS3				: in		std_logic_vector (11 downto 0);
			xVBIAS4				: in		std_logic_vector (11 downto 0);			

			xPROVDD0			: in		std_logic_vector (11 downto 0);
			xPROVDD1			: in		std_logic_vector (11 downto 0);
			xPROVDD2			: in		std_logic_vector (11 downto 0);
			xPROVDD3			: in		std_logic_vector (11 downto 0);			
			xPROVDD4			: in		std_logic_vector (11 downto 0);
			
			xDLL_VDD0		: in		std_logic_vector (11 downto 0);
			xDLL_VDD1		: in		std_logic_vector (11 downto 0);
			xDLL_VDD2		: in		std_logic_vector (11 downto 0);
			xDLL_VDD3		: in		std_logic_vector (11 downto 0);
			xDLL_VDD4		: in		std_logic_vector (11 downto 0);
			
			xDACCLK1			: out		std_logic;  	--copy of DACclk to external
			xDACCLK2			: out		std_logic;  	--ditto, second DAC
			xDACCLK3			: out		std_logic;
			xLOAD1				: out 	std_logic;
			xLOAD2				: out		std_logic;  	--Load signal (active low)
			xLOAD3				: out		std_logic;
			xCLR_BAR1			: out 	std_logic;
			xCLR_BAR2			: out		std_logic;  	--Clear (currently inactive)
			xCLR_BAR3			: out		std_logic;
			xSDATIN1			: out 	std_logic;  	--serial data to DAC1
			xSDATIN2			: out		std_logic; 	--serial data to DAC2			
			xSDATIN3			: out		std_logic);
end component;			

-------------------------------------------------------------
begin
-------------------------------------------------------------
	
	xRO_FREQ 			<= SETFREQ;
	--xTRIG_SIGN			<= TRIGSIGN;
	CLK_FAST				<=	xCLK_FAST;
	MCLK					<=	xCLK_IN_40M_JC;
	
	MONITOR_PSEC0		<=	MONITOR_ASIC(0);
	MONITOR_PSEC1		<=	MONITOR_ASIC(1);
	MONITOR_PSEC2		<=	MONITOR_ASIC(2);
	MONITOR_PSEC3		<=	MONITOR_ASIC(3);
	MONITOR_PSEC4		<=	MONITOR_ASIC(4);
	
	RO_DESIRED_COUNT_VALUE(0)<=xWILK_DESIRED_CNT_IN(0); 
	RO_DESIRED_COUNT_VALUE(1)<=xWILK_DESIRED_CNT_IN(0); 
	RO_DESIRED_COUNT_VALUE(2)<=xWILK_DESIRED_CNT_IN(0);
	RO_DESIRED_COUNT_VALUE(3)<=xWILK_DESIRED_CNT_IN(0);
	RO_DESIRED_COUNT_VALUE(4)<=xWILK_DESIRED_CNT_IN(0);
	
	xTRIG_THRESHES(0) <= x"0" & xSET_TRIG_THRESH0;
	xTRIG_THRESHES(1) <= x"0" & xSET_TRIG_THRESH1;
	xTRIG_THRESHES(2) <= x"0" & xSET_TRIG_THRESH2;
	xTRIG_THRESHES(3) <= x"0" & xSET_TRIG_THRESH3;
	xTRIG_THRESHES(4) <= x"0" & xSET_TRIG_THRESH4;
	
	xVBIASES(0)			<= x"0" & xSET_VBIAS0;
	xVBIASES(1)			<= x"0" & xSET_VBIAS1;
	xVBIASES(2)			<= x"0" & xSET_VBIAS2;
	xVBIASES(3)			<= x"0" & xSET_VBIAS3;
	xVBIASES(4)			<= x"0" & xSET_VBIAS4;
	
	xWILK_DESIRED_CNT_OUT(0)<=	RO_DESIRED_COUNT_VALUE(0); 
	xWILK_DESIRED_CNT_OUT(1)<=	RO_DESIRED_COUNT_VALUE(1); 
	xWILK_DESIRED_CNT_OUT(2)<=	RO_DESIRED_COUNT_VALUE(2); 
	xWILK_DESIRED_CNT_OUT(3)<=	RO_DESIRED_COUNT_VALUE(3); 
	xWILK_DESIRED_CNT_OUT(4)<=	RO_DESIRED_COUNT_VALUE(4); 
	xRO_DAC_VALUE(0) 	<= x"0" & RO_DAC_VALUE(0);
	xRO_DAC_VALUE(1) 	<= x"0" & RO_DAC_VALUE(1);
	xRO_DAC_VALUE(2) 	<= x"0" & RO_DAC_VALUE(2);
	xRO_DAC_VALUE(3) 	<= x"0" & RO_DAC_VALUE(3);
	xRO_DAC_VALUE(4) 	<= x"0" & RO_DAC_VALUE(4);

	RAWDATA(0)(12)		<= PSEC_A_overflow;
	RAWDATA(1)(12)		<= PSEC_B_overflow;
	RAWDATA(2)(12)		<= PSEC_C_overflow;
	RAWDATA(3)(12)		<= PSEC_D_overflow;
	RAWDATA(4)(12)		<= PSEC_E_overflow;	
	RO_MON(0)			<= PSEC_A_RO_mon;
	RO_MON(1)			<= PSEC_B_RO_mon;
	RO_MON(2)			<= PSEC_C_RO_mon;
	RO_MON(3)			<= PSEC_D_RO_mon;
	RO_MON(4)			<= PSEC_E_RO_mon;
	DLL_OUTCLOCK(0)	<=	PSEC_A_DLout;	
	DLL_OUTCLOCK(1)	<=	PSEC_B_DLout;	
	DLL_OUTCLOCK(2)	<=	PSEC_C_DLout;	
	DLL_OUTCLOCK(3)	<=	PSEC_D_DLout;	
	DLL_OUTCLOCK(4)	<=	PSEC_E_DLout;	
	RAWDATA(0)(11 downto 0)	<=	PSEC_A_data;
	RAWDATA(1)(11 downto 0)	<=	PSEC_B_data;
	RAWDATA(2)(11 downto 0)	<=	PSEC_C_data;
	RAWDATA(3)(11 downto 0)	<=	PSEC_D_data;
	RAWDATA(4)(11 downto 0)	<=	PSEC_E_data;
	SELFTRIG(0)			<=	PSEC_A_trig;	
	SELFTRIG(1)			<=	PSEC_B_trig;	
	SELFTRIG(2)			<=	PSEC_C_trig;	
	SELFTRIG(3)			<=	PSEC_D_trig;	
	SELFTRIG(4)			<=	PSEC_E_trig;	
	PSEC_A_DLLreset 	<=	DLL_RESET(0);
	PSEC_B_DLLreset 	<=	DLL_RESET(1);
	PSEC_C_DLLreset 	<=	DLL_RESET(2);
	PSEC_D_DLLreset 	<=	DLL_RESET(3);
	PSEC_E_DLLreset 	<=	DLL_RESET(4);
	PSEC_A_trigCLEAR	<=	self_trigger_clear_flag;
	PSEC_B_trigCLEAR 	<=	self_trigger_clear_flag;
	PSEC_C_trigCLEAR 	<=	self_trigger_clear_flag;
	PSEC_D_trigCLEAR 	<=	self_trigger_clear_flag;
	PSEC_E_trigCLEAR	<=	self_trigger_clear_flag;
	PSEC_A_rampSTART 	<=	RAMP(0);
	PSEC_B_rampSTART 	<=	RAMP(1);
	PSEC_C_rampSTART 	<=	RAMP(2);
	PSEC_D_rampSTART 	<=	RAMP(3);
	PSEC_E_rampSTART	<=	RAMP(4);
	PSEC_A_RD_CLK		<=	RD_CLKOUT(0); 
	PSEC_B_RD_CLK		<=	RD_CLKOUT(1); 
	PSEC_C_RD_CLK 		<=	RD_CLKOUT(2);
	PSEC_D_RD_CLK 		<=	RD_CLKOUT(3);
	PSEC_E_RD_CLK 		<=	RD_CLKOUT(4);
	PSEC_A_EXT_trig 	<=	trigger_flag; --TRIG_FLAG(0); 	--TRIG_FLAG(0); 
	PSEC_B_EXT_trig 	<=	trigger_flag; --TRIG_FLAG(0); 	--TRIG_FLAG(1);
	PSEC_C_EXT_trig	<=	trigger_flag; --TRIG_FLAG(0); 
	PSEC_D_EXT_trig 	<=	trigger_flag; --TRIG_FLAG(0);	--TRIG_FLAG(3);
	PSEC_E_EXT_trig 	<=	trigger_flag; --TRIG_FLAG(0);  --TRIG_FLAG(4);
	PSEC_A_clearADC 	<=	CLEARADC(0);
	PSEC_B_clearADC 	<=	CLEARADC(1);
	PSEC_C_clearADC 	<=	CLEARADC(2);
	PSEC_D_clearADC 	<=	CLEARADC(3);
	PSEC_E_clearADC 	<=	CLEARADC(4);
	PSEC_A_RO_enable 	<=	not RO_EN(0);
	PSEC_B_RO_enable 	<=	not RO_EN(1);
	PSEC_C_RO_enable 	<=	not RO_EN(2);
	PSEC_D_RO_enable 	<=	not RO_EN(3);
	PSEC_E_RO_enable 	<=	not RO_EN(4);	
	PSEC_A_ADClatch 	<=	ADCLATCH(0);
	PSEC_B_ADClatch 	<=	ADCLATCH(1);
	PSEC_C_ADClatch 	<=	ADCLATCH(2);
	PSEC_D_ADClatch 	<=	ADCLATCH(3);
	PSEC_E_ADClatch 	<=	ADCLATCH(4);
	
	PSEC_A_ChanDECODE(0) <=	CHAN_SEL(0)(0);
	PSEC_A_ChanDECODE(1) <=	CHAN_SEL(0)(1);
	PSEC_A_ChanDECODE(2) <=	CHAN_SEL(0)(2);
	
	PSEC_A_TokDECODE		<=	BLOCK_SEL(0);
	PSEC_A_TOKin	 		<=	TOKIN2(0) & TOKIN1(0);
	PSEC_B_ChanDECODE 	<=	CHAN_SEL(1);
	PSEC_B_TokDECODE 		<=	BLOCK_SEL(1);
	PSEC_B_TOKin 			<=	TOKIN2(1) & TOKIN1(1);
	PSEC_C_ChanDECODE 	<=	CHAN_SEL(2);
	PSEC_C_TokDECODE 		<=	BLOCK_SEL(2);
	PSEC_C_TOKin 			<=	TOKIN2(2) & TOKIN1(2);
	PSEC_D_ChanDECODE 	<=	CHAN_SEL(3);
	PSEC_D_TokDECODE 		<=	BLOCK_SEL(3);
	PSEC_D_TOKin			<=	TOKIN2(3) & TOKIN1(3);
	PSEC_E_ChanDECODE 	<=	CHAN_SEL(4);
	PSEC_E_TokDECODE 		<=	BLOCK_SEL(4);
	PSEC_E_TOKin 			<=	TOKIN2(4) & TOKIN1(4);
	
	xTRIG_SIGN  <= SELF_TRIG_SIGN;
	xDIG_TRIG	<= start_adc_flag;
--	-----------------------------------------------------------------------------------------------
--   --info to send to DAQ
--	xTRIG_INFO(0)		<= "000" & SELF_TRIG_SIGN & xSELF_TRIGGER_SETTING;
--	xTRIG_INFO(1)		<= x"0" & xSELF_TRIGGER_MASK;
--	xSAMPLE_INFO(0)	<= x"00" & "000" &	SAMPLE_BIN_LOCATION(0) & "0";
--	xSAMPLE_INFO(1)	<= x"00" & "000" &	SAMPLE_BIN_LOCATION(1) & "0";
--	xSAMPLE_INFO(2)	<= x"00" & "000" &	SAMPLE_BIN_LOCATION(2) & "0";
--	xSAMPLE_INFO(3)	<= x"00" & "000" &	SAMPLE_BIN_LOCATION(3) & "0";
--	xSAMPLE_INFO(4)	<= x"00" & "000" &	SAMPLE_BIN_LOCATION(4) & "0";
--	-----------------------------------------------------------------------------------------------
	AC_TIMING_CONTROL	:	for i in 4 downto 0 generate
		psec4_timing_control	:	psec4_control
		port map(
			xMCLK				=>		MCLK,
			xCLKFAST			=> 	CLK_FAST,
			xCHIPSELECT	   => 	xCHIPSELECT(i),	
			xTRIG_FLAG		=>    start_adc_flag,	
			xCLR_ALL			=>		xCLR_ALL,
			xDONE				=>		xDONE(i),
			
			xDLL_RESET_FLAG=>		xDLL_RESET_FLAG(i),
			xDLL_CLOCK		=>		DLL_OUTCLOCK(i),
			xDLL_RESET		=>		DLL_RESET(i),
			
			xDAC_CLK			=>		xDAC_CLK,
			xREFRSH_CLK		=>		xCLK_10Hz,
			xRO_MON			=>		RO_MON(i),
			xDESIRECOUNT	=>		RO_DESIRED_COUNT_VALUE(i),
			xRESETFDBK		=>		xRESET_WILK_FDBK(i),
			xCOUNT_VALUE	=>		xWILK_COUNT(i),
			xDAC_VALUE  	=>		RO_DAC_VALUE(i),		
			
			xRAMP				=>		RAMP(i),
			xCLEARADC		=>		CLEARADC(i),
			xRO_EN			=>		RO_EN(i),	
			xADCLATCH		=>		ADCLATCH(i),
			
			xRD_CLKIN		=>		xRD_CLK,
			xCHANTOREAD		=>		xCHANTOREAD,
			xRD_CLKOUT		=>		RD_CLKOUT(i),
			xRAM_CLK			=>		xRAM_CLK,
	--		xRAMW_EN		
			xRAMR_EN			=>		xRAMR_EN(i),
			xRD_ADDRESS		=>		xRD_ADDRESS,
			xRAWDATA			=>		RAWDATA(i),
			xSELF_TRIG_EN  =>    xSELF_TRIGGER_SETTING_0(0),
			xTRIG_VALID	   =>		xTRIG_VALID,
			xDONE_FROM_SYS =>    xDONE_SIGNAL_FROM_SYS,

			xRAMDATA			=>		xRAMDATA(i),
			xTOK_IN1			=>		TOKIN1(i),
			xTOK_IN2			=>		TOKIN2(i),
			xCHAN_SEL		=>		CHAN_SEL(i),
			xBLOCK_SEL		=>		BLOCK_SEL(i),
			xSTART			=>		xSTART(i),
			xVCDL_COUNT    =>    xVCDL_COUNT(i),
			xMONITOR			=>		MONITOR_ASIC(i));	
	end generate AC_TIMING_CONTROL;
	
	AC_TRIGGER_CONTROL	:	psec4_trigger_GLOBAL
		port map(
			xTRIG_CLK			=> CLK_FAST,
			xMCLK					=> MCLK,
			xCLR_ALL				=> xCLR_ALL,
			xDONE					=> xDONE(0),
			xSLOW_CLK			=> xREFRESH_CLK,	
			
			xCC_TRIG				=> xCC_TRIG,
			xDC_TRIG				=> xDC_TRIG,
			
			xSELFTRIG_0			=> SELFTRIG(0),
			xSELFTRIG_1			=> SELFTRIG(1),
			xSELFTRIG_2			=> SELFTRIG(2),
			xSELFTRIG_3			=> SELFTRIG(3),
			xSELFTRIG_4			=> SELFTRIG(4),
			
			xSELF_TRIGGER_MASK	=>  xSELF_TRIGGER_MASK,
			xSELF_TRIGGER_SETTING_0=>xSELF_TRIGGER_SETTING_0,
			xSELF_TRIGGER_SETTING_1=>xSELF_TRIGGER_SETTING_1,
			xRESET_TRIG_FLAG		=> xRESET_SELF_TRIG,
			
			xDLL_RESET			=>	DLL_RESET(0),
			xPLL_LOCK			=>	xPLL_LOCK,
			xTRIG_VALID   		=> xTRIG_VALID,
			xDONE_FROM_SYS		=> xDONE_SIGNAL_FROM_SYS,
			xRESET_TIMESTAMPS	=> xRESET_TIMESTAMPS,
		
			xTRIGGER_OUT		=> trigger_flag,
			xSTART_ADC			=>  start_adc_flag,
			xTRIG_SIGNAL_REG  => xTRIG_SIGNAL_REG,

			
			xSELFTRIG_CLEAR	=>  self_trigger_clear_flag,
			
			xRATE_ONLY			=> xRATE_ONLY,

			xPSEC4_TRIGGER_INFO_1	=> xTRIG_INFO,
			xPSEC4_TRIGGER_INFO_2	=> xSAMPLE_INFO,
			xPSEC4_TRIGGER_INFO_3	=>	xEVENT_CNT,
			
			xSAMPLE_BIN			=> SAMPLE_BIN_LOCATION(0),
			xSELF_TRIG_RATES	=> xSELF_TRIG_RATES,
			xSELF_TRIG_SIGN   => SELF_TRIG_SIGN);

	xDAC_MAIN_CNTRL	:	dac_main_daisychain
	port map(
			xCLKDAC			=> 	xDAC_CLK,	
			xCLK_REFRESH	=>		xCLK_10Hz,
			xCLR_ALL			=>		xCLR_ALL,	
			xSDATOUT1		=>		xDAC_SPI_DATOUT1,	
			xSDATOUT2		=>		xDAC_SPI_DATOUT2,
			xSDATOUT3		=>		xDAC_SPI_DATOUT3,
			
			xTRIG_THRESH0	=>		xSET_TRIG_THRESH4,	
			xTRIG_THRESH1	=>		xSET_TRIG_THRESH3,
			xTRIG_THRESH2	=>		xSET_TRIG_THRESH2,	
			xTRIG_THRESH3	=>		xSET_TRIG_THRESH1,
			xTRIG_THRESH4	=>		xSET_TRIG_THRESH0,	
			 
			xVBIAS0			=>		xSET_VBIAS4,	
			xVBIAS1			=>		xSET_VBIAS3,	
			xVBIAS2			=>		xSET_VBIAS2,	
			xVBIAS3			=>		xSET_VBIAS1,	
			xVBIAS4			=>		xSET_VBIAS0,				

			xPROVDD0		=>			RO_DAC_VALUE(4),
			xPROVDD1		=>			RO_DAC_VALUE(3),	
			xPROVDD2		=>			RO_DAC_VALUE(2),	
			xPROVDD3		=>			RO_DAC_VALUE(1),			
			xPROVDD4		=>			RO_DAC_VALUE(0),	
			
			xDLL_VDD0		=> 	xSET_DLL_VDD0,
			xDLL_VDD1		=> 	xSET_DLL_VDD1,
			xDLL_VDD2		=> 	xSET_DLL_VDD2,
			xDLL_VDD3		=> 	xSET_DLL_VDD3,
			xDLL_VDD4		=> 	xSET_DLL_VDD4,
			
			xDACCLK1		=>			xDAC_SPI_CLK1,	
			xDACCLK2		=>			xDAC_SPI_CLK2,		
			xDACCLK3		=>			xDAC_SPI_CLK3,
			xLOAD1			=>		xDAC_SPI_LD1,		
			xLOAD2			=>		xDAC_SPI_LD2,		
			xLOAD3			=>		xDAC_SPI_LD3,
			xCLR_BAR1		=>		xDAC_SPI_CLR1,	
			xCLR_BAR2		=>		xDAC_SPI_CLR2,	
			xCLR_BAR3		=>		xDAC_SPI_CLR3,
			xSDATIN1		=>			xDAC_SPI_DATIN1,	
			xSDATIN2		=>			xDAC_SPI_DATIN2,
			xSDATIN3		=>			xDAC_SPI_DATIN3);
			
		
end BEHAVIORAL;

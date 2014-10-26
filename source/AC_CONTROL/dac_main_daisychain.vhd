------------------------------------------------------------------------------
------------------------------------------------------------------------------
-- AUTHOR: ejo                                                              --
-- DATE: 3/2010                                                          	--
-- PROJECT: psTDC_2 tester firmware                                         --
-- NAME: DAC_MAIN_DAISYCHAIN                                                --
-- Description:                                                             --
--      DAC module                                                          --
--    	for use with DAC_SERIALIZATION_DAISY.vhd:                          	--
--    	parallel control of two octal DACs 									--
--																			--	
-- MODIFIED: 1/2012 														--
-- PROJECT:	PSEC-4 Analog Card												--                                                                    --
------------------------------------------------------------------------------
------------------------------------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Definition_Pool.all;

entity DAC_MAIN_DAISYCHAIN is
	port(
			xCLKDAC			: in 		std_logic;  	--internal DACclk
			xCLK_REFRESH	: in		std_logic;  	--internal REFRESHclk
			xCLR_ALL			: in		std_logic;
			xSDATOUT1		: in		std_logic;
			xSDATOUT2		: in		std_logic;
			xSDATOUT3		: in		std_logic;
			
			xTRIG_THRESH0	: in		std_logic_vector (11 downto 0);
			xTRIG_THRESH1	: in		std_logic_vector (11 downto 0);
			xTRIG_THRESH2	: in		std_logic_vector (11 downto 0);
			xTRIG_THRESH3	: in		std_logic_vector (11 downto 0);
			xTRIG_THRESH4	: in		std_logic_vector (11 downto 0);
			
			xVBIAS0			: in		std_logic_vector (11 downto 0);
			xVBIAS1			: in		std_logic_vector (11 downto 0);
			xVBIAS2			: in		std_logic_vector (11 downto 0);
			xVBIAS3			: in		std_logic_vector (11 downto 0);
			xVBIAS4			: in		std_logic_vector (11 downto 0);			

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
			xLOAD1			: out 	std_logic;
			xLOAD2			: out		std_logic;  	--Load signal (active low)
			xLOAD3			: out		std_logic;
			xCLR_BAR1		: out 	std_logic;
			xCLR_BAR2		: out		std_logic;  	--Clear (currently inactive)
			xCLR_BAR3		: out		std_logic;
			xSDATIN1			: out 	std_logic;  	--serial data to DAC1
			xSDATIN2			: out		std_logic;	 	--serial data to DAC2
			xSDATIN3			: out		std_logic);		--serial data to DAC3	
			
	end DAC_MAIN_DAISYCHAIN;
	
architecture Behavioral of DAC_MAIN_DAISYCHAIN is
-------------------------------------------------------------------------------
-- SIGNALS 
-------------------------------------------------------------------------------	
	signal CLR		: std_logic;
	--signal DATIN1	: std_logic;
	--signal DATIN2   : std_logic;
	signal UPDATE   : std_logic;
	
	signal DAC_A_0	: std_logic_vector(63 downto 0);
	signal DAC_B_0	: std_logic_vector(63 downto 0);
	signal DAC_C_0	: std_logic_vector(63 downto 0);
	signal DAC_D_0	: std_logic_vector(63 downto 0);
	signal DAC_E_0	: std_logic_vector(63 downto 0);
	signal DAC_F_0	: std_logic_vector(63 downto 0);
	signal DAC_G_0	: std_logic_vector(63 downto 0);
	signal DAC_H_0	: std_logic_vector(63 downto 0);
	signal DAC_A_1	: std_logic_vector(63 downto 0);
	signal DAC_B_1	: std_logic_vector(63 downto 0);
	signal DAC_C_1	: std_logic_vector(63 downto 0);
	signal DAC_D_1	: std_logic_vector(63 downto 0);
	signal DAC_E_1	: std_logic_vector(63 downto 0);
	signal DAC_F_1	: std_logic_vector(63 downto 0);
	signal DAC_G_1	: std_logic_vector(63 downto 0);
	signal DAC_H_1	: std_logic_vector(63 downto 0);
	signal DAC_A_2	: std_logic_vector(63 downto 0);
	signal DAC_B_2	: std_logic_vector(63 downto 0);
	signal DAC_C_2	: std_logic_vector(63 downto 0);
	signal DAC_D_2	: std_logic_vector(63 downto 0);
	signal DAC_E_2	: std_logic_vector(63 downto 0);
	signal DAC_F_2	: std_logic_vector(63 downto 0);
	signal DAC_G_2	: std_logic_vector(63 downto 0);
	signal DAC_H_2	: std_logic_vector(63 downto 0);

---  DAC signals:    ----------------------------------------
	
	signal PROVDD_1	: std_logic_vector(15 downto 0); --ring oscillator P control
	signal PROVDD_2	: std_logic_vector(15 downto 0);
	signal PROVDD_3	: std_logic_vector(15 downto 0);
	signal PROVDD_4	: std_logic_vector(15 downto 0);
	signal PROVDD_5	: std_logic_vector(15 downto 0);
	signal PROGND_1	: std_logic_vector(15 downto 0); --ring oscillator N control
	signal PROGND_2	: std_logic_vector(15 downto 0);
	signal PROGND_3	: std_logic_vector(15 downto 0);
	signal PROGND_4	: std_logic_vector(15 downto 0);
	signal PROGND_5	: std_logic_vector(15 downto 0);

	signal TTHRSH_1	: std_logic_vector(15 downto 0); --trig threshold levels
	signal TTHRSH_2	: std_logic_vector(15 downto 0);
	signal TTHRSH_3	: std_logic_vector(15 downto 0);
	signal TTHRSH_4	: std_logic_vector(15 downto 0);
	signal TTHRSH_5	: std_logic_vector(15 downto 0);
	
	signal VBIAS_1	: std_logic_vector(15 downto 0); --ped levels
	signal VBIAS_2	: std_logic_vector(15 downto 0);
	signal VBIAS_3	: std_logic_vector(15 downto 0);
	signal VBIAS_4	: std_logic_vector(15 downto 0);
	signal VBIAS_5	: std_logic_vector(15 downto 0);
	
	signal DLLbiasN : std_logic_vector(15 downto 0);	--	<=	x"300F";	
	signal DLLbiasP	: std_logic_vector(15 downto 0);	--  <=  x"CFF0";
	signal DLLN_1	: std_logic_vector(15 downto 0); --DLLbiases
	signal DLLN_2	: std_logic_vector(15 downto 0);
	signal DLLN_3	: std_logic_vector(15 downto 0);
	signal DLLN_4	: std_logic_vector(15 downto 0);
	signal DLLN_5	: std_logic_vector(15 downto 0);
	signal DLLP_1	: std_logic_vector(15 downto 0); --DLLbiases, cont'd
	signal DLLP_2	: std_logic_vector(15 downto 0);
	signal DLLP_3	: std_logic_vector(15 downto 0);
	signal DLLP_4	: std_logic_vector(15 downto 0);
	signal DLLP_5	: std_logic_vector(15 downto 0);
	
	signal TRIG_BIAS 	: std_logic_vector(15 downto 0);
	signal TRIG_BIAS_1: std_logic_vector(15 downto 0); --TRIGbias (optional)
	signal TRIG_BIAS_2: std_logic_vector(15 downto 0); --TRIGbias (optional)
	signal TRIG_BIAS_3: std_logic_vector(15 downto 0); --TRIGbias (optional)
	signal TRIG_BIAS_4: std_logic_vector(15 downto 0); --TRIGbias (optional)
	signal TRIG_BIAS_5: std_logic_vector(15 downto 0); --TRIGbias (optional)	
-------------------------------------------------------------------------------
-- COMPONENTS 
-------------------------------------------------------------------------------
	component DAC_SERIALIZER_DAISYCHAIN    --call DAC_SERIALIZER_DAISYCHAIN.vhd
	port(
		xCLK             	: in    std_logic;      -- DAC clk ( < 50MHz ) 
        xUPDATE          : in    std_logic;
        xDAC_A           : in    std_logic_vector (63 downto 0);  --DAC takes
        xDAC_B           : in    std_logic_vector (63 downto 0);  
        xDAC_C           : in    std_logic_vector (63 downto 0);  
        xDAC_D           : in    std_logic_vector (63 downto 0);
        xDAC_E           : in    std_logic_vector (63 downto 0); 
        xDAC_F           : in    std_logic_vector (63 downto 0); 
        xDAC_G           : in    std_logic_vector (63 downto 0); 
        xDAC_H           : in    std_logic_vector (63 downto 0); 
        xLOAD            : out   std_logic;     -- load DACs- active low
        xCLR_BAR         : out   std_logic;     -- Asynch clear
        xSERIAL_DATOUT   : out   std_logic);    -- Serial data to DAC reg
	end component;
-------------------------------------------------------------------------------  
begin  -- Behavioral
-------------------------------------------------------------------------------
	UPDATE 	<= 	xCLK_REFRESH;       --1-10 Hz
	xDACCLK1 <= 	xCLKDAC;	
	xDACCLK2	<= 	xCLKDAC;
	xDACCLK3 <= 	xCLKDAC;
   --DLLbiasN <= 	x"200F";--x"300F";
   --DLLbiasP <= 	x"BFF0";  -- x"CFF0";   
-------------------------------------------------------------------------------
--assign DAC values
--   for 12 bit DAC, input word is 24 bits: 4 COMMAND-4 ADDRESS-12 DATA-4 DON'T CARE
--     assign 12 DATA-4 DON'T CARE here (set DON'T CARE = 0b1111 = 0xF) 
-------------------------------------------------------------------------------
	PROVDD_1	<=  xPROVDD0 & x"0";
	PROVDD_2	<=  xPROVDD1 & x"0";
	PROVDD_3	<=  xPROVDD2 & x"0";
	PROVDD_4	<=  xPROVDD3 & x"0";
	PROVDD_5	<=  xPROVDD4 & x"0";
	PROGND_1	<=  x"FFFF"-PROVDD_1;
	PROGND_2	<=  x"FFFF"-PROVDD_2;
	PROGND_3	<=  x"FFFF"-PROVDD_3;
	PROGND_4	<=  x"FFFF"-PROVDD_4;
	PROGND_5	<=  x"FFFF"-PROVDD_5;

	VBIAS_1		<=	xVBIAS0 & x"0";
	VBIAS_2		<=	xVBIAS1 & x"0";
	VBIAS_3		<=	xVBIAS2 & x"0";
	VBIAS_4		<=	xVBIAS3 & x"0";
	VBIAS_5		<= xVBIAS4 & x"0";
	
	TTHRSH_1		<=	xTRIG_THRESH0 & x"F";
	TTHRSH_2		<=	xTRIG_THRESH1 & x"F";
	TTHRSH_3		<=	xTRIG_THRESH2 & x"F";
	TTHRSH_4		<=	xTRIG_THRESH3 & x"F";
	TTHRSH_5		<= xTRIG_THRESH4 & x"F";
	
	DLLN_1		<=  x"FFFF"-(xDLL_VDD0 & x"0");
	DLLN_2		<=  x"FFFF"-(xDLL_VDD1 & x"0");
	DLLN_3		<=  x"FFFF"-(xDLL_VDD2 & x"0");
	DLLN_4		<=  x"FFFF"-(xDLL_VDD3 & x"0");
	DLLN_5		<=  x"FFFF"-(xDLL_VDD4 & x"0");
	DLLP_1		<=  xDLL_VDD0 & x"0";
	DLLP_2		<=  xDLL_VDD1 & x"0";
	DLLP_3		<=  xDLL_VDD2 & x"0";
	DLLP_4		<=  xDLL_VDD3 & x"0";
	DLLP_5		<=  xDLL_VDD4 & x"0";
	
	TRIG_BIAS 	<= x"FFFF";
	TRIG_BIAS_1	<= TRIG_BIAS;
	TRIG_BIAS_2	<= TRIG_BIAS;
	TRIG_BIAS_3	<= TRIG_BIAS;
	TRIG_BIAS_4	<= TRIG_BIAS;
	TRIG_BIAS_5	<= TRIG_BIAS;

--------------------------------------------------------------------------------
-- update DAC values with 4 COMMAND and 4 ADDRESS bits
-- note: these assignments are easily changed to match board layout
--------------------------------------------------------------------------------
	DAC_A_0		<=	"1111111100110000"	& VBIAS_2 		&	"1111111100110000"	& VBIAS_1;
	DAC_B_0		<=	"1111111100110001"	& TRIG_BIAS_2 	& 	"1111111100110001"	& TRIG_BIAS_1;
	DAC_C_0		<=	"1111111100110010"	& TTHRSH_2 		& 	"1111111100110010" 	& TTHRSH_1;
	DAC_D_0		<=	"1111111111110011"	& PROVDD_2 		& 	"1111111100110011" 	& PROVDD_1;
	DAC_E_0		<=	"1111111100110100"	& PROGND_2	 	&	"1111111100110100"	& PROGND_1;
	DAC_F_0		<=	"1111111100110101"	& DLLN_2	 		& 	"1111111100110101"	& DLLN_1;
	DAC_G_0		<=	"1111111100110110"	& DLLP_2 		& 	"1111111100110110" 	& DLLP_1;
	DAC_H_0		<=	"1111111100110111"	& x"0000"	 	& 	"1111111100110111" 	& x"FFFF";
---------------------------------
--  DAC assignment test:	
--	DAC_A_1		<=	"1101010100110000"	& x"1111" 	&	"1101010100110000"	& x"0000";
--	DAC_B_1		<=	"0101010100110001"	& x"5555" 	& 	"0101010100110001"	& x"5555";
--	DAC_C_1		<=	"0101010100110010"	& x"5555" 	& 	"0101010100110010" 	& x"5555";
--	DAC_D_1		<=	"0101010111110011"	& x"5555" 	& 	"0101010100110011" 	& x"5555";
--	DAC_E_1		<=	"0101010100110100"	& x"5555" 	&	"0101010100110100"	& x"5555";
--	DAC_F_1		<=	"0101010100110101"	& x"5555" 	& 	"0101010100110101"	& x"5555";
--	DAC_G_1		<=	"0101010100110110"	& x"5555" 	& 	"0101010100110110" 	& x"5555";
--	DAC_H_1		<=	"0101010100110111"	& x"5555" 	& 	"0101010100110111" 	& x"5555";
---------------------------------
	DAC_A_1		<=	"1111111100110000"	& VBIAS_4 		&	"1111111100110000"	& VBIAS_3;
	DAC_B_1		<=	"1111111100110001"	& TRIG_BIAS_4 	& 	"1111111100110001"	& TRIG_BIAS_3;
	DAC_C_1		<=	"1111111100110010"	& TTHRSH_4 		& 	"1111111100110010" 	& TTHRSH_3;
	DAC_D_1		<=	"1111111100110011"	& PROVDD_4		& 	"1111111100110011" 	& PROVDD_3;
	DAC_E_1		<=	"1111111100110100"	& PROGND_4 		&	"1111111100110100"	& PROGND_3;
	DAC_F_1		<=	"1111111100110101"	& DLLN_4 		& 	"1111111100110101"	& DLLN_3;
	DAC_G_1		<=	"1111111100110110"	& DLLP_4 		& 	"1111111100110110" 	& DLLP_3;
	DAC_H_1		<=	"1111111100110111"	& x"0000" 		& 	"1111111100110111" 	& x"FFFF";	
-------------------------------------------------------------------------------
	DAC_A_2		<=	"1111111100110000"	& VBIAS_5 		&	"1111111100110000"	& VBIAS_5;  	--x"0000";
	DAC_B_2		<=	"1111111100110001"	& TRIG_BIAS_5 	& 	"1111111100110001"	& TRIG_BIAS_5;	--x"0000";
	DAC_C_2		<=	"1111111100110010"	& TTHRSH_5 		& 	"1111111100110010" 	& TTHRSH_5; 	--x"0000"; 
	DAC_D_2		<=	"1111111100110011"	& PROVDD_5		& 	"1111111100110011" 	& PROVDD_5;		--x"0000";
	DAC_E_2		<=	"1111111100110100"	& PROGND_5 		&	"1111111100110100"	& PROGND_5;		--x"0000";
	DAC_F_2		<=	"1111111100110101"	& DLLN_5 		& 	"1111111100110101"	& DLLN_5; 		--x"0000";
	DAC_G_2		<=	"1111111100110110"	& DLLP_5 		& 	"1111111100110110" 	& DLLP_5;	 	--x"0000";
	DAC_H_2		<=	"1111111100110111"	& x"0000" 		& 	"1111111100110111" 	& x"0000";	
---------------------------------------------------
	xDAC_SERIALIZER_0 : DAC_SERIALIZER_DAISYCHAIN
	port map(
		xCLK         => xCLKDAC,    
        xUPDATE      => '0',--UPDATE,    
        xDAC_A       => DAC_A_0,    
        xDAC_B       => DAC_B_0,    
        xDAC_C       => DAC_C_0,  
        xDAC_D       => DAC_D_0,    
        xDAC_E       => DAC_E_0,    
        xDAC_F       => DAC_F_0,    
        xDAC_G       => DAC_G_0,    
        xDAC_H       => DAC_H_0,    
  --      xSERIAL_DATIN	=> SDATOUT1,
        xLOAD        => xLOAD1,
        xCLR_BAR     => xCLR_BAR1,    
        xSERIAL_DATOUT	=> xSDATIN1);
        
 	xDAC_SERIALIZER_1 : DAC_SERIALIZER_DAISYCHAIN
	port map(
		xCLK         => xCLKDAC,    
        xUPDATE      => '0',--UPDATE,    
        xDAC_A       => DAC_A_1,    
        xDAC_B       => DAC_B_1,    
        xDAC_C       => DAC_C_1,  
        xDAC_D       => DAC_D_1,    
        xDAC_E       => DAC_E_1,    
        xDAC_F       => DAC_F_1,    
        xDAC_G       => DAC_G_1,     
        xDAC_H       => DAC_H_1,    
  --      xSERIAL_DATIN	=> SDATOUT1,
        xLOAD        => xLOAD2,
        xCLR_BAR     => xCLR_BAR2,    
        xSERIAL_DATOUT	=> xSDATIN2);
		  
 	xDAC_SERIALIZER_2 : DAC_SERIALIZER_DAISYCHAIN
	port map(
		xCLK         => xCLKDAC,    
        xUPDATE      => '0',--UPDATE,    
        xDAC_A       => DAC_A_2,    
        xDAC_B       => DAC_B_2,    
        xDAC_C       => DAC_C_2,  
        xDAC_D       => DAC_D_2,    
        xDAC_E       => DAC_E_2,    
        xDAC_F       => DAC_F_2,    
        xDAC_G       => DAC_G_2,     
        xDAC_H       => DAC_H_2,    
  --      xSERIAL_DATIN	=> SDATOUT1,
        xLOAD        => xLOAD3,
        xCLR_BAR     => xCLR_BAR3,    
        xSERIAL_DATOUT	=> xSDATIN3);
--------------------------------------------------------------------------------
end Behavioral;
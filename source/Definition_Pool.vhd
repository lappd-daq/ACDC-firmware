library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--use ieee.numeric_std.all;

package Definition_Pool is

constant STARTWORD	: std_logic_vector := x"1234";
constant STARTWORD_8a	: std_logic_vector := x"B7";
constant STARTWORD_8b	: std_logic_vector := x"34";
constant ENDWORD	: std_logic_vector := x"4321";
constant INS_LENGTH : integer := 48;


constant WILKRAMPCOUNT: integer := 160; --set ramp length w.r.t. clock
constant RAM_ADR_SIZE  : integer := 14;
constant EVT_CNT_SIZE  : integer := 16;
constant BLOCKSIZE    : integer := 64;
constant SETFREQ      : std_logic := '0';

constant ALIGN_WORD_16 				:  std_logic_vector := x"FACE";
constant ALIGN_WORD_8 				:  std_logic_vector := x"CE";

constant VBIAS_INITAL	 		:	std_logic_vector := x"800";
constant TRIG_THRESH_INITIAL	:	std_logic_vector := x"FFF";

type data_array is array(3 downto 0) of
		std_logic_vector(15 downto 0);

--psec4 control types
type RO_feedback_assign is array(4 downto 0) of
		std_logic_vector(15 downto 0);

type SampleBin_array is array(4 downto 0) of
		std_logic_vector(3 downto 0);
		
type AC_bitarray is array (4 downto 0) of 
		std_logic;

type SelfTrig_array is array (4 downto 0) of 
		std_logic_vector(5 downto 0);

type EvtCnt_array is array (4 downto 0) of 
		std_logic_vector(EVT_CNT_SIZE-1 downto 0);
		
type Word_array is array(4 downto 0) of
		std_logic_vector(15 downto 0);

type DAC_array is array(4 downto 0) of
		std_logic_vector(11 downto 0);

type ChipData_array is array(4 downto 0) of
		std_logic_vector(15 downto 0);

type Address_array is array(4 downto 0) of
		std_logic_vector(2 downto 0);        
        
type trigger_array is array (5 downto 0) of
				std_logic_vector(15 downto 0);

type bias_array is array (4 downto 0) of
            std_logic_vector (11 downto 0);
				
type rate_count_array is array(29 downto 0) of
				std_logic_vector (15 downto 0);

constant RO1          : std_logic_vector(15 downto 0) := x"C800";
constant RO2          : std_logic_vector(15 downto 0) := x"C800";
constant RO3          : std_logic_vector(15 downto 0) := x"C800";
constant RO4          : std_logic_vector(15 downto 0) := x"C800";
constant RO5          : std_logic_vector(15 downto 0) := x"C800";
 
end Definition_Pool;
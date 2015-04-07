--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	PLL_CONFIG
-- author		: 	ejo
-- date			: 	4/2012
-- description	:  PLL SPI management
--------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Definition_Pool.all;

entity PLL_CONFIG is
    Port ( xCLK : in  STD_LOGIC;
           REV_CLK_OUT : out  STD_LOGIC;
           LED : out  STD_LOGIC_VECTOR(8 downto 0);
		     REV_CLK_N : out STD_LOGIC;
			  REV_CLK_P : out STD_LOGIC;
			  PLL_SPI_CLK : out STD_LOGIC;
			  PLL_SPI_LE : out STD_LOGIC;
			  PLL_SPI_MISO : in STD_LOGIC;
			  PLL_SPI_MOSI : out STD_LOGIC;
			  MONITOR_HEADER : out STD_LOGIC_VECTOR(15 downto 0);
			  PLL_NOT_POWER_DOWN : out STD_LOGIC;
			  PLL_TEST_MODE : out STD_LOGIC;
			  PLL_SYNC : out STD_LOGIC;
			  PLL_LOCK : in STD_LOGIC;
			  xUPDATE	:	in	STD_LOGIC;
			  xCLR_ALL	:	in	STD_LOGIC;
			  xPLL_MODE	: in std_logic_vector(1 downto 0);
			  PLL_REF_SEL : out STD_LOGIC;
			  xPLL_CONFIG_OUT	: out std_logic);
end PLL_CONFIG;

architecture Behavioral of PLL_CONFIG is
	type STATE_TYPE is ( IDLE, PWR_UP, SERIALIZE, GND_STATE, CAL_HOLD, SYNC); 
-------------------------------------------------------------------------------
-- SIGNALS 
-------------------------------------------------------------------------------
	signal STATE          : STATE_TYPE;
	
	signal DIN	  			: std_logic	:= '0';
	signal S_EN	  			: std_logic	:=	'0';
	signal PWR_DWN	  		: std_logic	:= '1';
	signal PLL_RST	  		: std_logic	:= '1';
	signal RAM_SEL			: std_logic_vector(3 downto 0) := x"F";
	signal xRAM				: std_logic_vector(31 downto 0);
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
	signal xRAM0	  		: std_logic_vector(31 downto 0);
	signal xRAM1	  		: std_logic_vector(31 downto 0);
	signal xRAM2	  		: std_logic_vector(31 downto 0);
	signal xRAM3	  		: std_logic_vector(31 downto 0);
	signal xRAM4	  		: std_logic_vector(31 downto 0);
	signal xRAM5	  		: std_logic_vector(31 downto 0);
	signal xRAM6	  		: std_logic_vector(31 downto 0);
	signal xRAM7	  		: std_logic_vector(31 downto 0);
	signal xRAM8	  		: std_logic_vector(31 downto 0);
	signal xLOAD_PROM		: std_logic_vector(31 downto 0);
	
	signal internal_COUNTER : std_logic_vector(31 downto 0) := (others => '0');
	signal internal_PLL_SPI_CLK_COUNTER : std_logic_vector(12 downto 0) := (others => '0');
	signal internal_PLL_SPI_CLK_ENABLE : std_logic := '0';
	signal internal_PLL_SPI_CLK : std_logic;
	signal internal_MONITOR_HEADER : std_logic_vector(15 downto 0);
	
  
  type SPI_REGISTER is array(8 downto 0) of std_logic_vector(31 downto 0);
  signal iREGISTER : SPI_REGISTER;
-------------------------------------------------------------------------------  
begin  -- Behavioral
-------------------------------------------------------------------------------
  PLL_SPI_MOSI <= DIN;
  PLL_SPI_LE <= (not S_EN);
  internal_PLL_SPI_CLK <= xCLK;
  PLL_SPI_CLK <= internal_PLL_SPI_CLK;
  PLL_NOT_POWER_DOWN <= (not PWR_DWN);
	PLL_TEST_MODE <= '1';
	PLL_SYNC <= (not PLL_RST);
	PLL_REF_SEL <= '1';


--internal_REGISTER(0)(31 downto 0) <= x"0114032"&"0000";
--internal_REGISTER(1)(31 downto 0) <= x"3115ff3"&"0001";
--internal_REGISTER(2)(31 downto 0) <= x"3115ff0"&"0010";
--internal_REGISTER(3)(31 downto 0) <= x"3115ff0"&"0011";
--internal_REGISTER(4)(31 downto 0) <= x"0115ff3"&"0100";
--internal_REGISTER(5)(31 downto 0) <= x"fc009e8"&"0101";
--internal_REGISTER(6)(31 downto 0) <= x"2bff82e"&"0110";
--internal_REGISTER(7)(31 downto 0) <= x"fd903c1"&"0111";
--internal_REGISTER(8)(31 downto 0) <= x"e0001ff"&"1000";

--iREGISTER(0)(31 downto 0) <= x"0040020"&"0000";
--iREGISTER(1)(31 downto 0) <= x"3040020"&"0001";
--iREGISTER(2)(31 downto 0) <= x"3040020"&"0010";
--iREGISTER(3)(31 downto 0) <= x"3014020"&"0011";
--iREGISTER(4)(31 downto 0) <= x"0014023"&"0100";
--iREGISTER(5)(31 downto 0) <= x"fc009eb"&"0101";
--iREGISTER(6)(31 downto 0) <= x"1b5f82e"&"0110";
--iREGISTER(7)(31 downto 0) <= x"ff883e0"&"0111";
--iREGISTER(8)(31 downto 0) <= x"e0001ff"&"1000";
										--40 MHz -- use this one for fan-out only!!!!
--iREGISTER(0)(31 downto 0) <= x"014000e0"; --014002e0 to use secondary ref
--iREGISTER(1)(31 downto 0) <= x"014000c1";
--iREGISTER(2)(31 downto 0) <= x"014000c2";
--iREGISTER(3)(31 downto 0) <= x"014000e3";
--iREGISTER(4)(31 downto 0) <= x"014000e4";
--iREGISTER(5)(31 downto 0) <= x"01ff1e75"; --pick lvds/lvcmos input buffers
--iREGISTER(6)(31 downto 0) <= x"adffff86";
--iREGISTER(7)(31 downto 0) <= x"bd0037f7";
--iREGISTER(8)(31 downto 0) <= x"e0001ff"&"1000";
										--40 MHz
--iREGISTER(0)(31 downto 0) <= x"01400020";
--iREGISTER(1)(31 downto 0) <= x"01400001";
--iREGISTER(2)(31 downto 0) <= x"01400002";
--iREGISTER(3)(31 downto 0) <= x"01400003";
--iREGISTER(4)(31 downto 0) <= x"01400014";
--iREGISTER(5)(31 downto 0) <= x"10000BE5";
--iREGISTER(6)(31 downto 0) <= x"044E02E6";
--iREGISTER(7)(31 downto 0) <= x"BD913DB7";
--iREGISTER(8)(31 downto 0) <= x"20009D98";
--										--40 MHz using PLL
--iREGISTER(0)(31 downto 0) <= x"01140320"; --014002e0 to use secondary ref
--iREGISTER(1)(31 downto 0) <= x"01140301";
--iREGISTER(2)(31 downto 0) <= x"01140302";
--iREGISTER(3)(31 downto 0) <= x"01140303";
--iREGISTER(4)(31 downto 0) <= x"01140314";
--iREGISTER(5)(31 downto 0) <= x"10000BE5";
--iREGISTER(6)(31 downto 0) <= x"044E02E6";
--iREGISTER(7)(31 downto 0) <= x"BD913DB7";
--iREGISTER(8)(31 downto 0) <= x"20009D98";

--										--36 MHz using PLL
--iREGISTER(0)(31 downto 0) <= x"010E0320";
--iREGISTER(1)(31 downto 0) <= x"010E0301";
--iREGISTER(2)(31 downto 0) <= x"010E0302";
--iREGISTER(3)(31 downto 0) <= x"010E0303";
--iREGISTER(4)(31 downto 0) <= x"010E0314";
--iREGISTER(5)(31 downto 0) <= x"10040BE5";
--iREGISTER(6)(31 downto 0) <= x"044E04B6";
--iREGISTER(7)(31 downto 0) <= x"BD91BBB7";
--iREGISTER(8)(31 downto 0) <= x"20009D98";
--										--35 MHz using PLL
--		iREGISTER(0)(31 downto 0) <= x"011C0320";
--		iREGISTER(1)(31 downto 0) <= x"011C0301";
--		iREGISTER(2)(31 downto 0) <= x"011C0302";
--		iREGISTER(3)(31 downto 0) <= x"011C0303";
--		iREGISTER(4)(31 downto 0) <= x"011C0314";
--		iREGISTER(5)(31 downto 0) <= x"10040BE5";
--		iREGISTER(6)(31 downto 0) <= x"044E0C76";
--		iREGISTER(7)(31 downto 0) <= x"BD91BBB7";
--		iREGISTER(8)(31 downto 0) <= x"20009D98";
--32 MHz and 40 on channel 5
--		iREGISTER(0)(31 downto 0) <= x"01160320";
--		iREGISTER(1)(31 downto 0) <= x"01160301";
--		iREGISTER(2)(31 downto 0) <= x"01160302";
--		iREGISTER(3)(31 downto 0) <= x"01160303";
--		iREGISTER(4)(31 downto 0) <= x"01140314";
--		iREGISTER(5)(31 downto 0) <= x"10000BE5";
--		iREGISTER(6)(31 downto 0) <= x"042E02E6";
--		iREGISTER(7)(31 downto 0) <= x"BD1177F7";
--		iREGISTER(8)(31 downto 0) <= x"20009D98";
process(xPLL_MODE)
begin
	case xPLL_MODE is
		when "10" =>
      --24 MHz and 40 on channel 5
		iREGISTER(0)(31 downto 0) <= x"011E0320";
		iREGISTER(1)(31 downto 0) <= x"011E0301";
		iREGISTER(2)(31 downto 0) <= x"011E0302";
		iREGISTER(3)(31 downto 0) <= x"011E0323";
		iREGISTER(4)(31 downto 0) <= x"01140314";
		iREGISTER(5)(31 downto 0) <= x"FC000BE5";
		iREGISTER(6)(31 downto 0) <= x"042E02E6";
		iREGISTER(7)(31 downto 0) <= x"BD1177F7";
		iREGISTER(8)(31 downto 0) <= x"20009D98";
		
		when "01" =>
      --32 MHz and 40 on channel 5
		iREGISTER(0)(31 downto 0) <= x"01160320";
		iREGISTER(1)(31 downto 0) <= x"01160301";
		iREGISTER(2)(31 downto 0) <= x"01160302";
		iREGISTER(3)(31 downto 0) <= x"01160303";
		iREGISTER(4)(31 downto 0) <= x"01140314";
		iREGISTER(5)(31 downto 0) <= x"10000BE5";
		iREGISTER(6)(31 downto 0) <= x"042E02E6";
		iREGISTER(7)(31 downto 0) <= x"BD1177F7";
		iREGISTER(8)(31 downto 0) <= x"20009D98";
		
		
		when "00" =>
		iREGISTER(0)(31 downto 0) <= x"01140320"; --014002e0 to use secondary ref
		iREGISTER(1)(31 downto 0) <= x"01140301";
		iREGISTER(2)(31 downto 0) <= x"01140302";
		iREGISTER(3)(31 downto 0) <= x"01140303";
		iREGISTER(4)(31 downto 0) <= x"01140314";
		iREGISTER(5)(31 downto 0) <= x"10000BE5";
		iREGISTER(6)(31 downto 0) <= x"044E02E6";
		iREGISTER(7)(31 downto 0) <= x"BD913DB7";
		iREGISTER(8)(31 downto 0) <= x"20009D98";	

		
		when others =>
		iREGISTER(0)(31 downto 0) <= x"01140320"; --014002e0 to use secondary ref
		iREGISTER(1)(31 downto 0) <= x"01140301";
		iREGISTER(2)(31 downto 0) <= x"01140302";
		iREGISTER(3)(31 downto 0) <= x"01140303";
		iREGISTER(4)(31 downto 0) <= x"01140314";
		iREGISTER(5)(31 downto 0) <= x"10000BE5";
		iREGISTER(6)(31 downto 0) <= x"044E02E6";
		iREGISTER(7)(31 downto 0) <= x"BD913DB7";
		iREGISTER(8)(31 downto 0) <= x"20009D98";	

	end case;
end process;

--										--30 MHz using PLL
--iREGISTER(0)(31 downto 0) <= x"011C0320";
--iREGISTER(1)(31 downto 0) <= x"011C0301";
--iREGISTER(2)(31 downto 0) <= x"011C0302";
--iREGISTER(3)(31 downto 0) <= x"011C0303";
--iREGISTER(4)(31 downto 0) <= x"011C0314";
--iREGISTER(5)(31 downto 0) <= x"10000BE5";
--iREGISTER(6)(31 downto 0) <= x"044E02E6";
--iREGISTER(7)(31 downto 0) <= x"BD913DB7";
--iREGISTER(8)(31 downto 0) <= x"20009D98";
										 --20 MHz    --40 MHz
										
--										--20 MHz using PLL
--iREGISTER(0)(31 downto 0) <= x"012C0320";
--iREGISTER(1)(31 downto 0) <= x"012C0301";
--iREGISTER(2)(31 downto 0) <= x"012C0302";
--iREGISTER(3)(31 downto 0) <= x"012C0303";
--iREGISTER(4)(31 downto 0) <= x"012C0314";
--iREGISTER(5)(31 downto 0) <= x"10000BE5";
--iREGISTER(6)(31 downto 0) <= x"044E02E6";
--iREGISTER(7)(31 downto 0) <= x"BD913DB7";
--iREGISTER(8)(31 downto 0) <= x"20009D98";

										 --iREGISTER(0)(31 downto 0) <= x"01800020"; --x"014000e0"; --014002e0 to use secondary ref
--iREGISTER(1)(31 downto 0) <= x"01800001"; --x"014000c1";
--iREGISTER(2)(31 downto 0) <= x"01800002"; --x"014000c2";
--iREGISTER(3)(31 downto 0) <= x"01800023"; --x"014000e3";
--iREGISTER(4)(31 downto 0) <= x"01800014"; --x"014000e4";
--iREGISTER(5)(31 downto 0) <= x"10000BE5"; --x"01ff1e75"; --pick lvds/lvcmos input buffers
--iREGISTER(6)(31 downto 0) <= x"045E02E6"; --x"adffff86";
--iREGISTER(7)(31 downto 0) <= x"BD887647"; --x"bd0037f7";
--iREGISTER(8)(31 downto 0) <= x"e0001ff"&"1000";
									
										
										--PLL30MHz --PLL 25MHz  --20 MHz    --40 MHz
--iREGISTER(0)(31 downto 0) <= x"011C0320";--"010C0320";--x"01800020"; --x"014000e0"; --014002e0 to use secondary ref
--iREGISTER(1)(31 downto 0) <= x"011C0301";--"010C0301";--x"01800001"; --x"014000c1";
--iREGISTER(2)(31 downto 0) <= x"011C0302";--"010C0302";--x"01800002"; --x"014000c2";
--iREGISTER(3)(31 downto 0) <= x"011C0303";--"010C0303";--x"01800023"; --x"014000e3";
--iREGISTER(4)(31 downto 0) <= x"011C0314";--"010C0314";--x"01800014"; --x"014000e4";
--iREGISTER(5)(31 downto 0) <= x"10000BE5";--"10040A65";--x"01ff1e75"; --pick lvds/lvcmos input buffers
--iREGISTER(6)(31 downto 0) <= x"045E02E6";--"045E0186";--x"adffff86";
--iREGISTER(7)(31 downto 0) <= x"BD887647";--"BD887647";--x"bd0037f7";
--iREGISTER(8)(31 downto 0) <= x"e0001ff"&"1000";

									 --PLL 25MHz  
--iREGISTER(0)(31 downto 0) <= x"010C0320";
--iREGISTER(1)(31 downto 0) <= x"010C0301";
--iREGISTER(2)(31 downto 0) <= x"010C0302";
--iREGISTER(3)(31 downto 0) <= x"010C0303";
--iREGISTER(4)(31 downto 0) <= x"010C0314";
--iREGISTER(5)(31 downto 0) <= x"10040A65";
--iREGISTER(6)(31 downto 0) <= x"045E0186";
--iREGISTER(7)(31 downto 0) <= x"BD887647";
--iREGISTER(8)(31 downto 0) <= x"e0001ff"&"1000";
									--PLL 28MHz 
--iREGISTER(0)(31 downto 0) <= x"011E0320";
--iREGISTER(1)(31 downto 0) <= x"011E0301";
--iREGISTER(2)(31 downto 0) <= x"011E0302";
--iREGISTER(3)(31 downto 0) <= x"011E0303";
--iREGISTER(4)(31 downto 0) <= x"011E0314";
--iREGISTER(5)(31 downto 0) <= x"10040BE5";
--iREGISTER(6)(31 downto 0) <= x"045E0C76";
--iREGISTER(7)(31 downto 0) <= x"BD887647";
--iREGISTER(8)(31 downto 0) <= x"20009D98";

------------------------------------------------------------------------

	xRAM0 <= iREGISTER(0)(31 downto 0) ;
	xRAM1 <= iREGISTER(1)(31 downto 0) ;
	xRAM2 <= iREGISTER(2)(31 downto 0) ;
	xRAM3 <= iREGISTER(3)(31 downto 0) ;
	xRAM4 <= iREGISTER(4)(31 downto 0) ;
	--xRAM5 <= iREGISTER(5)(31 downto 18) & "00" & iREGISTER(5)(15 downto 4) & x"5";
	--xRAM6 <= iREGISTER(6)(31 downto 28) & '0' & iREGISTER(6)(26 downto 16) 
												--& '0' & iREGISTER(6)(14 downto 4) & x"6";
	--xRAM7 <= "1011110" & iREGISTER(7)(24 downto 4) & x"7";
	xRAM5 <= iREGISTER(5)(31 downto 0) ;
	xRAM6 <= iREGISTER(6)(31 downto 0) ;
	xRAM7 <= iREGISTER(7)(31 downto 0) ;
	xRAM8 <= x"20009D98"; --x"80005dd" & x"8";
	
--	xRAM0 <= iREGISTER(0)(31 downto 8) & "00" & iREGISTER(0)(5 downto 4) & x"0";
--	xRAM1 <= iREGISTER(1)(31 downto 8) & "00" & iREGISTER(1)(5 downto 4) & x"1";
--	xRAM2 <= iREGISTER(2)(31 downto 8) & "00" & iREGISTER(2)(5 downto 4) & x"2";
--	xRAM3 <= iREGISTER(3)(31 downto 8) & "000" & iREGISTER(3)(4) & x"3";
--	xRAM4 <= iREGISTER(4)(31 downto 8) & "00" & iREGISTER(4)(5) & '0' & x"4";
--	xRAM5 <= iREGISTER(5)(31 downto 18) & "00" & iREGISTER(5)(15 downto 4) & x"5";
--	xRAM6 <= iREGISTER(6)(31 downto 28) & '0' & iREGISTER(6)(26 downto 16) 
--												& '0' & iREGISTER(6)(14 downto 4) & x"6";
--	--xRAM7 <= "1011110" & iREGISTER(7)(24 downto 4) & x"7";
--	xRAM7 <= iREGISTER(7)(31 downto 4) & x"7";
--	xRAM8 <= x"80005dd" & x"8";
----------------------------	
	xLOAD_PROM <= x"0000001F";
-------------------------------------------------------------------------------

  	process(xCLK,xCLR_ALL)
	variable i	: integer range 0 to 31;
	begin
		if xCLR_ALL = '1' then
			DIN 		<= '0';
			S_EN 		<= '0';
			PWR_DWN 	<= '1';
			PLL_RST 	<= '1';
			RAM_SEL <= x"F";
			STATE	<= PWR_UP;			
			--xPLL_CONFIG_OUT <= xPLL_MODE;
		elsif falling_edge(xCLK) and xCLR_ALL = '0' then
--------------------------------------------------------------------------------			
			case STATE is
--------------------------------------------------------------------------------	
				when PWR_UP =>
					PWR_DWN 	<= '1';
					PLL_RST 	<= '1';
					STATE	<= CAL_HOLD;	
--------------------------------------------------------------------------------	
				when CAL_HOLD =>
					PWR_DWN 	<= '0';
					PLL_RST 	<= '1';
					STATE	<= IDLE;	
--------------------------------------------------------------------------------	
				when IDLE =>
					DIN 		<= '0';
					S_EN 		<= '0';
					PWR_DWN 	<= '0';
					PLL_RST 	<= '0';
					i := 0;
					if RAM_SEL = x"9" then
						RAM_SEL <= x"F";
						STATE	<= SYNC;
					else
						RAM_SEL <= RAM_SEL + 1;
						STATE	<= SERIALIZE;
					end if;
--------------------------------------------------------------------------------	
				when SERIALIZE =>
					S_EN 	<= '1';
					DIN 	<= xRAM(i);
					if i = 31 then
						STATE	<= IDLE;
					else
						i := i + 1;
					end if;
--------------------------------------------------------------------------------	
				when SYNC =>
					PLL_RST 	<= '1';
					if i = 31 then
						STATE	<= GND_STATE;
					else
						i := i + 1;
					end if;				
--------------------------------------------------------------------------------	
				when GND_STATE =>
					DIN 		<= '0';
					S_EN 		<= '0';
					PWR_DWN 	<= '0';
					PLL_RST 	<= '0';
					RAM_SEL <= x"F";
--------------------------------------------------------------------------------	
				when others =>	STATE<=PWR_UP;																
			end case;
		end if;
	end process;	
	
	process(RAM_SEL)
	begin
		if RAM_SEL = x"0" then
			xRAM <= xRAM0;
		elsif RAM_SEL = x"1" then
			xRAM <= xRAM1;
		elsif RAM_SEL = x"2" then
			xRAM <= xRAM2;
		elsif RAM_SEL = x"3" then
			xRAM <= xRAM3;
		elsif RAM_SEL = x"4" then
			xRAM <= xRAM4;
		elsif RAM_SEL = x"5" then
			xRAM <= xRAM5;
		elsif RAM_SEL = x"6" then
			xRAM <= xRAM6;
		elsif RAM_SEL = x"7" then
			xRAM <= xRAM7;
		elsif RAM_SEL = x"8" then
			xRAM <= xRAM8;
		elsif RAM_SEL = x"9" then
			xRAM <= xLOAD_PROM;
		else
			xRAM <= x"00000000";
		end if;
	end process;
end Behavioral;	
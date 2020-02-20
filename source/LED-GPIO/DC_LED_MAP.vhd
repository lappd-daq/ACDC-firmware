--------------------------------------------------
-- University of Chicago
-- LAPPD system firmware
--------------------------------------------------
-- module		: 	DC_LED_MAP
-- author		: 	ejo
-- date			: 	4/2012
-- description	:  LED mapping for digital card
--------------------------------------------------

library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.Definition_Pool.all;

entity DC_LED_MAP is
	Port(
		GPIO				:	out	std_logic_vector(26 downto 18);
		xCLR_ALL			:	in		std_logic;
		LED_BLOCK_A0	:	in		std_logic; --ASIC indicators
		LED_BLOCK_A1	:	in		std_logic; --ASIC indicators
		LED_BLOCK_A2	:	in		std_logic; --ASIC indicators
		LED_BLOCK_A3	:	in		std_logic; --ASIC indicators
		LED_BLOCK_A4	:	in		std_logic; --ASIC indicators
		LED_BLOCK_A5	:	in		std_logic; --ASIC indicators
		LED_BLOCK_A6	:	in		std_logic; --ASIC indicators
		LED_BLOCK_A7	:	in		std_logic; --ASIC indicators
		LED_BLOCK_A8	:	in		std_logic; --ASIC indicators

		xOTHER			:	in		std_logic_vector(15 downto 0);
		xCLK_A			:  in		std_logic;
		xCLK_B			:  in		std_logic;
		xLED_EN			: 	in		std_logic);
end DC_LED_MAP;

architecture Behavioral of DC_LED_MAP is
		type		BLINK_TYPE  is (BLINK, RESET);
		signal   BLINK1_STATE	:  BLINK_TYPE;
		signal   BLINK2_STATE	:  BLINK_TYPE;
		signal   BLINK3_STATE	:  BLINK_TYPE;

		signal 	LED				:	std_logic_vector(8 downto 0) := (others=>'1');
		signal 	LED_reset		:	std_logic_vector(8 downto 0) := (others=>'0');
		signal 	LED_temp			:	std_logic_vector(8 downto 0);
		signal 	LED_temp_temp	:	std_logic_vector(8 downto 0);
		signal 	CLK_10			:	std_logic;
		signal	CLK_100			:	std_logic;
		signal   TURN_OFF			:  std_logic;


begin
		
	process(xLED_EN, xCLK_B)
	begin
		-- LED active low --
		if xLED_EN = '0' then
			TURN_OFF <= '1';
			GPIO(18)	<=	 '1';
			GPIO(19)	<=	 '1';
			GPIO(20)	<=	 '1';
			GPIO(21)	<=	 '1';
			GPIO(22)	<=	 '1';
			GPIO(23)	<=	 '1';
			GPIO(24)	<=	 '1';
			GPIO(25)	<=	 '1'; --clear all indicator
			GPIO(26)	<=	 '1';
			
		elsif xLED_EN = '1' and xCLR_ALL = '1' then
			TURN_OFF <= '1';
			--for i in 0 to 8 loop	
			--	LED_temp(i) <= '1';
			--end loop;
			GPIO(18)	<=	 '1';
			GPIO(19)	<=	 '1';
			GPIO(20)	<=	 '1';
			GPIO(21)	<=	 LED_BLOCK_A3; --'1';
			GPIO(22)	<=	 '1';
			GPIO(23)	<=	 '1';
			GPIO(24)	<=	 '1';
			GPIO(25)	<=	 not xCLR_ALL; --clear all indicator
			GPIO(26)	<=	 '1';
		
		else --if xLED_EN = '1' then
			TURN_OFF <= '0';
			--LED(0)		<=		LED_BLOCK_A0 or TURN_OFF;
			LED(1)		<=		LED_temp_temp(1); --LED_BLOCK_A0;
			LED(0)		<=    LED_temp_temp(0); --LED_BLOCK_A1;
			LED(2)		<=		not LED_BLOCK_A2;
			LED(3)		<=		LED_temp_temp(3);
			LED(4)		<=		not LED_BLOCK_A4;
			LED(5)		<=		not LED_BLOCK_A5;
			LED(6)		<=		not LED_BLOCK_A6; --local clk pll lock
			LED(7)		<=		not LED_BLOCK_A7;
			LED(8)		<=		not LED_BLOCK_A8;

			GPIO(18)	<=	LED(0);
			GPIO(19)	<=	LED(1) ;
			GPIO(20)	<=	LED(2);
			GPIO(21)	<=	LED(3);
			GPIO(22)	<=	LED(4) ;
			GPIO(23)	<=	LED(5);
			GPIO(24)	<=	LED(6);
			GPIO(25)	<=	LED(7) or TURN_OFF; --LED(7) or TURN_OFF;
			GPIO(26)	<=	LED(8) or TURN_OFF;	

		end if;
	end process;
	
process(xCLR_ALL, LED_BLOCK_A0)
	begin
		if xCLR_ALL = '1' or LED_reset(0) = '1' then	
			LED_temp(0) <= '0';
		elsif rising_edge(LED_BLOCK_A0) and xLED_EN = '1' then
			LED_temp(0) <= '1';		
		end if;
end process;
process(xCLK_B, LED_temp(0))
variable i : integer range 1010 downto 0 := 0;	
	begin
		if LED_temp(0) = '0' then
			LED_temp_temp(0) <= '1';
			LED_reset(0) <= '0';
			i := 0;
			BLINK1_STATE <= BLINK;
		elsif rising_edge(xCLK_B) and LED_temp(0) = '1' then
			case BLINK1_STATE is
				when BLINK =>
					if i > 1000 then
						i := 0;
						LED_temp_temp(0) <= '1';
						BLINK1_STATE <= RESET;
					else
						i := i + 1;
						LED_temp_temp(0) <= '0';
					end if;
					
				when RESET =>
					LED_reset(0) <= '1';
			end case;
		end if;
end process;

process(xCLR_ALL, LED_BLOCK_A1)
	begin
		if xCLR_ALL = '1' or LED_reset(1) = '1' then	
			LED_temp(1) <= '0';
		elsif rising_edge(LED_BLOCK_A1) and xLED_EN = '1' then
			LED_temp(1) <= '1';		
		end if;
end process;
process(xCLK_B, LED_temp(1))
variable i : integer range 1010 downto 0 := 0;	
	begin
		if LED_temp(1) = '0' then
			LED_temp_temp(1) <= '1';
			LED_reset(1) <= '0';
			i := 0;
			BLINK2_STATE <= BLINK;
		elsif rising_edge(xCLK_B) and LED_temp(1) = '1' then
			case BLINK2_STATE is
				when BLINK =>
					if i > 1000 then
						i := 0;
						LED_temp_temp(1) <= '1';
						BLINK2_STATE <= RESET;
					else
						i := i + 1;
						LED_temp_temp(1) <= '0';
					end if;
					
				when RESET =>
					LED_reset(1) <= '1';
			end case;
		end if;
end process;

process(xCLR_ALL, LED_BLOCK_A3)
	begin
		if xCLR_ALL = '1' or LED_reset(3) = '1' then	
			LED_temp(3) <= '0';
		elsif rising_edge(LED_BLOCK_A3) and xLED_EN = '1' then
			LED_temp(3) <= '1';		
		end if;
end process;
process(xCLK_B, LED_temp(3))
variable i : integer range 5010 downto 0 := 0;	
	begin
		if LED_temp(3) = '0' then
			LED_temp_temp(3) <= '1';
			LED_reset(3) <= '0';
			i := 0;
			BLINK3_STATE <= BLINK;
		elsif rising_edge(xCLK_B) and LED_temp(3) = '1' then
			case BLINK3_STATE is
				when BLINK =>
					if i > 5000 then
						i := 0;
						LED_temp_temp(3) <= '1';
						BLINK3_STATE <= RESET;
					else
						i := i + 1;
						LED_temp_temp(3) <= '0';
					end if;
					
				when RESET =>
					LED_reset(3) <= '1';
			end case;
		end if;
end process;





end Behavioral;
			
		


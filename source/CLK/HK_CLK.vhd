---------------------------------------------------------------------------------------------
-- Design by: Larry L. Ruckman Jr.															--
-- DATE : 27 JUNE 2007																			--
-- Project name: ICRR firmware																--
--	Module name: HK_CLK			  																--
--	Description : 																					--
-- 	House Keeping clock control module													--
--		  											    												--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity HK_CLK is
    Port ( 	xCLK_40MHz	: 	in  std_logic;
				xCLR_ALL		:  in  std_logic;
				xCLK_1kHz 	: 	out std_logic;	
				xCLK_100Hz 	: 	out std_logic;	
				xCLK_10Hz 	: 	out std_logic;					
				xCLK_1Hz 	: 	out std_logic);
end HK_CLK;

architecture Behavioral of HK_CLK is
	type STATE_TYPE_1Hz is (	HI_1Hz,LO_1Hz);								
	signal STATE_1Hz  	: STATE_TYPE_1Hz;
	signal CLK_1Hz			: std_logic;
	
	type STATE_TYPE_10Hz is (	HI_10Hz,LO_10Hz);								
	signal STATE_10Hz  	: STATE_TYPE_10Hz;
	signal CLK_10Hz			: std_logic;
	
	type STATE_TYPE_100Hz is (	HI_100Hz,LO_100Hz);								
	signal STATE_100Hz  	: STATE_TYPE_100Hz;
	signal CLK_100Hz			: std_logic;
	
	type STATE_TYPE_1kHz is (	HI_1kHz,LO_1kHz);								
	signal STATE_1kHz  	: STATE_TYPE_1kHz;
	signal CLK_1kHz			: std_logic;
	
--------------------------------------------------------------------------------	
begin 
--------------------------------------------------------------------------------
	xCLK_1Hz <= CLK_1Hz;
	xCLK_10Hz <= CLK_10Hz;
	xCLK_100Hz <= CLK_100Hz;
	xCLK_1kHz <= CLK_1kHz;
--------------------------------------------------------------------------------
	process(xCLK_40MHz)
	variable i : integer range 20000001 downto 0;
	begin
		if xCLR_ALL = '1' then
			CLK_1Hz <= '1';
			i:= 0;
			STATE_1Hz <= HI_1Hz;
		elsif rising_edge(xCLK_40MHz) then
--------------------------------------------------------------------------------			
			case STATE_1Hz is
--------------------------------------------------------------------------------	
				when HI_1Hz =>			
					CLK_1Hz <= '1';
					i := i + 1;
					if i = 20000000 then
						i := 1;
						STATE_1Hz <= LO_1Hz;
					end if;
--------------------------------------------------------------------------------	
				when LO_1Hz =>			
					CLK_1Hz <= '0';
					i := i + 1;
					if i = 20000000 then
						i := 1;
						STATE_1Hz <= HI_1Hz;
					end if;
--------------------------------------------------------------------------------	
				when others =>	STATE_1Hz<=HI_1Hz;																
			end case;
		end if;
	end process;	
--------------------------------------------------------------------------------	
	process(xCLK_40MHz)
	variable i : integer range 2000001 downto 0;
	begin
		if xCLR_ALL = '1' then
			CLK_10Hz <= '1';
			i:= 0;
			STATE_10Hz <= HI_10Hz;
		elsif rising_edge(xCLK_40MHz) then
--------------------------------------------------------------------------------			
			case STATE_10Hz is
--------------------------------------------------------------------------------	
				when HI_10Hz =>			
					CLK_10Hz <= '1';
					i := i + 1;
					if i = 2000000 then
						i := 1;
						STATE_10Hz <= LO_10Hz;
					end if;
--------------------------------------------------------------------------------	
				when LO_10Hz =>			
					CLK_10Hz <= '0';
					i := i + 1;
					if i = 2000000 then
						i := 1;
						STATE_10Hz <= HI_10Hz;
					end if;
--------------------------------------------------------------------------------	
				when others =>	STATE_10Hz<=HI_10Hz;																
			end case;
		end if;
	end process;	
--------------------------------------------------------------------------------	
	process(xCLK_40MHz)
	variable i : integer range 200001 downto 0;
	begin
		if xCLR_ALL = '1' then
			CLK_100Hz <= '1';
			i:= 0;
			STATE_100Hz <= HI_100Hz;
		elsif rising_edge(xCLK_40MHz) then
--------------------------------------------------------------------------------			
			case STATE_100Hz is
--------------------------------------------------------------------------------	
				when HI_100Hz =>			
					CLK_100Hz <= '1';
					i := i + 1;
					if i = 200000 then
						i := 1;
						STATE_100Hz <= LO_100Hz;
					end if;
--------------------------------------------------------------------------------	
				when LO_100Hz =>			
					CLK_100Hz <= '0';
					i := i + 1;
					if i = 200000 then
						i := 1;
						STATE_100Hz <= HI_100Hz;
					end if;
--------------------------------------------------------------------------------	
				when others =>	STATE_100Hz<=HI_100Hz;																
			end case;
		end if;
	end process;	
--------------------------------------------------------------------------------
	process(xCLK_40MHz)
	variable i : integer range 20001 downto 0;
	begin
		if xCLR_ALL = '1' then
			i:= 0;
			CLK_1kHz <= '1';
			STATE_1kHz <= HI_1kHz;
		elsif rising_edge(xCLK_40MHz) then
--------------------------------------------------------------------------------			
			case STATE_1kHz is
--------------------------------------------------------------------------------	
				when HI_1kHz =>			
					CLK_1kHz <= '1';
					i := i + 1;
					if i = 20000 then
						i := 1;
						STATE_1kHz <= LO_1kHz;
					end if;
--------------------------------------------------------------------------------	
				when LO_1kHz =>			
					CLK_1kHz <= '0';
					i := i + 1;
					if i = 20000 then
						i := 1;
						STATE_1kHz <= HI_1kHz;
					end if;
--------------------------------------------------------------------------------	
				when others =>	STATE_1kHz<=HI_1kHz;																
			end case;
		end if;
	end process;	
--------------------------------------------------------------------------------
end Behavioral;
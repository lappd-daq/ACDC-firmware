
--------------------------------------------------------------------------------	
-- Design by: eoberla																			--
-- DATE : 10 APRIL 2010																			--
-- Project name: PSEC2 firmware																--
--	Module name: MESS	  																			--
--	Description : 																					--
-- 	Master Event Synchronous Sequencer (MESS) module								--
--		  											    												--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MESS is
   port ( 
			 xSLWR			: in   std_logic;
			 xSTART		 	: in   std_logic;
			 xDONE		 	: in   std_logic;
			 xCLR_ALL	 	: in   std_logic;
			 xADC			: in   std_logic_vector (12 downto 0);
			 xROVDD			: in   std_logic_vector (11 downto 0);
			 xPROVDD		: in   std_logic_vector (11 downto 0);
			 xEVT_CNT		: in   std_logic_vector (10 downto 0);
			 xTRIG_LOC		: in   std_logic_vector (3 downto 0);
			 xFPGA_DATA     : out  std_logic_vector (15 downto 0);
			 xRADDR			: out  std_logic_vector (10 downto 0));
end MESS; 

architecture Behavioral of MESS is
	type STATE_TYPE is ( HDR_START,ADC,EVT_CNT,TRIG_LOCATE,HDR_END,GND_STATE);
	signal STATE 			: STATE_TYPE;
	signal RADDR			: std_logic_vector(10 downto 0);
	signal FPGA_DATA		: std_logic_vector(15 downto 0);
--------------------------------------------------------------------------------
begin
--------------------------------------------------------------------------------
	xFPGA_DATA <= FPGA_DATA;
	xRADDR <= RADDR;
--------------------------------------------------------------------------------
	process(xSLWR,xSTART,xDONE,xCLR_ALL)
	begin
		if xCLR_ALL = '1' or xDONE = '1' then
			RADDR 		<= (others=>'0');--"00000000001"; --(others=>'0');
			FPGA_DATA 	<= (others=>'0');
			STATE 		<= HDR_START;
		elsif falling_edge(xSLWR) and xSTART = '1' then
--------------------------------------------------------------------------------			
			case STATE is
--------------------------------------------------------------------------------	
				when HDR_START =>	
					FPGA_DATA <= x"1234";
					STATE <= ADC;	
--------------------------------------------------------------------------------					
				when ADC =>	
					FPGA_DATA <= "000" & xADC;
					RADDR <= RADDR + 1;
					if RADDR = 1540 then       --256
					--if RADDR = 265 then       --256
						RADDR <= (others=>'0');
						STATE <= EVT_CNT;	
					end if;
--------------------------------------------------------------------------------	
				when EVT_CNT =>	
					FPGA_DATA <= x"0" & "0" & xEVT_CNT;		
					STATE <= TRIG_LOCATE;	
--------------------------------------------------------------------------------	
				when TRIG_LOCATE =>	
					FPGA_DATA <= x"000" & xTRIG_LOC;		
					STATE <= HDR_END;	
--------------------------------------------------------------------------------	
				when HDR_END =>	
					FPGA_DATA <= x"4321";		
					STATE <= GND_STATE;	
--------------------------------------------------------------------------------	
				when GND_STATE =>			
					FPGA_DATA <= (others=>'0');
--------------------------------------------------------------------------------	
				when others =>	STATE<=HDR_START;																
			end case;
		end if;
	end process;		
--------------------------------------------------------------------------------		
end Behavioral;
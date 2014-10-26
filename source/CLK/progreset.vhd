
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------																															
-- Design by: ejo															--
-- DATE : 10 March 2009																			--													--
-- FPGA chip :	altera cyclone III series									   --
-- USB chip : CYPRESS CY7C68013  															--
--	Module name: PROGRESET        															--
--	Description : 																					--
-- 	progreset will reset other modules                        				--
--																										--
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

--------------------------------------------------------------------------------
--   								I/O Definitions		   						         --
--------------------------------------------------------------------------------

entity PROGRESET is
    Port ( 	CLK     : 	in std_logic; 		-- CLOCK	48MHz
         -- 	WAKEUP  : 	in std_logic; 		-- Active High Powered up USB
			Clr_all : 	out std_logic; 	-- Active High Clr_all
           	GLRST   : 	out std_logic); 	-- RESET low-active
end PROGRESET;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

architecture Behavioral of PROGRESET is
	type State_type is(RESETD, NORMAL);
	signal state: State_type;	
	signal POS_COUNTER 	: 	std_logic_vector(31 downto 0) := (others=>'0');
	signal POS_LOGIC		:	std_logic	:= '0';
	
begin
	
	process(CLK)
	begin
		--state <= RESETD;
		if rising_edge(CLK) then
			case state is
				when RESETD =>
					POS_LOGIC <= '0';
					if POS_COUNTER = x"3FFFF" then
					--if POS_COUNTER = x"04FFFFFF" then
						state <= NORMAL;
					else
						POS_COUNTER <= POS_COUNTER + 1;
						state <= RESETD;
					end if;
					
				when NORMAL =>
					POS_LOGIC <= '1';
			end case;
		end if;
	end process;
		
	
	process(POS_LOGIC) 
	begin	
		if POS_LOGIC = '0' then
				GLRST 	<= '0';
				Clr_all 	<= '1';
		else
				GLRST 	<= '1';
				Clr_all 	<= '0';
		end if;
	end process;

end Behavioral;

--------------------------------------------------------------------------------
--   			                 	The End        						   	         --
--------------------------------------------------------------------------------
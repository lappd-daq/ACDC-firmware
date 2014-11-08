
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
          	WAKEUP  : 	in std_logic; 		
				Clr_all : 	out std_logic; 	-- Active High Clr_all
           	GLRST   : 	out std_logic); 	-- RESET low-active
end PROGRESET;

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

architecture Behavioral of PROGRESET is
	type State_type is(RESETD, NORMAL);
	signal state: State_type;	

	type		System_reset is (RESETS, NORMALS);
	signal   reset_state : System_reset;
	
	signal POS_COUNTER 	: 	std_logic_vector(31 downto 0) := (others=>'0');
	signal POS_LOGIC		:	std_logic	:= '0';
	 
	signal led_reset  	:	std_logic := '0';
	signal led_temp  		:	std_logic := '0';	
	signal led_temp_temp :	std_logic;	
	
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
		
	process(CLK, WAKEUP)
	begin
		if led_reset = '1' then
			led_temp <= '0';
		elsif rising_edge(WAKEUP) then
			led_temp <= '1';		
		end if;
	end process;
	process(CLK, led_temp)
	variable i : integer range 100010 downto 0 := 0;	
		begin
		if led_temp = '0' then
			led_temp_temp <= '0';
			led_reset <= '0';
			i := 0;
			reset_state <= RESETS;
		elsif rising_edge(CLK) and led_temp = '1' then
			case reset_state is
				when RESETS =>
					if i > 100000 then
						i := 0;
						led_temp_temp <= '0';
						reset_state <= NORMALS;
					else
						i := i + 1;
						led_temp_temp <= '1';
					end if;
					
				when NORMALS =>
					led_reset <= '1';
			end case;
		end if;
	end process;
	
	process(POS_LOGIC) 
	begin	
		if POS_LOGIC = '0' or led_temp_temp = '1' then
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
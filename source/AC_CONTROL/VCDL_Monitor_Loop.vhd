----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:44:23 11/07/2011 
-- Design Name: 
-- Module Name:    VCDL_Monitor_Loop - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity VCDL_Monitor_Loop is
        Port (
                                RESET_FEEDBACK      : in std_logic;
                                REFRESH_CLOCK       : in std_logic; --One period of this clock defines how long we count Wilkinson rate pulses
                                VCDL_MONITOR_BIT    : in std_logic;
                                CURRENT_COUNT_VALUE : out std_logic_vector(31 downto 0)
        );
end VCDL_Monitor_Loop;

architecture Behavioral of VCDL_Monitor_Loop is
        type STATE_TYPE is ( MONITORING, SETTLING, LATCHING, CLEARING_AND_ADJUSTING );
        signal internal_STATE                   : STATE_TYPE := MONITORING;
        signal internal_COUNTER_ENABLE          : std_logic := '0';
        signal internal_COUNTER_CLEAR           : std_logic := '0';
        signal internal_COUNTER_VALUE           : unsigned(31 downto 0);
        signal internal_COUNTER_VALUE_LATCHED   : unsigned(31 downto 0);
begin
        CURRENT_COUNT_VALUE <= std_logic_vector(internal_COUNTER_VALUE_LATCHED);

        process(REFRESH_CLOCK)
        begin
                if (rising_edge(REFRESH_CLOCK)) then
                        case internal_STATE is
                                when MONITORING =>
                                        internal_COUNTER_ENABLE <= '1';
                                        internal_COUNTER_CLEAR  <= '0';
                                        internal_STATE <= SETTLING;
                                when SETTLING =>
                                        internal_COUNTER_ENABLE <= '0';
                                        internal_COUNTER_CLEAR  <= '0';
                                        internal_STATE <= LATCHING;
                                when LATCHING =>
                                        internal_COUNTER_ENABLE <= '0';
                                        internal_COUNTER_CLEAR  <= '0';
                                        internal_COUNTER_VALUE_LATCHED <= internal_COUNTER_VALUE;
                                        internal_STATE <= CLEARING_AND_ADJUSTING;
													
                                when CLEARING_AND_ADJUSTING =>
                                        internal_COUNTER_ENABLE <= '0';
                                        internal_COUNTER_CLEAR  <= '1';
                                        internal_STATE <= MONITORING;
                                when others =>
                                        internal_STATE <= MONITORING;
                        end case;
                end if;
        end process;

        process(VCDL_MONITOR_BIT, internal_COUNTER_ENABLE, internal_COUNTER_CLEAR) 
        begin
                if (internal_COUNTER_CLEAR = '1') then
                        internal_COUNTER_VALUE <= (others => '0');
                elsif ( internal_COUNTER_ENABLE = '1' and rising_edge(VCDL_MONITOR_BIT) ) then
                        internal_COUNTER_VALUE <= internal_COUNTER_VALUE + 1;
                end if;
        end process;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity GPIOing is
port(
	xGPIO_2v5_1		:	out		std_logic_vector(11 downto 0);
	xGPIO_2v5_2		:  out		std_logic_vector(29 downto 27);
	xCAL_PULSE_EN	:	in			std_logic_vector(14 downto 0));
end GPIOing;

architecture Behavioral of GPIOing is


begin

	xGPIO_2v5_1(11 downto 0) 	<= xCAL_PULSE_EN(11 downto 0);
	xGPIO_2v5_2(29 downto 27)	<= xCAL_PULSE_EN(14 downto 12);
	
end Behavioral;

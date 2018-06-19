-- Copyright (C) 2018  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and its AMPP partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 18.0.0 Build 614 04/24/2018 SJ Standard Edition"
-- CREATED		"Wed May 09 14:09:47 2018"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY lvds_tranceivers IS 
	PORT
	(
		TX_CLK :  IN  STD_LOGIC;
		RX_ALIGN :  IN  STD_LOGIC;
		RX_LVDS_DATA :  IN  STD_LOGIC;
		RX_CLK :  IN  STD_LOGIC;
		TX_DATA :  IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		TX_OUTCLK :  OUT  STD_LOGIC;
		RX_OUTCLK :  OUT  STD_LOGIC;
		RX_DATA :  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		TX_LVDS_DATA :  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END lvds_tranceivers;

ARCHITECTURE bdf_type OF lvds_tranceivers IS 

COMPONENT altlvds_tx0
	PORT(tx_inclock : IN STD_LOGIC;
		 tx_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
		 tx_outclock : OUT STD_LOGIC;
		 tx_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT altlvds_rx0
	PORT(rx_data_align : IN STD_LOGIC;
		 rx_inclock : IN STD_LOGIC;
		 rx_in : IN STD_LOGIC_VECTOR(0 TO 0);
		 rx_outclock : OUT STD_LOGIC;
		 rx_out : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
	);
END COMPONENT;



BEGIN 



lvds_tx : altlvds_tx0
PORT MAP(tx_inclock => TX_CLK,
		 tx_in => TX_DATA,
		 tx_outclock => TX_OUTCLK,
		 tx_out => TX_LVDS_DATA);


lvds_rx : altlvds_rx0
PORT MAP(rx_data_align => RX_ALIGN,
		 rx_inclock => RX_CLK,
		 rx_in(0) => RX_LVDS_DATA,
		 rx_outclock => RX_OUTCLK,
		 rx_out => RX_DATA);


END bdf_type;
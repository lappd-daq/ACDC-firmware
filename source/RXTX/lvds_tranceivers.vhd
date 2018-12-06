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

use work.Definition_Pool.all;


ENTITY lvds_tranceivers IS 
	PORT
	(
		CLK 				: 	IN  STD_LOGIC;
		RST 				:  IN  STD_LOGIC;
		CLK_COMS			:  IN  STD_LOGIC;
		RX_LVDS_DATA 	:  IN  STD_LOGIC;
		TX_DATA 			:  IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		TX_DATA_RDY		:  IN  STD_LOGIC;
		REMOTE_UP		:  OUT STD_LOGIC;
		REMOTE_VALID	:  OUT STD_LOGIC;
		TX_BUF_FULL		:  out std_logic;
		RX_ERROR			:  OUT  STD_LOGIC; --coding error & dispairty error
		RX_DATA_RDY		:  out  STD_LOGIC;
		RX_DATA 			:  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		TX_LVDS_DATA 	:  OUT  STD_LOGIC
	);
END lvds_tranceivers;

ARCHITECTURE bdf_type OF lvds_tranceivers IS 

component tx_fifo
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
end component;


component rx_fifo
	PORT
	(
		aclr		: IN STD_LOGIC  := '0';
		data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdclk		: IN STD_LOGIC ;
		rdreq		: IN STD_LOGIC ;
		wrclk		: IN STD_LOGIC ;
		wrreq		: IN STD_LOGIC ;
		q		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		rdempty		: OUT STD_LOGIC ;
		wrfull		: OUT STD_LOGIC 
	);
end component;

-- 8b10b components

COMPONENT encoder_8b10b
	GENERIC ( METHOD : INTEGER := 1 );
	PORT
	(
		clk		:	 IN STD_LOGIC;
		rst		:	 IN STD_LOGIC;
		kin_ena		:	 IN STD_LOGIC;		-- Data in is a special code, not all are legal.	
		ein_ena		:	 IN STD_LOGIC;		-- Data (or code) input enable
		ein_dat		:	 IN STD_LOGIC_VECTOR(7 DOWNTO 0);		-- 8b data in
		ein_rd		:	 IN STD_LOGIC;		-- running disparity input
		eout_val		:	 OUT STD_LOGIC;		-- data out is valid
		eout_dat		:	 OUT STD_LOGIC_VECTOR(9 DOWNTO 0);		-- data out
		eout_rdcomb		:	 OUT STD_LOGIC;		-- running disparity output (comb)
		eout_rdreg		:	 OUT STD_LOGIC		-- running disparity output (reg)
	);
END COMPONENT;

COMPONENT decoder_8b10b
	GENERIC ( RDERR : INTEGER := 1; KERR : INTEGER := 1; METHOD : INTEGER := 1 );
	PORT
	(
		clk		:	 IN STD_LOGIC;
		rst		:	 IN STD_LOGIC;
		din_ena		:	 IN STD_LOGIC;		-- 10b data ready
		din_dat		:	 IN STD_LOGIC_VECTOR(9 DOWNTO 0);		-- 10b data input
		din_rd		:	 IN STD_LOGIC;		-- running disparity input
		dout_val		:	 OUT STD_LOGIC;		-- data out valid
		dout_dat		:	 OUT STD_LOGIC_VECTOR(7 DOWNTO 0);		-- data out
		dout_k		:	 OUT STD_LOGIC;		-- special code
		dout_kerr		:	 OUT STD_LOGIC;		-- coding mistake detected
		dout_rderr		:	 OUT STD_LOGIC;		-- running disparity mistake detected
		dout_rdcomb		:	 OUT STD_LOGIC;		-- running disparity output (comb)
		dout_rdreg		:	 OUT STD_LOGIC		-- running disparity output (reg)
	);
END COMPONENT;

COMPONENT uart
	GENERIC ( BITS	: INTEGER := 10;
				 CLK_HZ : INTEGER := 50000000; 
				 BAUD : INTEGER := 115200
				 );
	PORT
	(
		clk				:	 IN STD_LOGIC;
		rst				:	 IN STD_LOGIC;
		tx_data			:	 IN STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
		tx_data_valid	:	 IN STD_LOGIC;
		tx_data_ack		:	 OUT STD_LOGIC;
		tx_ready			:  OUT STD_LOGIC;
		txd				:	 OUT STD_LOGIC;
		rx_data			:	 OUT STD_LOGIC_VECTOR(BITS-1 DOWNTO 0);
		rx_data_fresh	:	 OUT STD_LOGIC;
		rxd				:	 IN STD_LOGIC
	);
END COMPONENT;

TYPE TX_STATE_TYPE is (RESET, READY, UART_WAIT_LSB, UART_WAIT, UART_BUSY_LSB, UART_BUSY);
signal TX_STATE		: TX_STATE_TYPE;

signal tx_data_ack	:  std_logic;		-- data acknowledge from the UART
signal tx_ready			:  std_logic;
signal rx_data_fresh :  std_logic;		-- new data from the UART

type LINK_STATE_TYPE is (DOWN, CHECKING, UP, ERROR);
signal LINK_STATE : LINK_STATE_TYPE;
signal REMOTE_LINK_STATE	:  LINK_STATE_TYPE;

signal LINK_STATE_OUT				:  std_logic_vector(7 downto 0);

signal RX_DATA10						:	std_logic_vector(9 downto 0);
signal TX_DATA10						: 	std_logic_vector(9 downto 0);

-- 8b/10b sigals
signal tx_enc_data				:  std_logic_vector(7 downto 0); 	-- input to the encoder, either code or data
signal TX_RDreg	: std_logic;
signal RX_RDreg	: std_logic;
signal kin_ena 	:	std_logic;		-- Data in is a special code, not all are legal.	
signal ein_ena 	:	std_logic;		-- Data (or code) input enable
signal eout_val	:  std_logic;		-- Encoder output valid.
signal dout_val 	:	std_logic;		-- data out valid
signal dout_dat	:  std_logic_vector(7 downto 0);
signal dout_k		:  std_logic;		-- data is a k-code
signal dout_kerr	:  std_logic;		-- coding error
signal dout_rderr	:  std_logic;		-- dispairty error


-- fifo signals
signal tx_fifo_rdreq		:  std_logic;
signal tx_fifo_out		:  std_logic_vector(15 downto 0);
signal tx_fifo_empty		:  std_logic;
signal rx_fifo_empty		:  std_logic;
signal rx_fifo_rdreq		:  std_logic;




BEGIN 

-- Send side:

tx_buf : tx_fifo
	PORT MAP(
		aclr	=> RST,
		data	=> TX_DATA,
		rdclk	=> CLK_COMS,
		rdreq	=> tx_fifo_rdreq,
		wrclk	=> CLK,
		wrreq	=> TX_DATA_RDY,
		q		=> tx_fifo_out,
		rdempty	=> tx_fifo_empty,
		wrfull	=> TX_BUF_FULL 
	);


-- either send k-codes or data, depending on the fifo.
tx_enc_input : process(RST, CLK_COMS)
variable tx_fifo_out_msb	: std_logic_vector(7 downto 0);
begin
	if RST = '1' then
		TX_STATE <= RESET;
		tx_enc_data <= (others => '0');
		kin_ena <= '0';
		ein_ena <= '0';
		tx_fifo_rdreq <= '0';
		tx_fifo_out_msb := (others => '0');
	elsif rising_edge(CLK_COMS) then
		case TX_STATE is
			when RESET =>
				TX_STATE <= READY;
				tx_enc_data <= (others => '0');
				kin_ena <= '0';
				ein_ena <= '0';
				tx_fifo_rdreq <= '0';
				tx_fifo_out_msb := (others => '0');
			when READY =>
				if tx_fifo_empty = '0' then
					tx_fifo_out_msb := tx_fifo_out(15 downto 8);
					tx_enc_data <= tx_fifo_out(7 downto 0);
					kin_ena <= '0';
					ein_ena <= '1';
					tx_fifo_rdreq <= '1';  --acknowlege fifo read
					TX_STATE <= UART_WAIT_LSB;
				else
					tx_enc_data <= LINK_STATE_OUT;
					kin_ena <= '1';
					ein_ena <= '1';
					tx_fifo_rdreq <= '0';
					TX_STATE <= UART_WAIT;  --only send one byte k-codes.
				end if;
			when UART_WAIT_LSB =>
				tx_fifo_rdreq <= '0';
				kin_ena <= '0';
				ein_ena <= '0';
				if tx_data_ack = '1' then -- send the msb
					TX_STATE <= UART_BUSY_LSB;
				end if;
			when UART_BUSY_LSB =>
				if tx_ready = '1' then
					tx_enc_data <= tx_fifo_out_msb;
					kin_ena <= '0';
					ein_ena <= '1';
					TX_STATE <= UART_WAIT;
				end if;
			when UART_WAIT =>  -- last byte (either code or msb of data)
				tx_fifo_rdreq <= '0';
				kin_ena <= '0';
				ein_ena <= '0';
				if tx_data_ack = '1' then
					TX_STATE <= UART_BUSY;
				end if;
			when UART_BUSY =>
				if tx_ready = '1' then
					TX_STATE <= READY;
				end if;
			when others =>
				TX_STATE <= RESET;	
		end case;
	end if;
end process;


tx_enc0 : encoder_8b10b
	GENERIC MAP( METHOD => 0 )
	PORT MAP(
		clk => CLK_COMS,
		rst => RST,
		kin_ena => kin_ena,		-- Data in is a special code, not all are legal.	
		ein_ena => ein_ena,		-- Data (or code) input enable
		ein_dat => tx_enc_data(7 downto 0),		-- 8b data in
		ein_rd => TX_RDreg,		-- running disparity input
		eout_val => eout_val,		-- data out is valid
		eout_dat => TX_DATA10(9 downto 0),		-- data out
		eout_rdcomb => open,		-- running disparity output (comb)
		eout_rdreg => TX_RDreg);		-- running disparity output (reg)


uart0 : uart
	GENERIC map 
	(	BITS => 10,
		CLK_HZ	=> 160000000,
		BAUD => 10000000)
	PORT map
	(
		clk => CLK_COMS,
		rst => RST,
		tx_data => TX_DATA10,
		tx_data_valid => eout_val,
		tx_data_ack	=> tx_data_ack,
		tx_ready	=> tx_ready,
		txd => TX_LVDS_DATA,
		rx_data => RX_DATA10,
		rx_data_fresh => rx_data_fresh,
		rxd => RX_LVDS_DATA
	);

-- Receive Side: 

rx_dec : decoder_8b10b
	GENERIC MAP(
		RDERR =>1,
		KERR => 1,
		METHOD => 0)
	PORT MAP(
		clk => CLK_COMS,
		rst => RST,
		din_ena => rx_data_fresh,		-- 10b data ready
		din_dat => RX_DATA10(9 downto 0),		-- 10b data input
		din_rd => RX_RDreg,		-- running disparity input
		dout_val => dout_val,		-- data out valid
		dout_dat => dout_dat(7 downto 0),		-- data out
		dout_k => dout_k,		-- special code
		dout_kerr => dout_kerr,		-- coding mistake detected
		dout_rderr => dout_rderr,		-- running disparity mistake detected
		dout_rdcomb => open,		-- running disparity output (comb)
		dout_rdreg => RX_RDreg);		-- running disparity output (reg)

--Check if Link is disconnected
process(CLK_COMs, RST)
variable counter 	: integer range 200000000 downto 0;
variable dff1,dff2,dff3		: std_logic;
variable edge		: std_logic;
begin
	if RST = '1' then
		dff1		:= '0';
		dff2		:= '0';
		dff3		:= '0';
		edge		:= dff2 xor dff3;
		counter	:= 0;
		LINK_STATE <= DOWN;
		LINK_STATE_OUT <= K28_1;
	elsif rising_edge(CLK_COMs) then
		edge 	:= dff2 xor dff3;
		dff3  := dff2;
		dff2	:= dff1;
		dff1  := RX_LVDS_DATA;
		case LINK_STATE is
			when DOWN =>
				if edge = '1' then
					counter := 0;
					LINK_STATE <= CHECKING;
					LINK_STATE_OUT <=  K28_7;
				else
					LINK_STATE_OUT <= K28_1;
				end if;
			when others =>
				if dout_val = '1' and dout_kerr = '0' then
					counter := 0;
					LINK_STATE <= UP;
					LINK_STATE_OUT <= K28_5;
				elsif dout_kerr = '1' or dout_rderr = '1' then
					counter := 0;
					LINK_STATE <= ERROR;
					LINK_STATE_OUT <= K27_7;
				else
					counter := counter + 1;
					if counter > 160000000 then -- check if we're past timeout
						LINK_STATE <= DOWN;
						LINK_STATE_OUT <=  K28_1;
						counter := 0;
					end if;
				end if;
		end case;
	end if;
end process;

RX_ERROR  <= dout_kerr OR dout_rderr;
		
RX_DATA_RDY <= (NOT rx_fifo_empty);

rx_buf : rx_fifo
	PORT MAP(
		aclr	=> RST,
		data	=> dout_dat,
		rdclk	=> CLK,
		rdreq	=> NOT rx_fifo_empty,
		wrclk	=> CLK_COMS,
		wrreq	=> dout_val,
		q		=> RX_DATA,
		rdempty	=> rx_fifo_empty,
		wrfull	=> open  -- should probably include backpressure.
	);



process(CLK_COMS, RST)
begin
	if RST = '1' then
		REMOTE_UP <= '0';
		REMOTE_VALID <= '0';
		REMOTE_LINK_STATE <= DOWN;
	elsif rising_edge(CLK_COMS) then
		if (dout_k = '1') and dout_val = '1' then
			case dout_dat is
				when K28_1 =>  -- link down
							REMOTE_LINK_STATE <= DOWN;
							REMOTE_UP <= '0';
							REMOTE_VALID <= '0';
				when K28_7 =>  -- link up but decoder doesn't see valid data
							REMOTE_LINK_STATE <= CHECKING;
							REMOTE_UP <= '1';
							REMOTE_VALID <= '0';
				when K28_5 =>  -- link is up and data is valid
							REMOTE_LINK_STATE <= UP;
							REMOTE_UP <= '1';
							REMOTE_VALID <= '1';
				when K27_7 =>
							REMOTE_LINK_STATE <= ERROR;
							REMOTE_UP <= '1';
							REMOTE_VALID <= '0';
				when others =>  -- Something unexpected
							REMOTE_LINK_STATE <= ERROR;
							REMOTE_UP <= '0';
							REMOTE_VALID <= '0';
			end case;
		end if;
	end if;
end process;


END bdf_type;
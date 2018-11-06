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
		TX_CLK 			:  IN  STD_LOGIC;
		RX_ALIGN 		:  IN  STD_LOGIC;
		RX_LVDS_DATA 	:  IN  STD_LOGIC;
		RX_CLK 			:  IN  STD_LOGIC;
		TX_DATA 			:  IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
		TX_DATA_RDY		:  IN  STD_LOGIC;
		REMOTE_UP		:  OUT STD_LOGIC;
		REMOTE_VALID	:  OUT STD_LOGIC;
		TX_BUF_FULL		:  out std_logic;
		RX_BUF_EMPTY	:  out std_logic;
		TX_OUTCLK 		:  OUT  STD_LOGIC;
		RX_OUTCLK 		:  OUT  STD_LOGIC;
		RX_ERROR			:  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0); --coding error & dispairty error
		RX_DATA 			:  OUT  STD_LOGIC_VECTOR(7 DOWNTO 0);
		TX_LVDS_DATA 	:  OUT  STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END lvds_tranceivers;

ARCHITECTURE bdf_type OF lvds_tranceivers IS 


COMPONENT altlvds_tx0
	PORT(tx_inclock : IN STD_LOGIC;
		 tx_in : IN STD_LOGIC_VECTOR(19 DOWNTO 0);
		 tx_outclock : OUT STD_LOGIC;
		 tx_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
	);
END COMPONENT;

COMPONENT altlvds_rx0
	PORT(rx_data_align : IN STD_LOGIC;
		 rx_inclock : IN STD_LOGIC;
		 rx_in : IN STD_LOGIC_VECTOR(0 TO 0);
		 rx_outclock : OUT STD_LOGIC;
		 rx_out : OUT STD_LOGIC_VECTOR(9 DOWNTO 0)
	);
END COMPONENT;

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

component lvds_cdr
	port (
		-- Input ports
		reset 	: in  std_logic;
		enable	: in  std_logic;
		base_clk	: in  std_logic;
		lvds_clk	: in  std_logic := '0';
		lvds_data	: in  std_logic := '0';

		-- Output ports
		rx_clk	: out  std_logic := '0';
		rx_fastclk	: out  std_logic := '0';
		rx_clk_ready	: out  std_logic := '0');
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

type LINK_STATE_TYPE is (DOWN, CHECKING, UP);
signal LINK_STATE : LINK_STATE_TYPE;

type RX_ALIGNMENT_TYPE is (RESET, ALIGNING, READY);
signal RX_ALIGNMENT_STATE : RX_ALIGNMENT_TYPE;

signal LINK_STATE_OUT				:  std_logic_vector(15 downto 0);

signal RX_CLK_LOCAL					:  std_logic := 'X';
signal RX_DATA10						:	std_logic_vector(9 downto 0);
signal TX_DATA10						: 	std_logic_vector(19 downto 0);

signal ALIGNED_RX_CLK 			:  std_logic;
signal ALIGNED_RX_FASTCLK 		:  std_logic;
signal ALIGNED_RX_CLK_READY 	:  std_logic;

-- 8b/10b sigals
signal tx_enc_data				:  std_logic_vector(15 downto 0); 	-- input to the encoder, either code or data
signal TX_RDcomb	: std_logic;
signal TX_RDreg	: std_logic;
signal RX_RDreg	: std_logic;
signal kin_ena 	:	std_logic;		-- Data in is a special code, not all are legal.	
signal ein_ena 	:	std_logic;		-- Data (or code) input enable
signal din_ena 	:	std_logic;		-- Data (or code) input enable
signal dout_val 	:	std_logic;		-- data out valid
signal dout_dat	:  std_logic_vector(7 downto 0);
signal dout_k		:  std_logic;		-- data is a k-code
signal dout_kerr	:  std_logic;		-- coding error
signal dout_rderr	:  std_logic;		-- dispairty error


signal cdr_enable : std_logic;	-- enable the clock alignment module.

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
		rdclk	=> TX_CLK,
		rdreq	=> tx_fifo_rdreq,
		wrclk	=> CLK,
		wrreq	=> TX_DATA_RDY,
		q		=> tx_fifo_out,
		rdempty	=> tx_fifo_empty,
		wrfull	=> TX_BUF_FULL 
	);

-- Depending on the RX link state, send a different K-Code
process(RX_CLK_LOCAL, RST)
begin
	if RST = '1' then
		LINK_STATE_OUT <= K28_1&K28_1;
		--TX_DATA <= ALIGN_WORD_16;
	elsif rising_edge(RX_CLK_LOCAL) then
		if (LINK_STATE /= UP) then
			LINK_STATE_OUT <= K28_1&K28_1;
		else
			if dout_val = '0' then  -- link is up, but decoder doesn't see valid data
				LINK_STATE_OUT <= K28_7&K28_7;
			else -- link is up and data is valid
				LINK_STATE_OUT <= K28_5&K28_5;
			end if;
		end if;
	end if;
end process;

-- either send k-codes or data, depending on the fifo.
tx_enc_input : process(RST, TX_CLK)
begin
	if RST = '1' then
		tx_enc_data <= (others => '0');
		kin_ena <= '0';
		ein_ena <= '0';
		tx_fifo_rdreq <= '0';
	elsif rising_edge(CLK) then
		if tx_fifo_empty = '0' then -- and the other side is locked.
			tx_enc_data <= tx_fifo_out;
			kin_ena <= '0';
			ein_ena <= '1';
			tx_fifo_rdreq <= '1';
		else
			tx_enc_data <= LINK_STATE_OUT;
			kin_ena <= '1';
			ein_ena <= '1';
			tx_fifo_rdreq <= '0';
		end if;
	end if;
end process;


tx_enc0 : encoder_8b10b
	GENERIC MAP( METHOD => 0 )
	PORT MAP(
		clk => TX_CLK,
		rst => RST,
		kin_ena => kin_ena,		-- Data in is a special code, not all are legal.	
		ein_ena => ein_ena,		-- Data (or code) input enable
		ein_dat => tx_enc_data(7 downto 0),		-- 8b data in
		ein_rd => TX_RDreg,		-- running disparity input
		eout_val => open,		-- data out is valid
		eout_dat => TX_DATA10(9 downto 0),		-- data out
		eout_rdcomb => TX_RDcomb,		-- running disparity output (comb)
		eout_rdreg => open);		-- running disparity output (reg)


tx_enc1 : encoder_8b10b
	GENERIC MAP( METHOD => 0 )
	PORT MAP(
		clk => TX_CLK,
		rst => RST,
		kin_ena => kin_ena,		-- Data in is a special code, not all are legal.	
		ein_ena => ein_ena,		-- Data (or code) input enable
		ein_dat => tx_enc_data(15 downto 8),		-- 8b data in
		ein_rd => TX_RDcomb,		-- running disparity input
		eout_val => open,		-- data out is valid
		eout_dat => TX_DATA10(19 downto 10),		-- data out
		eout_rdcomb => open,		-- running disparity output (comb)
		eout_rdreg => TX_RDreg);		-- running disparity output (reg)

lvds_tx : altlvds_tx0
PORT MAP(tx_inclock => TX_CLK,
		 tx_in => TX_DATA10,
		 tx_outclock => TX_OUTCLK,
		 tx_out => TX_LVDS_DATA);

		 
-- Receive Side: 

-- Get Bits from serdes
lvds_rx : altlvds_rx0
PORT MAP(rx_data_align => RX_ALIGN,
		 rx_inclock => ALIGNED_RX_CLK,
		 rx_in(0) => RX_LVDS_DATA,
		 rx_outclock => RX_CLK_LOCAL,
		 rx_out => RX_DATA10);

--Check if Link is disconnected
process(CLK)
variable i : integer range 5 downto 0;
begin
	if RST = '1' then
		LINK_STATE <= DOWN;
		i := 0;
	elsif rising_edge(CLK) then
		if RX_DATA10 = x"3FF" then
			LINK_STATE <= DOWN;
			i := 0;
		else
			if i < 5 then
				LINK_STATE <= CHECKING;
				i := i + 1;
			else
				LINK_STATE <= UP;
			end if;
		end if;
	end if;
end process;


--Align RX Clock
process(CLK)
begin
	if RST = '1' or LINK_STATE /= UP then
		RX_ALIGNMENT_STATE <= RESET;
	else
		case RX_ALIGNMENT_STATE is 
			when RESET =>
				if (LINK_STATE <= UP) or (ALIGNED_RX_CLK_READY = '1') then
					RX_ALIGNMENT_STATE <= ALIGNING;
				end if;
			when ALIGNING =>
				if ALIGNED_RX_CLK_READY = '1' then
					RX_ALIGNMENT_STATE <= READY;
				end if;
			when READY =>
				if ALIGNED_RX_CLK_READY = '0' then
					RX_ALIGNMENT_STATE <= ALIGNING;
				end if;
			when others =>
				-- should never happen
				RX_ALIGNMENT_STATE <= RESET;
		end case;
	end if;
end process;

cdr_enable <= '0' when RX_ALIGNMENT_STATE = RESET else '1';
cdr : lvds_cdr
	PORT MAP
	(
		-- Input ports
		reset => RST,
		enable => cdr_enable,
		base_clk => CLK,
		lvds_clk	=> RX_CLK,
		lvds_data => RX_LVDS_DATA,

		-- Output ports
		rx_clk => ALIGNED_RX_CLK,
		rx_fastclk => ALIGNED_RX_FASTCLK,
		rx_clk_ready => ALIGNED_RX_CLK_READY
	);

din_ena <= '1' when RX_ALIGNMENT_STATE = READY else '0';

rx_dec : decoder_8b10b
	GENERIC MAP(
		RDERR =>1,
		KERR => 1,
		METHOD => 0)
	PORT MAP(
		clk => RX_CLK_LOCAL,
		rst => RST,
		din_ena => din_ena,		-- 10b data ready
		din_dat => RX_DATA10(9 downto 0),		-- 10b data input
		din_rd => RX_RDreg,		-- running disparity input
		dout_val => dout_val,		-- data out valid
		dout_dat => dout_dat(7 downto 0),		-- data out
		dout_k => dout_k,		-- special code
		dout_kerr => dout_kerr,		-- coding mistake detected
		dout_rderr => dout_rderr,		-- running disparity mistake detected
		dout_rdcomb => open,		-- running disparity output (comb)
		dout_rdreg => RX_RDreg);		-- running disparity output (reg)

		
RX_ERROR  <= dout_kerr & dout_rderr;
		
rx_fifo_rdreq <= (NOT rx_fifo_empty) and (NOT RST);

rx_buf : rx_fifo
	PORT MAP(
		aclr	=> RST,
		data	=> dout_dat,
		rdclk	=> CLK,
		rdreq	=> rx_fifo_rdreq,
		wrclk	=> RX_CLK_LOCAL,
		wrreq	=> dout_val,
		q		=> RX_DATA,
		rdempty	=> rx_fifo_empty,
		wrfull	=> open  -- should probably include backpressure.
	);



process(RX_CLK_LOCAL, RST)
begin
	if RST = '1' then
		REMOTE_UP <= '0';
		REMOTE_VALID <= '0';
	elsif rising_edge(RX_CLK_LOCAL) then
		if (dout_k = '1') then
			case dout_dat is
				when K28_1 =>  -- link down
							REMOTE_UP <= '0';
							REMOTE_VALID <= '0';
				when K28_7 =>  -- link up but decoder doesn't see valid data
							REMOTE_UP <= '1';
							REMOTE_VALID <= '0';
				when K28_5 =>  -- link is up and data is valid
							REMOTE_UP <= '1';
							REMOTE_VALID <= '1';
				when others =>  -- Something unexpected
							REMOTE_UP <= '0';
							REMOTE_VALID <= '0';
			end case;
		end if;
	end if;
end process;


RX_OUTCLK <= RX_CLK_LOCAL;

END bdf_type;
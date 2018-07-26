--------------------------------------------------
-- module		: 	lvds_cdr
-- author		: 	Jonathan Eisch
-- date			: 	6/2018
-- description	:  LVDS clock recovery
--------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library altera; 
use altera.altera_primitives_components.all;

entity lvds_cdr is
	port
	(
		-- Input ports
		reset 	: in  std_logic;
		enable	: in  std_logic;
		sys_clk	: in  std_logic;
		lvds_clk	: in  std_logic := '0';
		lvds_data	: in  std_logic := '0';

		-- Output ports
		rx_clk	: out  std_logic := '0';
		rx_fastclk	: out  std_logic := '0';
		rx_clk_ready	: out  std_logic := '0'
	);

end lvds_cdr;

architecture behavioral of lvds_cdr is

component altpll_rx_phaseshift
	PORT
	(
		inclk0		: IN STD_LOGIC  := '0';
		phasecounterselect		: IN STD_LOGIC_VECTOR (2 DOWNTO 0) :=  (OTHERS => '0');
		phasestep		: IN STD_LOGIC  := '0';
		phaseupdown		: IN STD_LOGIC  := '0';
		scanclk		: IN STD_LOGIC  := '1';
		c0		: OUT STD_LOGIC ;
		c1		: OUT STD_LOGIC ;
		c2		: OUT STD_LOGIC ;
		c3		: OUT STD_LOGIC ;
		locked		: OUT STD_LOGIC ;
		phasedone		: OUT STD_LOGIC 
	);
end component;

type 	PD_STATE_TYPE is (WAIT_FOR_LOCK, CHECK_PHASE_READY, MEASURE_PHASE, ADJUST_PHASE, WAIT_FOR_PHASE_CHANGE);
--type 	GET_CC_INSTRUCT_TYPE is (IDLE, CATCH0, CATCH1, CATCH2, CATCH3, READY);
signal PD_STATE	:	PD_STATE_TYPE;

signal phasecounterselect	: STD_LOGIC_VECTOR (2 DOWNTO 0) :=  (OTHERS => '0');
signal phasestep	: STD_LOGIC  := '0';
signal phaseupdown	: STD_LOGIC  := '0';
signal locked	: STD_LOGIC  := '0';
signal phasedone	: STD_LOGIC  := '0';

signal local_rx_clk 	:  std_logic;
signal local_rx_clk_q	:  std_logic;
signal rx_fastclk_q	:  std_logic;

signal coarse_pd_ena 	:  std_logic;
signal coarse_pd_out 	:  std_logic;

begin

rx_clk <= local_rx_clk;

process(reset, locked, enable, phasedone, PD_STATE, local_rx_clk) is 
	-- Declaration(s) 
	variable history_n 	: integer range 0 to 255;
	variable history_reg 	: std_logic_vector(15 downto 0);
	variable history_state 	: integer range -31 to 31;
begin 
	if (reset = '1' OR locked = '0' or enable = '0') then
		phasecounterselect(2 downto 0) <= "001";  -- Select the M register for fine collective phase shift.  See CYIV-51005-2.4 page 5-32
		phasestep <= '0';
		phaseupdown <= '0';
		rx_clk_ready <= '0';
		history_n := 0;
		history_state := 0;
	elsif(phasedone = '0' and PD_STATE = WAIT_FOR_PHASE_CHANGE) then
		phasestep <= '0';
		PD_STATE <= CHECK_PHASE_READY;
	elsif(rising_edge(local_rx_clk)) then
		case PD_STATE is
			when WAIT_FOR_LOCK =>
				if locked = '1' then
					PD_STATE <= CHECK_PHASE_READY;
				end if;
			when CHECK_PHASE_READY =>
				if phasedone = '1' then
					PD_STATE <= MEASURE_PHASE;
				end if;
			when MEASURE_PHASE =>
				-- coarse_pd d-flipflop will be measuring the phase on this clock cycle.
				PD_STATE <= ADJUST_PHASE;
			when ADJUST_PHASE =>
				if coarse_pd_out = '0' then 
					phaseupdown <= '1'; 	-- move up if the input is 0 at the edge, or move down.
				else
					phaseupdown <= '0';
				end if;
				phasestep <= '0';
				PD_STATE <= WAIT_FOR_PHASE_CHANGE;
				if phaseupdown = '0' then
					history_state := history_state-1;
				else 
					history_state := history_state+1;
				end if;
				if history_n > 15 then
					if history_reg(15) = '0' then
						history_state := history_state+1;
					else 
						history_state := history_state-1;
					end if;
				end if;
				history_reg(15 downto 1) := history_reg(14 downto 0);
				history_reg(0) := phaseupdown;
				if history_n < 255 then
					history_n := history_n+1;
				end if;
				if (history_n) > 16 and (history_state <14) and (history_state > -14) then
					rx_clk_ready <= '1';
				end if;
			when WAIT_FOR_PHASE_CHANGE =>
				-- change out of this asynchronously above, this is only a failsafe
				null;
		end case;
	end if;
end process; 

coarse_pd_ena <= '1' when PD_STATE = MEASURE_PHASE else '0';

-- Instantiating DFFE
	coarse_pd : DFFE
	port map (
			d => lvds_clk,
			clk => local_rx_clk,
			clrn => '1',
			prn => '1',
			ena => coarse_pd_ena,
			q => coarse_pd_out
			);


altpll_rx_phaseshift_inst : altpll_rx_phaseshift 
	PORT MAP (
		inclk0	 => sys_clk,
		phasecounterselect	 => phasecounterselect,
		phasestep	 => phasestep,
		phaseupdown	 => phaseupdown,
		scanclk	 => sys_clk,
		c0	 => local_rx_clk,
		c1	 => local_rx_clk_q,
		c2	 => rx_fastclk,
		c3	 => rx_fastclk_q,
		locked	 => locked,
		phasedone	 => phasedone
	);


end behavioral;



## Generated SDC file "ACDC-1v1.out.sdc"

## Copyright (C) 1991-2012 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 12.1 Build 177 11/07/2012 SJ Full Version"

## DATE    "Mon Apr 06 18:41:43 2015"

##
## DEVICE  "EP4CGX110DF27C7"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {altera_reserved_tck} -period 100.000 -waveform { 0.000 50.000 } [get_ports {altera_reserved_tck}]
create_clock -name {clk_system_40} -period 25.000 -waveform { 0.000 12.500 } [get_ports {clk_system_40}]
create_clock -name {clk_local_200} -period 25.000 -waveform { 0.000 12.500 } [get_ports {clk_local_200}]
create_clock -name {PSEC_A_RD_CLK} -period 25.000 -waveform { 0.000 12.500 } [get_ports {PSEC_A_RD_CLK}]
create_clock -name {PSEC_B_RD_CLK} -period 25.000 -waveform { 0.000 12.500 } [get_ports {PSEC_B_RD_CLK}]
create_clock -name {PSEC_C_RD_CLK} -period 25.000 -waveform { 0.000 12.500 } [get_ports {PSEC_C_RD_CLK}]
create_clock -name {PSEC_D_RD_CLK} -period 25.000 -waveform { 0.000 12.500 } [get_ports {PSEC_D_RD_CLK}]
create_clock -name {PSEC_E_RD_CLK} -period 25.000 -waveform { 0.000 12.500 } [get_ports {PSEC_E_RD_CLK}]


#**************************************************************
# Create Generated Clock
#**************************************************************

create_generated_clock -name {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]} -source [get_pins {inst19|inst4|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -master_clock {clk_system_40} [get_pins {inst19|inst4|altpll_component|auto_generated|pll1|clk[0]}] 
create_generated_clock -name {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]} -source [get_pins {inst19|inst4|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 10 -phase 45.000 -master_clock {clk_system_40} [get_pins {inst19|inst4|altpll_component|auto_generated|pll1|clk[1]}] 
create_generated_clock -name {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]} -source [get_pins {inst19|inst10|altpll_component|auto_generated|pll1|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -divide_by 200 -master_clock {clk_local_200} [get_pins {inst19|inst10|altpll_component|auto_generated|pll1|clk[2]}] 
create_generated_clock -name {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock} -source [get_pins {inst2|xDC_lvds_tranceivers|inst|ALTLVDS_TX_component|auto_generated|lvds_tx_pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 4 -phase -90.000 -master_clock {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]} [get_pins {inst2|xDC_lvds_tranceivers|inst|ALTLVDS_TX_component|auto_generated|lvds_tx_pll|clk[0]}] 
create_generated_clock -name {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]} -source [get_pins {inst2|xDC_lvds_tranceivers|inst|ALTLVDS_TX_component|auto_generated|lvds_tx_pll|inclk[0]}] -duty_cycle 50.000 -multiply_by 1 -phase -22.500 -master_clock {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]} [get_pins {inst2|xDC_lvds_tranceivers|inst|ALTLVDS_TX_component|auto_generated|lvds_tx_pll|clk[1]}] 


#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************

set_clock_uncertainty -rise_from [get_clocks {clk_local_200}] -rise_to [get_clocks {clk_local_200}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_local_200}] -fall_to [get_clocks {clk_local_200}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_local_200}] -rise_to [get_clocks {clk_local_200}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_local_200}] -fall_to [get_clocks {clk_local_200}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_system_40}] -rise_to [get_clocks {clk_system_40}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {clk_system_40}] -fall_to [get_clocks {clk_system_40}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_system_40}] -rise_to [get_clocks {clk_system_40}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {clk_system_40}] -fall_to [get_clocks {clk_system_40}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -rise_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {altera_reserved_tck}] -fall_to [get_clocks {altera_reserved_tck}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.130  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.130  
set_clock_uncertainty -rise_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|fast_clock}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.130  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -setup 0.130  
set_clock_uncertainty -fall_from [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -hold 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {clk_local_200}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {clk_local_200}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {clk_local_200}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {clk_local_200}] -hold 0.070  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -setup 0.180  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -hold 0.190  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -setup 0.180  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -hold 0.190  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {clk_local_200}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {clk_local_200}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {clk_local_200}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {clk_local_200}] -hold 0.070  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -setup 0.180  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -hold 0.190  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -setup 0.180  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -hold 0.190  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -hold 0.130  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -setup 0.100  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -hold 0.130  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}]  0.150  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -rise_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -hold 0.130  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -setup 0.100  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {lvds_com:inst2|lvds_tranceivers:xDC_lvds_tranceivers|altlvds_tx0:inst|altlvds_tx:ALTLVDS_TX_component|altlvds_tx0_lvds_tx:auto_generated|wire_lvds_tx_pll_clk[1]}] -hold 0.130  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLKmain:inst19|altpll0:inst10|altpll:altpll_component|altpll0_altpll:auto_generated|wire_pll1_clk[2]}]  0.150  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[1]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -rise_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  
set_clock_uncertainty -fall_from [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}] -fall_to [get_clocks {CLKmain:inst19|altpll3:inst4|altpll:altpll_component|altpll3_altpll:auto_generated|wire_pll1_clk[0]}]  0.020  


#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************

set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 
set_clock_groups -asynchronous -group [get_clocks {altera_reserved_tck}] 


#**************************************************************
# Set False Path
#**************************************************************

set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[0]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[22]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[1]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[4]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[21]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[18]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[23]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[28]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[9]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[6]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[14]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[7]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[5]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[20]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[3]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[12]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[26]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[29]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[8]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[16]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[17]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[27]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[24]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[15]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[13]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[2]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[10]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[11]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_WAIT_FOR_SYS_TRIG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EN}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_RATE_ONLY}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[20]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[20]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[20]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[20]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[9]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[9]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[9]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[9]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[21]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[21]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[21]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[21]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[7]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[7]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[7]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[7]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[18]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[18]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[18]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[18]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[8]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[8]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[8]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[8]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[13]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[13]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[13]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[13]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[4]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[4]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[4]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[4]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[19]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[19]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[19]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[19]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[6]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[6]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[6]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[6]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[2]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[2]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[2]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[2]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[17]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[17]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[17]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[17]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[12]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[12]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[12]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[12]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[10]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[10]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[10]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[10]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[27]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[27]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[27]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[27]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[5]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[5]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[5]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[5]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[22]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[22]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[22]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[22]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[23]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[23]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[23]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[23]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[11]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[11]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[11]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[11]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[16]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[16]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[16]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[16]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[15]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[15]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[15]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[15]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[26]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[26]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[26]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[26]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[3]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[3]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[3]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[3]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[24]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[24]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[24]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[24]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[14]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[14]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[14]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[14]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|CC_EVENT_RESET}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[25]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[19]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[0]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[0]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[0]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[0]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[25]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[25]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[25]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[25]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[1]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[1]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[1]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[1]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[28]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[28]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[28]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[28]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[29]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[29]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[29]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[29]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {decode_instruct:inst5|CC_EVENT_RESET}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {decode_instruct:inst5|CC_EVENT_RESET}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|CC_EVENT_RESET}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {decode_instruct:inst5|CC_EVENT_RESET}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_FIRMWARE_FLAG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_FIRMWARE_FLAG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_FIRMWARE_FLAG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_FIRMWARE_FLAG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_WAIT_FOR_SYS_TRIG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[1]}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_WAIT_FOR_SYS_TRIG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[0]}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_WAIT_FOR_SYS_TRIG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[2]}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_WAIT_FOR_SYS_TRIG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_SAVE[3]}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[0]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[3]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[23]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[1]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[2]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[22]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[17]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[18]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[9]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[5]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[19]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[13]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[21]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[16]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[7]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[8]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[12]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[20]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[4]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[15]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[6]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[14]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[24]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[25]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[28]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[11]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[27]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[10]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[29]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|SELF_TRIG_MASK[26]}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|CC_EVENT_RESET}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_WAIT_FOR_SYS_TRIG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_SOFTWARE}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_SOFTWARE}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_FIRMWARE_FLAG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_FIRMWARE_FLAG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EN}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {decode_instruct:inst5|TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|USE_TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|USE_TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_RATE_ONLY}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|USE_SMA_TRIG_ON_BOARD}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|USE_SMA_TRIG_ON_BOARD}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_FIRMWARE_FLAG}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SMA_TRIG}]
set_false_path -from [get_keepers {decode_instruct:inst5|CC_EVENT_RESET}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SMA_TRIG}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|RESET_TRIG_FROM_SOFTWARE}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SMA_TRIG}]
set_false_path -from [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|USE_SMA_TRIG_ON_BOARD}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SMA_TRIG}]
set_false_path -from [get_keepers {decode_instruct:inst5|TRIG_VALID}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SMA_TRIG}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|led_temp_temp}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|led_temp_temp}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|POS_LOGIC}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SELF_TRIG_EXT_HI}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|POS_LOGIC}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|BIN_COUNT_HOLD}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|POS_LOGIC}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SMA_TRIG}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|led_temp_temp}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|SMA_TRIG}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|POS_LOGIC}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|clock_dll_reset_lo_lo[0]}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|POS_LOGIC}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|clock_dll_reset_lo_lo[1]}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|POS_LOGIC}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|clock_dll_reset_lo_lo[2]}]
set_false_path -from [get_keepers {CLKmain:inst19|PROGRESET:inst1|POS_LOGIC}] -to [get_keepers {AC_CONTROL:inst|psec4_trigger_GLOBAL:AC_TRIGGER_CONTROL|clock_dll_reset_lo_lo[3]}]


#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************


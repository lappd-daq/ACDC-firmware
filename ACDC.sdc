
 
# WARNING: Expected ENABLE_CLOCK_LATENCY to be set to 'ON', but it is set to 'OFF'
#          In SDC, create_generated_clock auto-generates clock latency
#
# ------------------------------------------
#
# Create generated clocks based on PLLs

#
# ------------------------------------------
#-waveform {0  12.500} 

# Original Clock Setting Name: master_clock0
create_clock 	-period "25.000 ns"  	[get_ports clk_system_40]
create_clock 	-period "25.000 ns"   [get_ports clk_local_200]


#create_clock -period "25.000 ns" \
					-name {clk40M}
				 
#create_clock -period 320MHz -name {xCLK}
					
create_clock -period 40MHz 	[get_ports PSEC_A_RD_CLK]
					
create_clock -period 40MHz 	[get_ports PSEC_B_RD_CLK]

create_clock -period 40MHz 	[get_ports PSEC_C_RD_CLK]
					
create_clock -period 40MHz 	[get_ports PSEC_D_RD_CLK]

create_clock -period 40MHz 	[get_ports PSEC_E_RD_CLK]

#create_clock [get_ports lvds_rx_in(1)]

#create_generated_clock -multiply_by 8 -source clk_system_40 -name CLKmain:inst6|altpll1:inst2|altpll:altpll_component|altpll1_altpll:auto_generated|wire_pll1_clk[0]

derive_pll_clocks -use_tan_name		

derive_clock_uncertainty		

# ---------------------------------------------

# ** Clock Latency
#    -------------

# ** Clock Uncertainty
#    -----------------

# ** Multicycles
#    -----------
# ** Cuts
#    ----

# ** Input/Output Delays
#    -------------------




# ** Tpd requirements
#    ----------------

# ** Setup/Hold Relationships
#    ------------------------

# ** Tsu/Th requirements
#    -------------------


# ** Tco/MinTco requirements
#    -----------------------



# ---------------------------------------------


# ####################################################################

#  Created by Genus(TM) Synthesis Solution 21.17-s066_1 on Tue Apr 29 00:34:19 EDT 2025

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1fF
set_units -time 1ps

# Set the current design
current_design Top_PipelinedCipher

create_clock -name "clk" -period 260.0 -waveform {0.0 130.0} [get_ports clk]
set_clock_gating_check -setup 0.0 

# ####################################################################
# Modified by Ali Aqdas on 2025-05-15 to Match the Frequency of 1.065 GHz
#  Created by Genus(TM) Synthesis Solution 21.17-s066_1 on Tue Apr 29 00:34:19 EDT 2025

# ####################################################################

set sdc_version 2.0

set_units -capacitance 1fF
set_units -time 1ps

# Set the current design
current_design Top_PipelinedCipher

create_clock -name "clk" -period 938.0 -waveform {0.0 469.0} [get_ports clk]
set_clock_gating_check -setup 0.0 

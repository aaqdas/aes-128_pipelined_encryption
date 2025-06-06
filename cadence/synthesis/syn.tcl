# *********************************************************
# Synthesis of AES Core
# *********************************************************


# *********************************************************
# Set Variables For Quick Modifications
# *********************************************************

set HOME_DIR "[exec pwd]/../../"
set RPT_DIR  "${HOME_DIR}/cadence/reports/"
set OUTPUT_DIR "${HOME_DIR}/cadence/output/"
set LIB_DIR "/home/min/a/aaqdas/Documents/aes_build/asap7nm/frontend/lib/"
set LEF_DIR "/home/min/a/aaqdas/Documents/aes_build/asap7nm/backend/lef/"
# set LIB_DIR  "/package/eda/cells/FreePDK15/NanGate_15nm_OCL_v0.1_2014_06_Apache.A/front_end/timing_power_noise/CCS/"
# set LEF_DIR "/package/eda/cells/FreePDK15/NanGate_15nm_OCL_v0.1_2014_06_Apache.A/back_end/lef/"
set RTL_DIR  "${HOME_DIR}/rtl/"
set TOP_LEVEL Top_PipelinedCipher

# Clock period in picoseconds
set CLK_PERIOD 260 
set CLK_PORT clk

set RTL_LIST [glob $RTL_DIR/*.v]

# set LEF_LIST { \
    # /package/eda/cells/FreePDK15/NanGate_15nm_OCL_v0.1_2014_06_Apache.A/back_end/lef/NanGate_15nm_OCL.tech.lef \
    # /package/eda/cells/FreePDK15/NanGate_15nm_OCL_v0.1_2014_06_Apache.A/back_end/lef/NanGate_15nm_OCL.macro.lef \
# }


# *********************************************************

# *********************************************************
set_db timing_time_unit 1ps
set_db max_cpus_per_server 16
set_db information_level 9
set_db auto_ungroup none
# Track filename with rows and columns for error reporting
set_db hdl_track_filename_row_col true

# Specifying Technology Library Path
set_db init_lib_search_path $LIB_DIR

# Specify RTL Directory Paths
set_db init_hdl_search_path $RTL_DIR

set LIB_LIST { \
    /home/min/a/aaqdas/Documents/aes_build/asap7nm/frontend/lib/asap7sc7p5t_AO_LVT_TT_nldm_211120.lib \
    /home/min/a/aaqdas/Documents/aes_build/asap7nm/frontend/lib/asap7sc7p5t_INVBUF_LVT_TT_nldm_220122.lib \
    /home/min/a/aaqdas/Documents/aes_build/asap7nm/frontend/lib/asap7sc7p5t_OA_LVT_TT_nldm_211120.lib \
    /home/min/a/aaqdas/Documents/aes_build/asap7nm/frontend/lib/asap7sc7p5t_SEQ_LVT_TT_nldm_220123.lib \
    /home/min/a/aaqdas/Documents/aes_build/asap7nm/frontend/lib/asap7sc7p5t_SIMPLE_LVT_TT_nldm_211120.lib \
}
set LEF_LIST { \
    /home/min/a/aaqdas/Documents/aes_build/asap7nm/backend/lef/asap7_tech_1x_201209.lef \
    /home/min/a/aaqdas/Documents/aes_build/asap7nm/backend/lef/asap7sc7p5t_28_L_1x_220121a.lef \
}

# Specify Technology Library Files
set_db library $LIB_LIST

# Read Libs
read_libs $LIB_LIST

# Read Physical Parameters for Better Estimate
read_physical -lefs $LEF_LIST

# Specify RTL Files 
read_hdl -sv $RTL_LIST

# Elaborating Top Level Design 
elaborate $TOP_LEVEL

# Checking for Unresolved Issues After Elaborating
check_design -unresolved

# suspend

# Specify Constraints
create_clock -name clk -period $CLK_PERIOD [get_ports $CLK_PORT]
check_timing_intent

# Generic Synthesis
syn_generic
write_snapshot -outdir $RPT_DIR -tag generic
report_summary -directory $RPT_DIR
puts "Runtime and Memory after syn_generic"
time_info GENERIC

# Synthesis to Mapped Gates
syn_map
write_snapshot -outdir $RPT_DIR -tag map
report_summary -directory $RPT_DIR
puts "Runtime and Memory after syn_map"
time_info MAPPED

# Synthesis Optimizations
syn_opt
# report_timing > ${RPT_DIR}/final_timing.rpt
# report_area   > ${RPT_DIR}/final_area.rpt
# report_power -by_hierarchy > ${RPT_DIR}/final_static_power.rpt
write_snapshot -outdir $RPT_DIR -tag final
report_summary -directory $RPT_DIR
puts "Runtime and Memory after syn_opt"
time_info OPT


write_hdl > ${OUTPUT_DIR}/aes_top_gate.v
write_sdc > ${OUTPUT_DIR}/aes_top_gate.sdc
report_units > ${OUTPUT_DIR}/units.rpt

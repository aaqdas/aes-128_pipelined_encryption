##############################################################################
## 			Parameterized Synthesis
##############################################################################

##############################################################################
## Set Paths 
##############################################################################
set DESIGN aes_top_gate
set TOP_LEVEL Top_PipelinedCipher
set HOME_DIR "[exec pwd]/../../"
set RPT_DIR  "${HOME_DIR}/cadence/reports/"
set CONSTRAINTS_DIR "${HOME_DIR}/cadence/constraints/"
set RTL_DIR "${HOME_DIR}/cadence/output/"
set LIB_DIR "/home/min/a/aaqdas/Documents/aes_build/asap7nm/frontend/lib/"
set LEF_DIR "/home/min/a/aaqdas/Documents/aes_build/asap7nm/backend/lef/"
set VCD_PATH		"${HOME_DIR}/cadence/post_synthesis_simulation/my_shm.shm"

set_db lp_power_unit mW 
set_db lib_search_path $LIB_DIR
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

read_libs $LIB_LIST

read_hdl ${DESIGN}.v
set_db lp_insert_clock_gating true

elaborate ${TOP_LEVEL}

write_db -all -to_file ${DESIGN}.joules.flow.elab.db

read_sdc $CONSTRAINTS_DIR/${DESIGN}.sdc

syn_power -effort high 
read_stimulus -file $VCD_PATH -format shm
compute_power -mode time_based
report_power -by_hierarchy > $RPT_DIR/${DESIGN}_power_hierarchy.joules.rpt

write_db -all -to_file ${DESIGN}.joules.flow.proto.db
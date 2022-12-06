// To run JG with GUI, type: "jg jg_master.tcl"
// To run JG with no GUI, type: "jg -batch jg_master.tcl"

// AXI4 Monitor
+incdir+${ABVIP_INST_DIR}/axi4/rtl+${vip_dir}/../include
-y ${ABVIP_INST_DIR}/axi4/rtl
+libext+.sv
+libext+.svp

// AXI Master DUT
${vip_dir}/../src/CPU_wrapper.sv
//${vip_dir}/../src/CPU.sv

// Top level Verilog file
${vip_dir}/master_duv/top.v


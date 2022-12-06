// To run JG with GUI, type: "jg jg_bridge.tcl"
// To run JG with no GUI, type: "jg -batch jg_bridge.tcl"

// AXI4 Monitor
+incdir+${ABVIP_INST_DIR}/axi4/rtl+${vip_dir}/../include+${vip_dir}../src/AXI
-y ${ABVIP_INST_DIR}/axi4/rtl
+libext+.sv
+libext+.svp

// Top level Verilog file
${ABVIP_INST_DIR}/axi4/rtl/axi4_master.sv
${ABVIP_INST_DIR}/axi4/rtl/axi4_slave.sv
${vip_dir}/../src/AXI/AXI_bridge/AXI.sv
${vip_dir}/bridge_duv/top.v



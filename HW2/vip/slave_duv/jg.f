// To run JG with GUI, type: "jg jg_slave.tcl"
// To run JG with no GUI, type: "jg -batch jg_slave.tcl"

// AXI4 Monitor
+incdir+${ABVIP_INST_DIR}/axi4/rtl+${vip_dir}/../include+${vip_dir}/../sim
-y ${ABVIP_INST_DIR}/axi4/rtl
+libext+.sv
+libext+.svp

// AXI Slave DUT
${vip_dir}/../src/SRAM_wrapper.sv
${vip_dir}/../sim/SRAM/SRAM_rtl.sv

// Top level Verilog file
${vip_dir}/slave_duv/top.v


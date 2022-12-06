#Read All Files
analyze -format sverilog ../src/top.sv
read_file {../src ../include ../src/AXI ../src/CPU ../src/DRAM ../src/ROM ../src/SRAM} -autoread -top top 
elaborate top
link
uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

#Setting Clock Constraints
source -echo -verbose ../script/DC.sdc

#Synthesis all design
compile -map_effort high -area_effort high
# compile_ultra -gate_clock -no_autoungroup
# sizeof_collection [all_registers]
# optimize_registers
# compile_ultra -incremental -no_autoungroup
# sizeof_collection [all_registers]
# optimize_netlist -area

# Post-compile reports
set fileName top_syn
report_clock > ../syn/report_clock_$fileName.rpt
report_timing > ../syn/report_timing_$fileName.rpt
report_constraints > ../syn/report_constraints_$fileName.rpt
report_power > ../syn/report_power_$fileName.rpt
report_qor > ../syn/report_qor_$fileName.rpt

# Save design
write_file -format ddc -hierarchy -out ../syn/$fileName.ddc
write_file -format verilog -hierarchy -out ../syn/$fileName.v
write_sdf ../syn/$fileName.sdf
write_sdc ../syn/$fileName.sdc

# analyze -format sverilog ../src/top.sv
# read_file {../src ../include ../src/AXI ../src/CPU ../src/DRAM ../src/ROM ../src/SRAM} -autoread -top top 
# current_design top
# link
# uniquify
# set_fix_multiple_port_nets -all -buffer_constants [get_designs *]

# source ../script/DC.sdc

# compile
# remove_unconnected_ports -blast_buses [get_cells * -hier]
# write_file -format verilog -hier -output ../syn/top_syn.v
# write_sdf -version 2.1 -context verilog -load_delay net ../syn/top_syn.sdf
# report_timing > ../syn/timing.log
# report_area > ../syn/area.log
# exit



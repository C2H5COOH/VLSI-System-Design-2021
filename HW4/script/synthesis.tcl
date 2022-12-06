analyze -format sverilog ../src/top.sv
read_file {../src ../include ../src/AXI ../src/CPU ../src/DRAM ../src/ROM ../src/SRAM ../src/SRAM} -autoread -top top 
elaborate top
link
uniquify

#Setting Clock Constraints
source -echo -verbose ../script/DC.sdc

# compile

#Synthesis all design
compile -map_effort high -area_effort high

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



root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
inc_dir := ./include
sim_dir := ./sim
vip_dir := $(PWD)/vip
bld_dir := ./build
FSDB_DEF :=
ifeq ($(FSDB),1)
	FSDB_DEF := +FSDB
else ifeq ($(FSDB),2)
	FSDB_DEF := +FSDB_ALL
endif
CYCLE=`grep -v '^$$' $(root_dir)/sim/CYCLE`
MAX=`grep -v '^$$' $(root_dir)/sim/MAX`

export vip_dir

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

# AXI simulation
vip_b: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_bridge.tcl

vip_m: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_master.tcl

vip_s: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_slave.tcl

# RTL simulation
rtl_all: clean rtl0 rtl1 rtl2 rtl3

rtl0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0

rtl1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1

rtl2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog2$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog2

rtl3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog3/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+prog3$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog3

# Post-Synthesis simulation
syn_all: clean syn0 syn1 syn2 syn3

syn0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0

syn1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1

syn2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog2$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog2

syn3: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog3/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+prog3$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog3

# Utilities
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

dv: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -gui -no_home_init

synthesize: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -no_home_init -f ../script/synthesis.tcl

# Check file structure
BLUE=\033[1;34m
RED=\033[1;31m
NORMAL=\033[0m

check: clean
	@if [ -f StudentID ]; then \
		STUDENTID=$$(grep -v '^$$' StudentID); \
		if [ -z "$$STUDENTID" ]; then \
			echo -e "$(RED)Student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID_LEN=$$(expr length $$STUDENTID); \
			if [ $$ID_LEN -eq 9 ]; then \
				if [[ $$STUDENTID =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	else \
		echo -e "$(RED)StudentID file is not found$(NORMAL)"; \
		exit 1; \
	fi; \
	if [ -f StudentID2 ]; then \
		STUDENTID2=$$(grep -v '^$$' StudentID2); \
		if [ -z "$$STUDENTID2" ]; then \
			echo -e "$(RED)Second student ID number is not provided$(NORMAL)"; \
			exit 1; \
		else \
			ID2_LEN=$$(expr length $$STUDENTID2); \
			if [ $$ID2_LEN -eq 9 ]; then \
				if [[ $$STUDENTID2 =~ ^[A-Z][A-Z0-9][0-9]+$$ ]]; then \
					echo -e "$(BLUE)Second student ID number pass$(NORMAL)"; \
				else \
					echo -e "$(RED)Second student ID number should be one capital letter and 8 numbers (or 2 capital letters and 7 numbers)$(NORMAL)"; \
					exit 1; \
				fi \
			else \
				echo -e "$(RED)Second student ID number length isn't 9$(NORMAL)"; \
				exit 1; \
			fi \
		fi \
	fi; \
	if [ $$(ls -1 *.docx 2>/dev/null | wc -l) -eq 0 ]; then \
		echo -e "$(RED)Report file is not found$(NORMAL)"; \
		exit 1; \
	elif [ $$(ls -1 *.docx 2>/dev/null | wc -l) -gt 1 ]; then \
		echo -e "$(RED)More than one docx file is found, please delete redundant file(s)$(NORMAL)"; \
		exit 1; \
	elif [ ! -f $${STUDENTID}.docx ]; then \
		echo -e "$(RED)Report file name should be $$STUDENTID.docx$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Report file name pass$(NORMAL)"; \
	fi; \
	if [ $$(basename $(PWD)) != $$STUDENTID ]; then \
		echo -e "$(RED)Main folder name should be \"$$STUDENTID\"$(NORMAL)"; \
		exit 1; \
	else \
		echo -e "$(BLUE)Main folder name pass$(NORMAL)"; \
	fi

tar: check
	STUDENTID=$$(basename $(PWD)); \
	cd ..; \
	tar cvf $$STUDENTID.tar $$STUDENTID

.PHONY: clean

clean:
	rm -rf $(bld_dir); \
	rm -rf $(sim_dir)/prog*/result*.txt; \
	make -C $(sim_dir)/prog0/ clean; \
	make -C $(sim_dir)/prog1/ clean; \
	make -C $(sim_dir)/prog2/ clean; \
	make -C $(sim_dir)/prog3/ clean;

root_dir := $(PWD)
src_dir := ./src
syn_dir := ./syn
pr_dir := ./pr
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
pend=$(shell grep '[1-2]' $(root_dir)/sim/maxpend)
maxpend :=
ifeq ($(pend),1)
	maxpend := 1
else ifeq ($(pend),2) 
	maxpend := 2
else
	maxpend := 0
endif
$(info maxpend=$(maxpend))

export vip_dir
export maxpend

IFM_TEST_IDX ?= 0

$(bld_dir):
	mkdir -p $(bld_dir)

$(syn_dir):
	mkdir -p $(syn_dir)

$(pr_dir):
	mkdir -p $(pr_dir)

# AXI simulation
vip_b: clean | $(bld_dir)
	cd $(bld_dir); \
	jg ../script/jg_bridge.tcl

# RTL simulation
rtl_all: clean rtl0 rtl1 tpu_bias tpu_input0 tpu_input0_s1 tpu_input0_s2 tpu_input1 tpu_input1_s1 \
	tpu_input1_s2 tpu_moving_q tpu_output_q tpu_output_raw tpu_weight layer0 tpu_pw

syn_tpu_all: clean syn_tpu_input0 syn_tpu_input0_s1 syn_tpu_input0_s2 syn_tpu_input1 syn_tpu_input1_s1 \
	syn_tpu_input1_s2 syn_tpu_moving_q syn_tpu_output_q syn_tpu_output_raw syn_tpu_weight syn_layer0 syn_tpu_pw

pr_tpu_all: clean pr_tpu_input0 pr_tpu_input0_s1 pr_tpu_input0_s2 pr_tpu_input1 pr_tpu_input1_s1 \
	pr_tpu_input1_s2 pr_tpu_moving_q pr_tpu_output_q pr_tpu_output_raw pr_tpu_weight pr_layer0 pr_tpu_pw

tpu_bias: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_bias/ clean; \
	make -C $(sim_dir)/tpu_bias/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_bias \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_bias \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_bias

tpu_weight: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_weight/ clean; \
	make -C $(sim_dir)/tpu_weight/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_weight \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_weight \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_weight

tpu_input0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0/ clean; \
	make -C $(sim_dir)/tpu_input0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_input0 \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_input0 \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0

tpu_input1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1/ clean; \
	make -C $(sim_dir)/tpu_input1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_input1 \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_input1 \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1

tpu_input0_s1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0_s1/ clean; \
	make -C $(sim_dir)/tpu_input0_s1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_input0 \
	-define IFM_TEST_IDX=$(IFM_TEST_IDX) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_input0_s1 \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0_s1

tpu_input1_s1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1_s1/ clean; \
	make -C $(sim_dir)/tpu_input1_s1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_input1 \
	-define IFM_TEST_IDX=$(IFM_TEST_IDX) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_input1_s1 \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1_s1

tpu_input0_s2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0_s2/ clean; \
	make -C $(sim_dir)/tpu_input0_s2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_input0 \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_input0_s2 \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0_s2

tpu_input1_s2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1_s2/ clean; \
	make -C $(sim_dir)/tpu_input1_s2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_input1 \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_input1_s2 \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1_s2

tpu_output_raw: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_output_raw/ clean; \
	make -C $(sim_dir)/tpu_output_raw/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_output \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_output_raw \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_output_raw

tpu_moving_q: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_moving_q/ clean; \
	make -C $(sim_dir)/tpu_moving_q/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_quant \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_moving_q \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_moving_q

# tpu_conv_t0_c0: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/tpu_conv_t0_c0/ clean; \
# 	make -C $(sim_dir)/tpu_conv_t0_c0/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/tb_TPU1.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
# 	+define+RTL+tpu1$(FSDB_DEF) \
# 	-define CYCLE=$(CYCLE) \
# 	-define MAX=$(MAX) \
# 	+access+r \
# 	+data_path=$(root_dir)/$(sim_dir)/tpu_conv_t0_c0 \
# 	+prog_path=$(root_dir)/$(sim_dir)/tpu_conv_t0_c0

layer0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/driver/layer0/ clean; \
	make -C $(sim_dir)/driver/layer0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_layer0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+RTL+tpu1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/driver/layer0/ \
	+prog_path=$(root_dir)/$(sim_dir)/driver/layer0/

# plic_dma_boot: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/plic_dma_boot/ clean; \
# 	make -C $(sim_dir)/plic_dma_boot/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
# 	+define+tpu0$(FSDB_DEF) \
# 	+define+test_input0  \
# 	-define CYCLE=$(CYCLE) \
# 	-define MAX=$(MAX) \
# 	+access+r \
# 	+data_path=$(root_dir)/$(sim_dir)/plic_dma_boot \
# 	+prog_path=$(root_dir)/$(sim_dir)/plic_dma_boot
	
tpu_output_q: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_output_q/ clean; \
	make -C $(sim_dir)/tpu_output_q/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu0$(FSDB_DEF) \
	+define+RTL+test_output \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/$(sim_dir)/tpu_output_q \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_output_q

tpu_dw: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_dw/ clean; \
	make -C $(sim_dir)/tpu_dw/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU1.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu_dw$(FSDB_DEF) \
	+define+RTL+test_output \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/tools \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_dw

tpu_pw: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_pw/ clean; \
	make -C $(sim_dir)/tpu_pw/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU2.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+tpu_pw$(FSDB_DEF) \
	+define+RTL+test_output \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+data_path=$(root_dir)/tools \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_pw

rtl0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/ clean; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU \
	+define+RTL+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0

rtl1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/ clean; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
	+define+RTL+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1

# dma0: | $(bld_dir)
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/tb_DMA0.sv \
# 	+incdir+$(root_dir)/$(inc_dir)+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(src_dir)/DMA \
# 	+define+dma0$(FSDB_DEF) \
# 	+access+r

# dma1: | $(bld_dir)
# 	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
# 		echo "Cycle time shouldn't exceed 20"; \
# 		exit 1; \
# 	fi; \
# 	make -C $(sim_dir)/dma1/ clean; \
# 	make -C $(sim_dir)/dma1/; \
# 	cd $(bld_dir); \
# 	irun $(root_dir)/$(sim_dir)/tb_DMA1.sv \
# 	+incdir+$(root_dir)/$(src_dir)+$(root_dir)/$(src_dir)/AXI+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir)+$(root_dir)/$(src_dir)/CPU+$(root_dir)/$(src_dir)/cache+$(root_dir)/$(src_dir)/SRAM+$(root_dir)/$(src_dir)/DMA+$(root_dir)/$(src_dir)/TPU  \
# 	+define+dma1$(FSDB_DEF) \
# 	-define CYCLE=$(CYCLE) \
# 	-define MAX=$(MAX) \
# 	+access+r \
# 	+prog_path=$(root_dir)/$(sim_dir)/dma1

# Post-Synthesis simulation
syn_all: clean syn0 syn1

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

syn_tpu_input0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0/ clean; \
	make -C $(sim_dir)/tpu_input0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_input0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0

syn_tpu_input1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1/ clean; \
	make -C $(sim_dir)/tpu_input1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_input1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1

syn_tpu_weight: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_weight/ clean; \
	make -C $(sim_dir)/tpu_weight/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_weight$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_weight

syn_tpu_input0_s1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0_s1/ clean; \
	make -C $(sim_dir)/tpu_input0_s1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_input0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0_s1

syn_tpu_input1_s1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1_s1/ clean; \
	make -C $(sim_dir)/tpu_input1_s1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_input1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1_s1

syn_tpu_input0_s2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0_s2/ clean; \
	make -C $(sim_dir)/tpu_input0_s2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_input0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0_s2

syn_tpu_input1_s2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1_s2/ clean; \
	make -C $(sim_dir)/tpu_input1_s2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_input1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1_s2

syn_tpu_output_raw: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_output_raw/ clean; \
	make -C $(sim_dir)/tpu_output_raw/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_output$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_output_raw

syn_tpu_output_q: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_output_q/ clean; \
	make -C $(sim_dir)/tpu_output_q/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_output$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_output_q

syn_tpu_moving_q: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_moving_q/ clean; \
	make -C $(sim_dir)/tpu_moving_q/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_quant$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_moving_q

syn_tpu_moving_q: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_moving_q/ clean; \
	make -C $(sim_dir)/tpu_moving_q/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+test_quant$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_moving_q

syn_layer0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/driver/layer0/ clean; \
	make -C $(sim_dir)/driver/layer0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_layer0.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+tpu1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/driver/layer0/

syn_tpu_pw: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_pw/ clean; \
	make -C $(sim_dir)/tpu_pw/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU2.sv \
	-sdf_file $(root_dir)/$(syn_dir)/top_syn.sdf \
	+incdir+$(root_dir)/$(syn_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+SYN+tpu_pw$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_pw

# Post-Layout simulation
pr_all: clean pr0 pr1 pr2

pr0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog0

pr1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/prog1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/top_tb.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+prog1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/prog1

pr_tpu_input0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_input0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0

pr_tpu_input0_s1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0_s1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_input0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0_s1

pr_tpu_input0_s2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input0_s2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_input0$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input0_s2

pr_tpu_input1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_input1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1

pr_tpu_input1_s1: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1_s1/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_input1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1_s1

pr_tpu_input1_s2: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_input1_s2/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_input1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_input1_s2

pr_tpu_moving_q: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_moving_q/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_quant$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_moving_q

pr_tpu_output_q: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_output_q/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_output$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_output_q

pr_tpu_output_raw: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_output_raw/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_output$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_output_raw

pr_tpu_weight: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_weight/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_weight$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_weight

pr_layer0: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/driver/layer0/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_layer0.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+tpu1$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/driver/layer0/

pr_tpu_pw: | $(bld_dir)
	@if [ $$(echo $(CYCLE) '>' 20.0 | bc -l) -eq 1 ]; then \
		echo "Cycle time shouldn't exceed 20"; \
		exit 1; \
	fi; \
	make -C $(sim_dir)/tpu_pw/; \
	cd $(bld_dir); \
	irun $(root_dir)/$(sim_dir)/tb_TPU2.sv \
	-sdf_file $(root_dir)/$(pr_dir)/top_pr.sdf \
	+incdir+$(root_dir)/$(pr_dir)+$(root_dir)/$(inc_dir)+$(root_dir)/$(sim_dir) \
	+define+PR+test_pw$(FSDB_DEF) \
	-define CYCLE=$(CYCLE) \
	-define MAX=$(MAX) \
	+access+r \
	+prog_path=$(root_dir)/$(sim_dir)/tpu_pw

# Utilities
nWave: | $(bld_dir)
	cd $(bld_dir); \
	nWave top.fsdb &

superlint: | $(bld_dir)
	cd $(bld_dir); \
	jg -superlint ../script/superlint.tcl &

line: 
	wc -l src/* src/AXI/* src/AXI/AXI_master_DMA/* src/AXI/AXI_slave_DMA/* src/AXI/AXI_slave_SRAM/* src/cache/* src/CPU/* src/DMA/* src/SRAM/* src/TPU/* include/*

dv: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -gui -no_home_init

synthesize: | $(bld_dir) $(syn_dir)
	cp script/synopsys_dc.setup $(bld_dir)/.synopsys_dc.setup; \
	cd $(bld_dir); \
	dc_shell -gui -no_home_init -f ../script/synthesis.tcl

innovus: | $(bld_dir) $(pr_dir)
	cd $(bld_dir); \
	innovus

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
	make -C $(sim_dir)/data0/ clean; \
	make -C $(sim_dir)/prog0/ clean; \
	make -C $(sim_dir)/prog1/ clean; \
	make -C $(sim_dir)/dma1/ clean; \
	make -C $(sim_dir)/tpu_input0/ clean; \
	make -C $(sim_dir)/tpu_input0_s1/ clean; \
	make -C $(sim_dir)/tpu_input0_s2/ clean; \
	make -C $(sim_dir)/tpu_input1/ clean; \
	make -C $(sim_dir)/tpu_input1_s1/ clean; \
	make -C $(sim_dir)/tpu_input1_s2/ clean; \
	make -C $(sim_dir)/tpu_weight/ clean; \
	make -C $(sim_dir)/tpu_bias/ clean; \
	make -C $(sim_dir)/tpu_moving_q/ clean; \
	make -C $(sim_dir)/tpu_output_q/ clean; \
	make -C $(sim_dir)/tpu_output_raw/ clean; \
	make -C $(sim_dir)/tpu_conv_t0_c0/ clean; \
	make -C $(sim_dir)/driver/layer0/ clean; \
	make -C $(sim_dir)/tpu_dw/ clean; \
	make -C $(sim_dir)/tpu_pw/ clean; \
	rm -rf nWaveLog; \
	rm -rf novas.*; \
	rm -rf BSSLib.lib++; \
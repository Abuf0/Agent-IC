# Makefile for fp_mac verification
# 使用Cocotb + Icarus Verilog仿真

# 1. 仿真器选择
SIM ?= icarus
# 启用波形
WAVES ?= 1
WAVE_FORMAT ?= vcd

# 2. Verilog文件路径
RTL_PATH = ../rtl
RTL_SPLITTER_PATH = $(RTL_PATH)/rtl_splitter

# 3. Verilog源文件
VERILOG_SOURCES = \
	$(RTL_PATH)/fp_mac.sv \
	$(RTL_PATH)/mult_booth4.sv \
	$(RTL_PATH)/wallace_tree.sv \
	$(RTL_PATH)/csa_3t2.sv \
	$(RTL_PATH)/CLA.sv

# 如果使用拆分后的模块，可以注释上面的fp_mac.sv，使用下面的模块
# VERILOG_SOURCES = \
# 	$(RTL_SPLITTER_PATH)/fp_mac_stage1.sv \
# 	$(RTL_SPLITTER_PATH)/fp_mac_stage2.sv \
# 	$(RTL_SPLITTER_PATH)/fp_mac_stage3.sv \
# 	$(RTL_SPLITTER_PATH)/fp_mac_stage4.sv \
# 	$(RTL_SPLITTER_PATH)/fp_mac_top.sv \
# 	$(RTL_PATH)/mult_booth4.sv \
# 	$(RTL_PATH)/wallace_tree.sv \
# 	$(RTL_PATH)/csa_3t2.sv \
# 	$(RTL_PATH)/CLA.sv

# 4. 顶层模块名
TOPLEVEL = fp_mac

# 5. cocotb测试模块名（无.py后缀）
MODULE = fp_mac_tb

# 6. 仿真选项
ifeq ($(SIM),icarus)
	SIM_BUILD = sim_build
	IVERILOG_FLAGS = -g2012 -I$(RTL_PATH) -I$(RTL_SPLITTER_PATH)
	VVP_FLAGS = -v -n
	ifeq ($(WAVES),1)
		IVERILOG_FLAGS += -DCOCOTB_SIM=1
		VVP_FLAGS += -lxt2
	endif
endif

# 7. 环境变量
export COCOTB_RESOLVE_X = ZEROS
export COCOTB_TIMEOUT_CYCLES = 1000000
export COCOTB_REDUCED_LOG_FMT = 1

# 8. 波形文件设置
ifeq ($(WAVES),1)
	export COCOTB_ANSI = 0
	ifeq ($(WAVE_FORMAT),vcd)
		VVP_FLAGS += -vcd sim_build/$(TOPLEVEL).vcd
	else ifeq ($(WAVE_FORMAT),fst)
		VVP_FLAGS += -fst sim_build/$(TOPLEVEL).fst
	else
		VVP_FLAGS += -vcd sim_build/$(TOPLEVEL).vcd
	endif
endif

# 9. Python路径
export PYTHONPATH := $(PWD):$(PYTHONPATH)

# 10. Make工具路径（Windows MSYS2环境）
MAKE := make

# 11. 引入cocotb的通用仿真规则
include $(shell cocotb-config --makefiles)/Makefile.sim

# 12. 自定义目标
.PHONY: clean_all waves

clean_all:
	rm -rf sim_build
	rm -f *.vcd *.fst *.log
	rm -rf __pycache__
	rm -f results.xml

waves:
	@if [ "$(WAVES)" = "1" ]; then \
		echo "Waveform generated at sim_build/$(TOPLEVEL).$(if $(filter vcd,$(WAVE_FORMAT)),vcd,fst)"; \
	else \
		echo "WAVES is not enabled. Set WAVES=1 to generate waveforms."; \
	fi

# 13. 测试报告生成
report:
	@echo "=== Test Summary ==="
	@if [ -f results.xml ]; then \
		echo "Test results saved to results.xml"; \
		python -c "import xml.etree.ElementTree as ET; tree = ET.parse('results.xml'); root = tree.getroot(); tests = int(root.get('tests')); failures = int(root.get('failures')); errors = int(root.get('errors')); print(f'Total tests: {tests}, Failures: {failures}, Errors: {errors}, Pass rate: {(tests-failures-errors)/tests*100:.2f}%');"; \
	else \
		echo "No results.xml found. Run 'make' first."; \
	fi
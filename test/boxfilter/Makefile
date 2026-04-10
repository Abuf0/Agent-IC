# BoxFilter Test Makefile
# 仿真器选择（默认icarus）
SIM ?= icarus
WAVES = 1
# 波形文件生成
ifeq ($(WAVES),1)
	VVP_FLAGS += -v -n -vcd sim_build/boxfilter.vcd
endif

# RTL文件路径
RTL_PATH = ../../rtl/rtl_splitter

# Verilog源文件列表
VERILOG_SOURCES = \
	${RTL_PATH}/BoxFilter.sv \
	${RTL_PATH}/Pipeline_act.sv \
	${RTL_PATH}/RegQueue.sv \
	${RTL_PATH}/enumdefine.sv

# 顶层模块名
TOPLEVEL = BoxFilter

# cocotb测试用例文件名（无.py后缀）
MODULE = test_boxfilter

# 导出环境变量
export COCOTB_RESOLVE_X = ZEROS
# 所有Cocotb测试用例的默认超时时间（单位：秒）
export COCOTB_TIMEOUT_CYCLES = 1000000

# 设置make路径（根据系统调整）
MAKE := make

# 引入cocotb的通用仿真规则
include $(shell cocotb-config --makefiles)/Makefile.sim

# 自定义目标
.PHONY: waves clean_waves

waves:
	@if [ -f sim_build/boxfilter.vcd ]; then \
		echo "Opening waveform viewer..."; \
		gtkwave sim_build/boxfilter.vcd & \
	else \
		echo "No waveform file found. Run simulation with WAVES=1 first."; \
	fi

clean_waves:
	rm -f sim_build/*.vcd

# Run simulation with output redirected to log file
run_quiet:
	$(MAKE) SIM=$(SIM) 2>&1 | tee sim_build/simulation.log
# Makefile
# 1. 仿真器选择（Verilator） iverilog
SIM ?= icarus
WAVES = 0
# 2. Verilog文件路径
RTL_PATH = ../rtl

VERILOG_SOURCES = \
${RTL_PATH}/fp_mac.sv \


# 3. 顶层模块名
TOPLEVEL = fp_mac

# 4. cocotb测试用例文件名（无.py后缀）
MODULE = test_fma

VVP_FLAGS += -v -n -vcd sim_build/test_fp_mac.vcd

#todo
export COCOTB_RESOLVE_X = ZEROS
# 所有Cocotb测试用例的默认超时时间（单位：秒）
export COCOTB_TIMEOUT_CYCLES = 10

# 5. 设置make路径
MAKE := D:/Software/msys64/usr/bin/make

# 6. 引入cocotb的通用仿真规则
include $(shell cocotb-config --makefiles)/Makefile.sim
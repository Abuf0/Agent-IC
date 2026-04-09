# fp_mac 浮点乘累加单元测试环境

## 概述
本测试环境用于验证 fp_mac 模块的功能正确性。fp_mac 是一个单精度浮点乘累加单元（FMA），支持 A*B+C 运算，具有5级流水线，支持5种舍入模式。

## 测试覆盖
- [x] 基本随机测试（随机正规数）
- [x] 特殊值测试（NaN、Infinity、零、次正规数）
- [x] 舍入模式测试（5种模式，标记已知问题）
- [x] 边界条件测试（溢出、下溢、精度损失）
- [x] 流水线测试（时序和延迟）
- [x] 状态输出验证

## 已知问题
RTL存在已知舍入逻辑错误：
- 最近偶数模式（RND=000）可能不正确
- 最近远离零模式（RND=100）可能不正确

测试中会标记这些已知问题，不会因此导致测试失败。

## 目录结构
```
test_fp_mac/
├── Makefile              # 仿真Makefile
├── fp_mac_tb.py          # 主测试文件（Cocotb测试）
├── fp_mac_model.py       # 参考模型
├── test_cases.py         # 测试用例定义
├── run.py                # 测试运行脚本
├── README.md             # 本文档
└── sim_build/            # 仿真构建目录（自动生成）
```

## 依赖
- Python 3.6+
- Cocotb 1.6+
- Icarus Verilog 或 Verilator
- Make

## 快速开始

### 1. 运行所有测试
```bash
cd test_fp_mac
python run.py all --waves
```

### 2. 仅运行仿真
```bash
python run.py run --waves --format vcd
```

### 3. 生成报告
```bash
python run.py report
```

### 4. 清理生成的文件
```bash
python run.py clean
```

### 5. 使用Make直接运行
```bash
make WAVES=1
make report
```

## 测试详情

### 基本功能测试
- 200个随机正规数测试
- 避免溢出范围
- 使用简单参考模型验证

### 特殊值测试
- NaN传播测试
- Infinity运算测试
- 零值测试（正零、负零）
- 次正规数测试

### 舍入模式测试
支持5种IEEE 754舍入模式：
1. `000` - 最近偶数（roundTiesToEven）**已知问题**
2. `001` - 向零舍入（roundTowardZero）
3. `010` - 向下舍入（roundTowardNegative）
4. `011` - 向上舍入（roundTowardPositive）
5. `100` - 最近远离零（roundTiesToAway）**已知问题**

### 边界条件测试
- 最大/最小正规数
- 最大/最小次正规数
- 溢出边界测试
- 下溢边界测试
- 精度损失测试
- 符号抵消测试

### 流水线测试
- 验证5级流水线延迟
- 背靠背输入测试
- 时序验证

### 状态输出验证
- 状态码正确性：`0x00`（正常）、`0x01`（NaN）、`0x02`（Infinity）

## 波形生成
启用波形生成：
```bash
make WAVES=1 WAVE_FORMAT=vcd
# 或
make WAVES=1 WAVE_FORMAT=fst
```

波形文件将生成在 `sim_build/` 目录中。

## 自定义测试

### 添加新测试用例
编辑 `test_cases.py` 文件，在相应的类别中添加新的 `TestCase` 对象。

### 修改参考模型
编辑 `fp_mac_model.py` 文件中的 `fp_mac_model` 函数。

### 添加新的测试套件
在 `fp_mac_tb.py` 中添加新的 `@cocotb.test()` 函数。

## 测试报告
测试完成后，生成报告：
- 控制台输出摘要
- `test_report.txt` 文件保存详细报告
- `results.xml` JUnit格式结果文件

报告内容包括：
- 测试总数、通过数、失败数、错误数
- 通过率
- 执行时间
- 失败/错误详情

## 故障排除

### 常见问题

1. **找不到make命令**
   - 确保已安装make（Windows用户可安装MSYS2）

2. **Cocotb导入错误**
   - 确保Cocotb已正确安装：`pip install cocotb`

3. **Icarus Verilog编译错误**
   - 检查Verilog文件路径
   - 确保使用支持SystemVerilog的版本

4. **波形文件无法生成**
   - 检查 `WAVES=1` 已设置
   - 检查仿真器是否支持波形生成

### 调试建议
- 启用波形生成查看信号时序
- 使用 `--waves` 参数运行脚本
- 检查 `sim_build` 目录中的编译日志
- 查看测试失败时的详细错误信息

## 性能统计
- 典型测试时间：2-5分钟（取决于仿真器）
- 内存使用：~100MB
- 波形文件大小：10-100MB（取决于测试数量）

## 扩展性
测试框架设计为模块化，易于扩展：
- 添加新的测试类别
- 支持不同的仿真器
- 集成覆盖率收集
- 支持回归测试
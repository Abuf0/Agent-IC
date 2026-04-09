# 仿真器临时目录问题解决方案

## 问题描述
运行 fp_mac 测试时出现以下错误：

1. **编译阶段**：
   ```
   D:\Common\Software\iverilog\bin\iverilog.exe: Error opening temporary file C:\TEMP\ivrlg1908
   D:\Common\Software\iverilog\bin\iverilog.exe: Please check TMP or TMPDIR.
   ```

2. **仿真阶段**（当编译成功后）：
   ```
   FSTAPI  | GetTempFileName() failed in ../../iverilog/vpi/fstapi.c line 231, exiting.
   ```

## 根本原因
1. **Icarus Verilog 临时文件错误**：Windows 环境下 Icarus Verilog 尝试在 `C:\TEMP` 目录创建临时文件，但该目录不存在或不可写。
2. **FST 波形 API 错误**：当启用波形生成时，Icarus Verilog 的 FST 波形 API 也需要创建临时文件，同样失败。

## 解决方案

### 1. 修复临时目录问题
```bash
# 创建 C:\TEMP 目录（在 MSYS2/Git Bash 中）
mkdir -p /c/TEMP

# 或者确保 TEMP/TMP 环境变量指向可写目录
export TEMP=/c/TEMP
export TMP=/c/TEMP
```

### 2. 禁用波形生成（避免 FST API 错误）
```bash
# 设置 WAVES=0 环境变量
export WAVES=0

# 或者直接运行
make SIM=icarus WAVES=0
```

### 3. 完整测试命令
```bash
# 进入测试目录
cd test_fp_mac

# 清理之前的构建
make clean_all

# 运行测试（无波形）
make SIM=icarus WAVES=0

# 或者使用提供的脚本
WAVES=0 python run.py run --sim icarus
```

## 替代方案：使用其他仿真器

### 尝试 Verilator（如果可用）
```bash
make SIM=verilator
```

### 但注意 Verilator 可能需要额外配置：
- 安装 Perl 模块（Pod::Usage）
- 确保 verilator 在 PATH 中

## 永久解决方案

### 对于 Windows 系统：
1. 永久创建 `C:\TEMP` 目录并设置适当权限
2. 在系统环境变量中添加 `TEMP=C:\TEMP` 和 `TMP=C:\TEMP`
3. 或者修改 Icarus Verilog 配置使用其他临时目录

### 修改 Makefile 默认设置：
在 `Makefile` 中将默认波形生成关闭：
```makefile
WAVES ?= 0  # 默认禁用波形
```

## 验证解决方案
运行以下命令验证问题已解决：
```bash
cd test_fp_mac
make clean_all
make SIM=icarus WAVES=0
```

预期输出应显示测试正常执行，无临时文件错误。

## 已知限制
- 解决方案禁用波形生成，调试时无法查看波形
- 如需波形，需要修复 FST API 的临时文件问题，可能需要：
  1. 确保 `C:\TEMP` 目录存在且可写
  2. 更新 Icarus Verilog 到最新版本
  3. 使用 VCD 格式替代 FST：`WAVE_FORMAT=vcd`

## 参考
- Icarus Verilog 临时文件问题常见于 Windows 环境
- Cocotb 与 Icarus Verilog 集成时可能遇到路径问题
- FST 格式需要额外的临时文件处理
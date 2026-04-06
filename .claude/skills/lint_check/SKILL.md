# Lint Check Skill

## 触发条件
当用户请求做RTL的lint检查时自动触发。

## 执行步骤
1. 使用nLint，工具安装目录为“D:/Software/nLint2.2v24/bin/nLint.exe”；
2. 根据用户输入的RTL文件，运行以下命令完成Lint检查：
   ```
   nLint.exe -verilog -2001 -top [模块名] -out [输出文件] [RTL文件]
   ```
3. 输出Lint检查报告，包括行数、代码、问题等信息；
4. 对于Verilog/SystemVerilog代码，必须使用-2001选项以支持Verilog 2001语法；


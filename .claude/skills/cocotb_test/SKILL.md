# Cocotb test Skill

## 触发条件
当用户请求做RTL的基于Cocotb的验证时自动触发。

## 执行步骤
1. 确认已经安装好Cocotb，可以运行以下命令：
   ```
   import cocotb
   print(cocotb.__version__)
   ```
2. 如果仿真工具选择Icarus verilog，icarus verilog的安装目录为："D:/Software/iverilog/bin"：
3. 根据验证flow，搭建cocotb仿真环境，完成环境自测试后，完成各项验证
4. Makefile文件可以参考cocotb_test/Makefile，make的安装目录为："D:/Software/msys64/usr/bin"
5. 在Makefile路径下执行make


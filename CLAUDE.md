# My Project
可以根据RTL和SPEC，完善SPEC，review RTL，搭建testbench完成验证，使用DC完成综合。

## Tech Stack
- RTL Language: Verilog / Systemverilog
- Review: Lint / CDC
- Testbench Platform: SV / UVM / Cocotb
- Synthesis: DC

## Common Commands
\`code reiview\`    # 代码审核+完善spec
\`test build/\`  # 验证
\`dc run\`  # 跑综合

## Code Conventions
- 只允许读取和修改该项目内部的文件，如果需要修改其他目录下的文件，需要获得许可
- PR 合并前必须通过 CI

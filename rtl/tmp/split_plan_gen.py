#!/usr/bin/env python3
import json
import os
from pathlib import Path

# 读取分析结果
analysis_file = Path("/d/Learn/Agent/Agent-IC/rtl/tmp/rtl_analysis.json")
with open(analysis_file, 'r', encoding='utf-8') as f:
    analysis = json.load(f)

modules = analysis.get("modules", [])
if not modules:
    print("No modules found")
    exit(1)

# 拆分参数
max_lines_per_file = 1000
preserve_fsm = True
max_cross_calls = 10

splits = []
warnings = []

for module in modules:
    module_name = module["name"]
    estimated_lines = module["complexity"]["estimated_lines"]

    # fp_mac模块有896行，接近限制，但可以按流水线阶段拆分
    if module_name == "fp_mac":
        # 检查是否有流水线寄存器(r1, r2, r3, r4)
        # 按功能区域拆分：
        # 1. 输入解码和特殊处理（行1-200）
        # 2. 乘法器和对齐（行200-400）
        # 3. 加法和LZC（行400-600）
        # 4. 规格化和舍入（行600-800）
        # 5. 输出和流水线寄存器（行800-896）
        splits.append({
            "file": "fp_mac_decode.sv",
            "include_modules": ["fp_mac_decode"],
            "lines": 200,
            "start_line": 1,
            "end_line": 200,
            "action": "extract",
            "description": "输入解码、特殊值判断、隐藏位添加"
        })
        splits.append({
            "file": "fp_mac_align.sv",
            "include_modules": ["fp_mac_align"],
            "lines": 200,
            "start_line": 200,
            "end_line": 400,
            "action": "extract",
            "description": "指数差计算、尾数对齐、乘法器实例"
        })
        splits.append({
            "file": "fp_mac_add.sv",
            "include_modules": ["fp_mac_add"],
            "lines": 200,
            "start_line": 400,
            "end_line": 600,
            "action": "extract",
            "description": "加法、符号处理、前导零计数(LZC)"
        })
        splits.append({
            "file": "fp_mac_norm.sv",
            "include_modules": ["fp_mac_norm"],
            "lines": 200,
            "start_line": 600,
            "end_line": 800,
            "action": "extract",
            "description": "规格化、舍入、溢出处理"
        })
        splits.append({
            "file": "fp_mac_output.sv",
            "include_modules": ["fp_mac_output"],
            "lines": 100,
            "start_line": 800,
            "end_line": 896,
            "action": "extract",
            "description": "输出选择、流水线寄存器、状态输出"
        })
        splits.append({
            "file": "fp_mac_top.sv",
            "include_modules": ["fp_mac"],
            "lines": 50,
            "action": "keep",
            "description": "顶层模块，实例化所有子模块"
        })
        warnings.append("拆分为5个功能子模块，需要仔细处理模块间接口信号")
    else:
        # 其他模块，保持原样
        splits.append({
            "file": f"{module_name}.sv",
            "include_modules": [module_name],
            "lines": estimated_lines,
            "action": "keep"
        })

# 生成方案
plan = {
    "splits": splits,
    "warnings": warnings,
    "parameters": {
        "max_lines_per_file": max_lines_per_file,
        "preserve_fsm": preserve_fsm,
        "max_cross_calls": max_cross_calls
    },
    "original_file": str(analysis["file"])
}

# 保存方案
output_file = analysis_file.parent / "split_plan.json"
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(plan, f, indent=2)

print(f"Split plan saved to {output_file}")
print("\n=== Split Plan ===")
for i, split in enumerate(splits):
    print(f"{i+1}. {split['file']}: {split.get('description', '')}")
    print(f"   Lines: {split.get('lines', '?')}, Action: {split['action']}")

if warnings:
    print("\n=== Warnings ===")
    for warning in warnings:
        print(f"- {warning}")
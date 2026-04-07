#!/usr/bin/env python3
import json
import os
from pathlib import Path

def make_split_decision(analysis_file, max_lines_per_file=1000, preserve_fsm=True, max_cross_calls=10):
    """基于分析结果生成拆分方案"""
    with open(analysis_file, 'r', encoding='utf-8') as f:
        analysis = json.load(f)

    modules = analysis.get("modules", [])
    if not modules:
        return {"error": "No modules found in analysis"}

    # 简单策略：如果模块行数超过阈值，按功能拆分
    splits = []
    warnings = []

    for module in modules:
        module_name = module["name"]
        estimated_lines = module["complexity"]["estimated_lines"]
        dependencies = module["dependencies"]

        # 检查是否超过行数限制
        if estimated_lines <= max_lines_per_file:
            # 不拆分
            splits.append({
                "file": f"{module_name}.sv",
                "include_modules": [module_name],
                "lines": estimated_lines,
                "action": "keep"
            })
        else:
            # 需要拆分
            # 根据fp_mac模块的特点，按功能拆分
            if module_name == "fp_mac":
                # 方案1：拆分为输入处理、乘法、加法、规格化输出
                splits.append({
                    "file": "fp_mac_input.sv",
                    "include_modules": ["fp_mac_input"],
                    "lines": 200,
                    "action": "extract",
                    "description": "输入解码、特殊值处理、指数计算"
                })
                splits.append({
                    "file": "fp_mac_multiply.sv",
                    "include_modules": ["fp_mac_multiply"],
                    "lines": 150,
                    "action": "extract",
                    "description": "乘法器实例、尾数对齐"
                })
                splits.append({
                    "file": "fp_mac_add.sv",
                    "include_modules": ["fp_mac_add"],
                    "lines": 250,
                    "action": "extract",
                    "description": "加法、LZC前导零计数"
                })
                splits.append({
                    "file": "fp_mac_norm.sv",
                    "include_modules": ["fp_mac_norm"],
                    "lines": 200,
                    "action": "extract",
                    "description": "规格化、舍入、输出选择"
                })
                splits.append({
                    "file": "fp_mac_top.sv",
                    "include_modules": ["fp_mac"],
                    "lines": 100,
                    "action": "keep",
                    "description": "顶层模块，实例化子模块"
                })
                warnings.append("拆分大型浮点乘加模块，可能需要调整接口信号")
            else:
                # 其他模块，尝试按实例化拆分
                if dependencies:
                    # 拆分为子模块
                    for dep in dependencies:
                        splits.append({
                            "file": f"{dep}.sv",
                            "include_modules": [dep],
                            "lines": "unknown",
                            "action": "extract"
                        })
                    splits.append({
                        "file": f"{module_name}_top.sv",
                        "include_modules": [module_name],
                        "lines": 50,
                        "action": "keep"
                    })
                else:
                    # 无法拆分，警告
                    warnings.append(f"模块 {module_name} 超过行数限制但无法自动拆分")

    # 过滤重复
    unique_splits = []
    seen_files = set()
    for split in splits:
        if split["file"] not in seen_files:
            unique_splits.append(split)
            seen_files.add(split["file"])

    return {
        "splits": unique_splits,
        "warnings": warnings,
        "parameters": {
            "max_lines_per_file": max_lines_per_file,
            "preserve_fsm": preserve_fsm,
            "max_cross_calls": max_cross_calls
        }
    }

def main():
    analysis_file = Path("/d/Learn/Agent/Agent-IC/rtl/tmp/rtl_analysis.json")
    if not analysis_file.exists():
        print("Analysis file not found")
        return

    decision = make_split_decision(analysis_file)

    output_file = analysis_file.parent / "split_plan.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(decision, f, indent=2)

    print(f"Split plan saved to {output_file}")
    print("\nSplit Plan Summary:")
    for i, split in enumerate(decision.get("splits", [])):
        print(f"  {i+1}. {split['file']}: {split.get('description', '')} ({split.get('lines', '?')} lines)")

    if decision.get("warnings"):
        print("\nWarnings:")
        for warning in decision["warnings"]:
            print(f"  - {warning}")

if __name__ == "__main__":
    main()
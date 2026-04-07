#!/usr/bin/env python3
import re
import json
import sys
from pathlib import Path

def analyze_verilog_file(file_path):
    """分析Verilog/SystemVerilog文件，提取模块信息"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 移除注释以简化分析
    # 移除单行注释
    content_no_comments = re.sub(r'//.*', '', content)
    # 移除多行注释（简单处理）
    content_no_comments = re.sub(r'/\*.*?\*/', '', content_no_comments, flags=re.DOTALL)

    # 查找所有模块
    module_pattern = r'module\s+(\w+)\s*\((.*?)\)\s*;(.*?)endmodule'
    module_matches = list(re.finditer(module_pattern, content_no_comments, re.DOTALL | re.IGNORECASE))

    modules = []

    for match in module_matches:
        module_name = match.group(1)
        params_section = match.group(2)  # 端口列表
        module_body = match.group(3)

        # 提取端口信息
        ports = []
        # 简单匹配 input/output/inout
        port_pattern = r'(input|output|inout|reg|wire)?\s*(?:\[\d+:\d+\])?\s*(\w+)'
        # 更精细的端口解析（简化版）
        lines = params_section.strip().split('\n')
        for line in lines:
            line = line.strip()
            if not line:
                continue
            # 匹配类似 "input      [31:0]   io_a," 的格式
            port_match = re.match(r'(input|output|inout|reg|wire)\s+(?:\[(\d+):(\d+)\])?\s*(\w+)', line)
            if port_match:
                direction = port_match.group(1)
                msb = port_match.group(2)
                lsb = port_match.group(3)
                name = port_match.group(4)
                width = 1
                if msb and lsb:
                    width = abs(int(msb) - int(lsb)) + 1
                ports.append({
                    "name": name,
                    "direction": direction,
                    "width": width,
                    "line": "unknown"  # 暂不记录行号
                })

        # 提取参数
        parameters = []
        param_pattern = r'parameter\s+(\w+)\s*=\s*([^,;]+)'
        param_matches = re.findall(param_pattern, module_body, re.IGNORECASE)
        for param_name, param_value in param_matches:
            parameters.append({"name": param_name, "value": param_value.strip()})

        # 提取实例化
        instances = []
        # 匹配实例化：module_name instance_name ( .port(signal), ... );
        inst_pattern = r'(\w+)\s+(\w+)\s*\((?:\s*\.\w+\([^)]+\)\s*,?\s*)*\);'
        inst_matches = re.finditer(inst_pattern, module_body, re.DOTALL)
        for inst_match in inst_matches:
            module_inst = inst_match.group(1)
            instance_name = inst_match.group(2)
            instances.append({
                "module": module_inst,
                "instance": instance_name
            })

        # 计算复杂度：always块数
        always_count = len(re.findall(r'\balways\b', module_body, re.IGNORECASE))

        # 估算FSM数量（简单通过状态寄存器判断）
        fsm_count = 0
        # 查找状态寄存器定义
        state_reg_pattern = r'reg\s+(?:\[\d+:\d+\])?\s*(\w+)\s*(?:=|<=)\s*'
        # 简单假设每个状态寄存器对应一个FSM
        state_regs = re.findall(state_reg_pattern, module_body)
        fsm_count = len(state_regs)  # 粗略估计

        # 估算行数
        line_count = len(module_body.split('\n'))

        # 查找依赖模块（从实例化中提取）
        dependencies = list(set([inst["module"] for inst in instances]))

        modules.append({
            "name": module_name,
            "line_range": "unknown",  # 需要更精确的解析
            "ports": ports,
            "parameters": parameters,
            "instances": instances,
            "complexity": {
                "always_blocks": always_count,
                "fsm_count": fsm_count,
                "estimated_lines": line_count
            },
            "dependencies": dependencies
        })

    # 如果正则匹配失败，使用回退方法：提取整个文件作为一个模块
    if not modules:
        # 估算总行数
        total_lines = len(content.split('\n'))

        # 查找实例化（简单grep）
        inst_matches = re.findall(r'(\w+)\s+(\w+)\s*\(', content)
        instances = []
        dependencies = []
        for module_inst, instance_name in inst_matches:
            # 排除常见关键字
            if module_inst.lower() in ['if', 'always', 'assign', 'reg', 'wire', 'input', 'output', 'inout']:
                continue
            instances.append({
                "module": module_inst,
                "instance": instance_name
            })
            dependencies.append(module_inst)

        # 去重
        dependencies = list(set(dependencies))

        # 端口提取（简单扫描模块声明行）
        module_decl_match = re.search(r'module\s+(\w+)\s*\((.*?)\)\s*;', content, re.DOTALL)
        ports = []
        if module_decl_match:
            module_name = module_decl_match.group(1)
            port_section = module_decl_match.group(2)
            # 简单提取端口名
            port_names = re.findall(r'(\w+)\s*,?\s*$', port_section, re.MULTILINE)
            for port in port_names:
                if port.lower() in ['input', 'output', 'inout', 'reg', 'wire']:
                    continue
                ports.append({
                    "name": port,
                    "direction": "unknown",
                    "width": 1,
                    "line": "unknown"
                })

        modules.append({
            "name": "fp_mac",
            "line_range": f"1-{total_lines}",
            "ports": ports,
            "parameters": [],
            "instances": instances,
            "complexity": {
                "always_blocks": len(re.findall(r'\balways\b', content, re.IGNORECASE)),
                "fsm_count": 0,
                "estimated_lines": total_lines
            },
            "dependencies": dependencies,
            "parse_method": "regex_approx"
        })

    return {
        "file": str(file_path),
        "modules": modules,
        "parse_method": "regex_approx"
    }

def main():
    if len(sys.argv) < 2:
        print("Usage: python analyze_fp_mac.py <verilog_file>")
        sys.exit(1)

    file_path = sys.argv[1]
    result = analyze_verilog_file(file_path)

    # 输出到JSON文件
    output_path = Path(file_path).parent / "tmp" / "rtl_analysis.json"
    output_path.parent.mkdir(exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(result, f, indent=2)

    print(f"Analysis saved to {output_path}")

if __name__ == "__main__":
    main()
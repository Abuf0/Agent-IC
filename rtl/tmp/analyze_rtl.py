#!/usr/bin/env python3
"""
分析RTL文件，提取模块结构信息。
使用正则表达式作为回退方案。
"""

import os
import re
import json
import sys

def parse_verilog_file(file_path):
    """解析Verilog文件，提取模块信息"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 移除注释以简化解析
    # 移除单行注释
    content_no_comments = re.sub(r'//.*', '', content)
    # 移除多行注释
    content_no_comments = re.sub(r'/\*.*?\*/', '', content_no_comments, flags=re.DOTALL)

    # 查找所有模块定义
    module_pattern = r'\bmodule\s+(\w+)\s*(?:#?\s*\(.*?\))?\s*(?:\(|;)'
    # 简化：查找module到endmodule
    modules = []
    module_start = 0
    while True:
        module_match = re.search(r'\bmodule\s+(\w+)', content[module_start:], re.MULTILINE)
        if not module_match:
            break
        module_name = module_match.group(1)
        mod_start_pos = module_start + module_match.start()
        # 查找对应的endmodule
        endmodule_match = re.search(r'\bendmodule\b', content[mod_start_pos:], re.MULTILINE)
        if not endmodule_match:
            break
        end_pos = mod_start_pos + endmodule_match.end()
        module_text = content[mod_start_pos:end_pos]
        modules.append({
            'name': module_name,
            'text': module_text,
            'start_line': content[:mod_start_pos].count('\n') + 1,
            'end_line': content[:end_pos].count('\n') + 1
        })
        module_start = end_pos

    result = []
    for mod in modules:
        mod_info = extract_module_info(mod['name'], mod['text'])
        mod_info['file'] = os.path.basename(file_path)
        mod_info['start_line'] = mod['start_line']
        mod_info['end_line'] = mod['end_line']
        mod_info['line_count'] = mod['end_line'] - mod['start_line'] + 1
        result.append(mod_info)

    return result

def extract_module_info(module_name, module_text):
    """从模块文本中提取信息"""
    # 查找端口声明（简化版）
    # 查找input/output/inout
    ports = []
    # 简单正则匹配
    port_pattern = r'\b(input|output|inout)\s+(?:reg\s+|wire\s+|)?(?:\[.*?\]\s+)?(\w+)'
    for match in re.finditer(port_pattern, module_text):
        port_type = match.group(1)
        port_name = match.group(2)
        ports.append({
            'name': port_name,
            'type': port_type,
            'direction': 'input' if port_type == 'input' else 'output' if port_type == 'output' else 'inout'
        })

    # 查找子模块实例化
    instances = []
    # 模式：模块名 实例名 ( .端口(连接) );
    instance_pattern = r'\b(\w+)\s+(\w+)\s*\(.*?\);'
    for match in re.finditer(instance_pattern, module_text, re.DOTALL):
        module_inst = match.group(1)
        inst_name = match.group(2)
        instances.append({
            'module_name': module_inst,
            'instance_name': inst_name
        })

    # 计算大致逻辑行数（非空行）
    lines = [line.strip() for line in module_text.split('\n') if line.strip()]
    logic_lines = len(lines)

    return {
        'module_name': module_name,
        'ports': ports,
        'instances': instances,
        'logic_line_count': logic_lines
    }

def main():
    if len(sys.argv) < 2:
        print("Usage: python analyze_rtl.py <file1> [file2 ...]")
        sys.exit(1)

    all_modules = []
    for file_path in sys.argv[1:]:
        if not os.path.exists(file_path):
            print(f"Warning: File not found {file_path}")
            continue
        print(f"Processing {file_path}...")
        modules = parse_verilog_file(file_path)
        all_modules.extend(modules)

    # 输出JSON
    output = {
        'modules': all_modules,
        'analysis_date': '2026-04-07',
        'constraints': {
            'max_lines_per_file': 1000
        }
    }

    output_file = os.path.join(os.path.dirname(sys.argv[0]), 'rtl_analysis.json')
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)

    print(f"Analysis written to {output_file}")
    return output

if __name__ == '__main__':
    main()
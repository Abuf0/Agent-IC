#!/usr/bin/env python3
"""
测试环境自检脚本
检查必要的依赖和配置
"""

import sys
import os
import subprocess
import importlib

def check_python_version():
    """检查Python版本"""
    print("检查Python版本...")
    version = sys.version_info
    print(f"  Python {version.major}.{version.minor}.{version.micro}")

    if version.major >= 3 and version.minor >= 6:
        print("  [OK] Python版本符合要求")
        return True
    else:
        print("  [FAIL] 需要Python 3.6或更高版本")
        return False

def check_imports():
    """检查必要的Python包"""
    print("\n检查Python包依赖...")

    required = [
        ("cocotb", "Cocotb仿真框架"),
        ("numpy", "数值计算（可选）"),
    ]

    all_ok = True
    for package, description in required:
        try:
            importlib.import_module(package)
            print(f"  [OK] {package}: {description}")
        except ImportError:
            if package == "numpy":
                print(f"  [WARN] {package}: {description} (可选)")
            else:
                print(f"  [FAIL] {package}: {description} - 未安装")
                all_ok = False

    return all_ok

def check_simulator():
    """检查仿真器"""
    print("\n检查仿真器...")

    simulators = [
        ("iverilog", "Icarus Verilog"),
        ("verilator", "Verilator"),
    ]

    found = []
    for cmd, name in simulators:
        try:
            result = subprocess.run([cmd, "--version"],
                                   capture_output=True,
                                   text=True,
                                   timeout=2)
            if result.returncode == 0:
                print(f"  [OK] {name} ({cmd}): 已安装")
                # 提取版本信息
                lines = result.stdout.split('\n')
                if lines:
                    print(f"    版本: {lines[0]}")
                found.append(cmd)
            else:
                print(f"  [FAIL] {name} ({cmd}): 未找到")
        except FileNotFoundError:
            print(f"  [FAIL] {name} ({cmd}): 未找到")
        except subprocess.TimeoutExpired:
            print(f"  [WARN] {name} ({cmd}): 检查超时")

    if found:
        return True
    else:
        print("  [FAIL] 未找到任何仿真器，需要安装Icarus Verilog或Verilator")
        return False

def check_rtl_files():
    """检查RTL文件"""
    print("\n检查RTL文件...")

    rtl_path = "../rtl"
    required_files = [
        "fp_mac.sv",
        "mult_booth4.sv",
        "wallace_tree.sv",
        "csa_3t2.sv",
        "CLA.sv",
    ]

    all_ok = True
    for file in required_files:
        path = os.path.join(rtl_path, file)
        if os.path.exists(path):
            print(f"  [OK] {file}")
        else:
            print(f"  [FAIL] {file} - 未找到")
            all_ok = False

    # 检查拆分模块
    splitter_path = os.path.join(rtl_path, "rtl_splitter")
    if os.path.exists(splitter_path):
        print(f"  [OK] rtl_splitter/ 目录存在")
        split_files = ["fp_mac_stage1.sv", "fp_mac_stage2.sv",
                      "fp_mac_stage3.sv", "fp_mac_stage4.sv", "fp_mac_top.sv"]
        for file in split_files:
            path = os.path.join(splitter_path, file)
            if os.path.exists(path):
                print(f"    [OK] {file}")
            else:
                print(f"    [WARN] {file} - 未找到（可选）")
    else:
        print(f"  [WARN] rtl_splitter/ 目录不存在（使用完整fp_mac.sv）")

    return all_ok

def check_test_files():
    """检查测试文件"""
    print("\n检查测试文件...")

    current_dir = os.path.dirname(os.path.abspath(__file__))
    required_files = [
        "Makefile",
        "fp_mac_tb.py",
        "fp_mac_model.py",
        "test_cases.py",
        "run.py",
    ]

    all_ok = True
    for file in required_files:
        path = os.path.join(current_dir, file)
        if os.path.exists(path):
            print(f"  [OK] {file}")
        else:
            print(f"  [FAIL] {file} - 未找到")
            all_ok = False

    return all_ok

def check_cocotb_config():
    """检查Cocotb配置"""
    print("\n检查Cocotb配置...")

    try:
        result = subprocess.run(["cocotb-config", "--makefiles"],
                               capture_output=True,
                               text=True,
                               timeout=2)
        if result.returncode == 0:
            print(f"  [OK] Cocotb配置正常")
            print(f"    Makefiles路径: {result.stdout.strip()}")
            return True
        else:
            print(f"  [FAIL] Cocotb配置错误: {result.stderr}")
            return False
    except FileNotFoundError:
        print(f"  [FAIL] cocotb-config未找到，Cocotb可能未正确安装")
        return False
    except subprocess.TimeoutExpired:
        print(f"  [WARN] cocotb-config检查超时")
        return False

def main():
    """主函数"""
    print("=" * 60)
    print("fp_mac测试环境自检")
    print("=" * 60)

    checks = [
        ("Python版本", check_python_version),
        ("Python包依赖", check_imports),
        ("仿真器", check_simulator),
        ("RTL文件", check_rtl_files),
        ("测试文件", check_test_files),
        ("Cocotb配置", check_cocotb_config),
    ]

    results = []
    for name, func in checks:
        print(f"\n[{name}]")
        try:
            success = func()
            results.append((name, success))
        except Exception as e:
            print(f"  检查出错: {e}")
            results.append((name, False))

    print("\n" + "=" * 60)
    print("自检结果:")
    print("=" * 60)

    all_passed = True
    for name, success in results:
        status = "[PASS]" if success else "[FAIL]"
        print(f"{name:20} {status}")
        if not success:
            all_passed = False

    print("\n" + "=" * 60)
    if all_passed:
        print("所有检查通过！测试环境就绪。")
        print("运行测试: python run.py all --waves")
        return 0
    else:
        print("部分检查失败，请解决上述问题。")
        print("\n常见解决方案:")
        print("1. 安装缺失的Python包: pip install cocotb")
        print("2. 安装仿真器（如Icarus Verilog）")
        print("3. 确保RTL文件存在于 ../rtl/ 目录")
        return 1

if __name__ == "__main__":
    sys.exit(main())
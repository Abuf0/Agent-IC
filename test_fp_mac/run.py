#!/usr/bin/env python3
"""
fp_mac测试运行脚本
提供命令行接口来运行测试、生成报告等
"""

import os
import sys
import subprocess
import argparse
import xml.etree.ElementTree as ET
from datetime import datetime

def run_simulation(waves=False, wave_format="vcd", sim="icarus"):
    """运行仿真"""
    print("=" * 60)
    print("开始 fp_mac 仿真测试")
    print(f"时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    # 设置环境变量
    env = os.environ.copy()
    if waves:
        env["WAVES"] = "1"
        env["WAVE_FORMAT"] = wave_format
        print(f"波形生成: 启用 ({wave_format}格式)")
    else:
        env["WAVES"] = "0"
        print("波形生成: 禁用")

    env["SIM"] = sim
    print(f"仿真器: {sim}")

    # 运行make
    cmd = ["make", "SIMULATOR=" + sim]
    if waves:
        cmd.append("WAVES=1")

    print(f"执行命令: {' '.join(cmd)}")
    print("-" * 60)

    try:
        result = subprocess.run(
            cmd,
            env=env,
            cwd=os.path.dirname(os.path.abspath(__file__)),
            capture_output=True,
            text=True,
            check=False
        )

        print(result.stdout)
        if result.stderr:
            print("STDERR:", result.stderr)

        if result.returncode != 0:
            print(f"仿真失败，返回码: {result.returncode}")
            return False

        print("-" * 60)
        print("仿真完成")
        return True

    except subprocess.CalledProcessError as e:
        print(f"仿真过程错误: {e}")
        return False
    except FileNotFoundError:
        print("错误: 找不到make命令。请确保make已安装并在PATH中。")
        return False

def generate_report():
    """生成测试报告"""
    results_file = "results.xml"
    if not os.path.exists(results_file):
        print("错误: 找不到结果文件 results.xml")
        return False

    try:
        tree = ET.parse(results_file)
        root = tree.getroot()

        tests = int(root.get("tests", 0))
        failures = int(root.get("failures", 0))
        errors = int(root.get("errors", 0))
        skipped = int(root.get("skipped", 0))
        time = float(root.get("time", 0))

        passed = tests - failures - errors - skipped
        pass_rate = (passed / tests * 100) if tests > 0 else 0

        print("=" * 60)
        print("测试报告")
        print("=" * 60)
        print(f"测试总数:    {tests}")
        print(f"通过:        {passed}")
        print(f"失败:        {failures}")
        print(f"错误:        {errors}")
        print(f"跳过:        {skipped}")
        print(f"执行时间:    {time:.2f} 秒")
        print(f"通过率:      {pass_rate:.2f}%")
        print("=" * 60)

        # 打印失败详情
        if failures > 0 or errors > 0:
            print("\n失败/错误详情:")
            for testcase in root.findall(".//testcase"):
                failure = testcase.find("failure")
                error = testcase.find("error")
                if failure is not None:
                    print(f"  - {testcase.get('name')}: {failure.get('message', '')}")
                if error is not None:
                    print(f"  - {testcase.get('name')}: {error.get('message', '')}")

        # 保存报告到文件
        report_file = "test_report.txt"
        with open(report_file, "w") as f:
            f.write("=" * 60 + "\n")
            f.write("fp_mac 测试报告\n")
            f.write("=" * 60 + "\n")
            f.write(f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write(f"测试总数:    {tests}\n")
            f.write(f"通过:        {passed}\n")
            f.write(f"失败:        {failures}\n")
            f.write(f"错误:        {errors}\n")
            f.write(f"跳过:        {skipped}\n")
            f.write(f"执行时间:    {time:.2f} 秒\n")
            f.write(f"通过率:      {pass_rate:.2f}%\n")
            f.write("=" * 60 + "\n")

            if failures > 0 or errors > 0:
                f.write("\n失败/错误详情:\n")
                for testcase in root.findall(".//testcase"):
                    failure = testcase.find("failure")
                    error = testcase.find("error")
                    if failure is not None:
                        f.write(f"  - {testcase.get('name')}: {failure.get('message', '')}\n")
                    if error is not None:
                        f.write(f"  - {testcase.get('name')}: {error.get('message', '')}\n")

        print(f"\n详细报告已保存到: {report_file}")

        return pass_rate == 100.0

    except Exception as e:
        print(f"生成报告时出错: {e}")
        return False

def clean():
    """清理生成的文件"""
    print("清理生成的文件...")

    files_to_remove = [
        "results.xml",
        "test_report.txt",
        "*.vcd",
        "*.fst",
        "*.log",
    ]

    dirs_to_remove = [
        "sim_build",
        "__pycache__",
    ]

    for pattern in files_to_remove:
        for f in glob.glob(pattern):
            try:
                os.remove(f)
                print(f"删除文件: {f}")
            except:
                pass

    for dir_path in dirs_to_remove:
        if os.path.exists(dir_path):
            try:
                shutil.rmtree(dir_path)
                print(f"删除目录: {dir_path}")
            except:
                pass

    print("清理完成")

def main():
    """主函数"""
    parser = argparse.ArgumentParser(description="fp_mac测试运行脚本")
    parser.add_argument("action", choices=["run", "report", "clean", "all"],
                        help="执行的操作: run=运行仿真, report=生成报告, clean=清理, all=运行所有")
    parser.add_argument("--waves", action="store_true", help="启用波形生成")
    parser.add_argument("--format", default="vcd", choices=["vcd", "fst"],
                        help="波形格式 (vcd或fst)")
    parser.add_argument("--sim", default="icarus", choices=["icarus", "verilator"],
                        help="仿真器选择")

    args = parser.parse_args()

    if args.action == "run":
        success = run_simulation(args.waves, args.format, args.sim)
        sys.exit(0 if success else 1)

    elif args.action == "report":
        success = generate_report()
        sys.exit(0 if success else 1)

    elif args.action == "clean":
        import shutil
        import glob
        clean()
        sys.exit(0)

    elif args.action == "all":
        # 运行所有步骤
        success = run_simulation(args.waves, args.format, args.sim)
        if success:
            print("\n" + "=" * 60)
            print("仿真成功，生成报告...")
            print("=" * 60)
            success = generate_report()
        sys.exit(0 if success else 1)

    else:
        parser.print_help()
        sys.exit(1)

if __name__ == "__main__":
    main()
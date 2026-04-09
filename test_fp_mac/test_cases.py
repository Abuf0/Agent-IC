#!/usr/bin/env python3
"""
fp_mac测试用例定义
包含预定义的测试用例，用于定向测试
"""

import struct

def float_to_int(f):
    """将单精度浮点数转换为32位整数表示"""
    return struct.unpack('>I', struct.pack('>f', f))[0]

def int_to_float(i):
    """将32位整数表示转换为单精度浮点数"""
    return struct.unpack('>f', struct.pack('>I', i))[0]

class TestCase:
    """测试用例类"""
    def __init__(self, name, a, b, c, rnd=0, expected_z=None, expected_status=0,
                 description="", tolerance=0):
        self.name = name
        self.a = a if isinstance(a, int) else float_to_int(a)
        self.b = b if isinstance(b, int) else float_to_int(b)
        self.c = c if isinstance(c, int) else float_to_int(c)
        self.rnd = rnd
        self.expected_z = expected_z
        self.expected_status = expected_status
        self.description = description
        self.tolerance = tolerance  # 允许的误差（ULP）

    def __str__(self):
        return f"{self.name}: a={self.a:08x}, b={self.b:08x}, c={self.c:08x}, rnd={self.rnd}"

# 基本功能测试用例
BASIC_CASES = [
    TestCase("basic_1", 1.0, 2.0, 3.0, 0, description="1*2+3=5"),
    TestCase("basic_2", 1.5, 2.0, 0.5, 0, description="1.5*2+0.5=3.5"),
    TestCase("basic_3", -1.0, 2.0, 3.0, 0, description="-1*2+3=1"),
    TestCase("basic_4", 1.0, -2.0, 3.0, 0, description="1*-2+3=1"),
    TestCase("basic_5", 1.0, 2.0, -3.0, 0, description="1*2-3=-1"),
    TestCase("basic_6", 0.0, 2.0, 3.0, 0, description="0*2+3=3"),
    TestCase("basic_7", 1.0, 0.0, 3.0, 0, description="1*0+3=3"),
    TestCase("basic_8", 1.0, 2.0, 0.0, 0, description="1*2+0=2"),
]

# 特殊值测试用例
SPECIAL_CASES = [
    # 零
    TestCase("zero_pos", 0x00000000, 0x00000000, 0x00000000, 0,
             description="正零乘累加"),
    TestCase("zero_neg", 0x80000000, 0x80000000, 0x80000000, 0,
             description="负零乘累加"),
    TestCase("zero_mixed", 0x00000000, 0x80000000, 0x00000000, 0,
             description="混合零"),

    # 无穷大
    TestCase("inf_pos", 0x7f800000, 0x3f800000, 0x00000000, 0,
             expected_status=0x02, description="正无穷×1+0=正无穷"),
    TestCase("inf_neg", 0xff800000, 0x3f800000, 0x00000000, 0,
             expected_status=0x02, description="负无穷×1+0=负无穷"),
    TestCase("inf_zero_nan", 0x7f800000, 0x00000000, 0x00000000, 0,
             expected_status=0x01, description="无穷大×零=NaN"),

    # NaN
    TestCase("nan_propagation", 0x7fc00000, 0x3f800000, 0x00000000, 0,
             expected_status=0x01, description="NaN传播"),

    # 次正规数
    TestCase("subnormal_min", 0x00000001, 0x00000001, 0x00000001, 0,
             description="最小次正规数运算"),
    TestCase("subnormal_max", 0x007fffff, 0x007fffff, 0x007fffff, 0,
             description="最大次正规数运算"),
]

# 舍入模式测试用例
ROUNDING_CASES = []
# 添加舍入敏感测试用例
rounding_sensitive = [
    # 值，期望结果（不同舍入模式可能不同）
    (1.5, 1.5, 0.25, "1.5*1.5+0.25=2.5"),  # 2.5 精确
    (1.1, 1.1, 1.1, "1.1*1.1+1.1=2.41"),   # 需要舍入
]

for i, (a, b, c, desc) in enumerate(rounding_sensitive):
    for rnd in range(5):
        case = TestCase(
            f"rounding_{i}_rnd{rnd}",
            a, b, c, rnd,
            description=f"{desc} (RND={rnd})",
            tolerance=1  # 舍入可能引入差异
        )
        ROUNDING_CASES.append(case)

# 边界条件测试用例
EDGE_CASES = [
    # 最大/最小值
    TestCase("max_normal", 0x7f7fffff, 0x7f7fffff, 0x00000000, 0,
             description="最大正规数平方"),
    TestCase("min_normal", 0x00800000, 0x00800000, 0x00000000, 0,
             description="最小正规数平方"),
    TestCase("max_subnormal", 0x007fffff, 0x007fffff, 0x00000000, 0,
             description="最大次正规数平方"),
    TestCase("min_subnormal", 0x00000001, 0x00000001, 0x00000000, 0,
             description="最小次正规数平方"),

    # 溢出边界
    TestCase("overflow_near", 0x7f000000, 0x7f000000, 0x7f000000, 0,
             description="接近溢出"),

    # 下溢边界
    TestCase("underflow_near", 0x00400000, 0x00400000, 0x00400000, 0,
             description="接近下溢"),

    # 精度损失
    TestCase("precision_loss", 1.0e20, 1.0e-20, 1.0, 0,
             description="大数×小数+常数 精度损失"),

    # 符号抵消
    TestCase("sign_cancel", 0x3f800000, 0x3f800000, 0xbf800000, 0,
             description="1*1 + (-1) = 0"),
]

# 流水线测试用例（连续输入）
PIPELINE_CASES = []
for i in range(10):
    a_val = 1.0 + i * 0.1
    b_val = 2.0 + i * 0.1
    c_val = 3.0 + i * 0.1
    case = TestCase(
        f"pipeline_{i}",
        a_val, b_val, c_val, 0,
        description=f"流水线连续输入 {i}: {a_val}*{b_val}+{c_val}"
    )
    PIPELINE_CASES.append(case)

# 所有测试用例
ALL_CASES = {
    "basic": BASIC_CASES,
    "special": SPECIAL_CASES,
    "rounding": ROUNDING_CASES,
    "edge": EDGE_CASES,
    "pipeline": PIPELINE_CASES,
}

def get_test_cases(category=None):
    """获取测试用例"""
    if category is None:
        # 返回所有用例
        all_cases = []
        for cases in ALL_CASES.values():
            all_cases.extend(cases)
        return all_cases
    elif category in ALL_CASES:
        return ALL_CASES[category]
    else:
        raise ValueError(f"未知测试类别: {category}")

if __name__ == "__main__":
    # 打印测试用例统计
    for category, cases in ALL_CASES.items():
        print(f"{category}: {len(cases)} 个测试用例")

    total = sum(len(cases) for cases in ALL_CASES.values())
    print(f"总计: {total} 个测试用例")
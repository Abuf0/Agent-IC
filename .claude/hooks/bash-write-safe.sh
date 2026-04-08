#!/bin/bash
# 功能：拦截可能向项目目录外写入的 Bash 命令

# 调试信息
echo "DEBUG: bash-write-safe.sh 开始执行" >&2

# 读取 stdin 中的 JSON（Claude 传入的 Bash 工具调用信息）
INPUT_JSON=$(cat)
echo "DEBUG: 输入JSON长度: ${#INPUT_JSON}" >&2

# 计算项目根目录
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
echo "DEBUG: 项目根目录: $PROJECT_ROOT" >&2

# 提取 command 字段（实际要执行的命令）
# 使用 grep/sed 提取，避免依赖 jq
COMMAND=$(echo "$INPUT_JSON" | grep -o '"command":\s*"[^"]*"' | head -1 | sed 's/"command":\s*"//;s/"//')
echo "DEBUG: 提取的命令: '$COMMAND'" >&2

# 如果提取失败（可能 JSON 格式变化），尝试备用方法
if [[ -z "$COMMAND" ]]; then
    # 尝试提取第一个包含 "command" 的字段（允许空格和不同格式）
    COMMAND=$(echo "$INPUT_JSON" | sed -n 's/.*"command":\s*"\([^"]*\)".*/\1/p' | head -1)
    echo "DEBUG: 备用方法提取的命令: '$COMMAND'" >&2
fi

# 如果仍然为空，使用原始输入（安全回退）
if [[ -z "$COMMAND" ]]; then
    COMMAND="$INPUT_JSON"
    echo "DEBUG: 使用原始输入作为命令: '$COMMAND'" >&2
fi

# 定义危险模式：重定向到绝对路径或包含 .. 的路径
if echo "$COMMAND" | grep -E -q '[>]?\s*/(etc|usr|var|home|root|tmp)/'; then
    echo "❌ 安全拦截：禁止向系统绝对路径写入 ($COMMAND)" >&2
    exit 2
fi

if echo "$COMMAND" | grep -E -q '[>]\s*\.\./'; then
    echo "❌ 安全拦截：禁止使用 ../ 向项目上级目录写入" >&2
    exit 2
fi

# 检查重定向到任何绝对路径（以/开头的路径）
if echo "$COMMAND" | grep -E -q '>[[:space:]]*/'; then
    echo "DEBUG: 检测到向绝对路径的重定向" >&2
    # 提取重定向后的目标路径
    # 匹配模式：> 或 >> 后面有空白，然后是以/开头的路径
    TARGET=$(echo "$COMMAND" | sed -n 's/.*>[[:space:]]*\([^[:space:]]*\).*/\1/p')
    echo "DEBUG: 提取的目标路径: '$TARGET'" >&2

    # 如果提取失败或为空，尝试匹配 >> 的情况
    if [ -z "$TARGET" ] || [[ ! "$TARGET" =~ ^/ ]]; then
        TARGET=$(echo "$COMMAND" | sed -n 's/.*>>[[:space:]]*\([^[:space:]]*\).*/\1/p')
        echo "DEBUG: 尝试>>提取的目标路径: '$TARGET'" >&2
    fi

    # 如果成功提取到以/开头的路径
    if [[ -n "$TARGET" ]] && [[ "$TARGET" =~ ^/ ]]; then
        echo "DEBUG: 目标路径是绝对路径: $TARGET" >&2
        # 解析绝对路径
        if command -v realpath &> /dev/null; then
            ABS_TARGET=$(realpath "$TARGET" 2>/dev/null || echo "$TARGET")
        else
            ABS_TARGET=$(cd "$(dirname "$TARGET")" 2>/dev/null && pwd)/$(basename "$TARGET" 2>/dev/null)
            # 如果解析失败，使用原始路径
            if [ $? -ne 0 ]; then
                ABS_TARGET="$TARGET"
            fi
        fi
        echo "DEBUG: 解析后的绝对路径: $ABS_TARGET" >&2

        # 检查是否在项目根目录内
        if [[ "$ABS_TARGET" != "$PROJECT_ROOT"/* ]] && [[ "$ABS_TARGET" != "$PROJECT_ROOT" ]]; then
            echo "❌ 安全拦截：禁止向项目目录外写入 ($COMMAND)" >&2
            echo "   项目根目录: $PROJECT_ROOT" >&2
            echo "   试图写入: $TARGET -> $ABS_TARGET" >&2
            exit 2
        else
            echo "DEBUG: 目标在项目目录内，允许执行" >&2
        fi
    fi
fi

# 可选：检查 cp/mv 的目标路径是否在项目外
if echo "$COMMAND" | grep -E -q '^[[:space:]]*(cp|mv)[[:space:]]+.*[[:space:]]+(/|\.\./)'; then
    echo "❌ 安全拦截：禁止 cp/mv 到项目外部" >&2
    exit 2
fi

echo "DEBUG: bash-write-safe.sh 检查通过" >&2
exit 0

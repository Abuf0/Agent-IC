#!/bin/bash
# 功能：禁止 Edit 工具修改项目目录外的任何文件

# 获取 Claude Code 传递给 Edit 工具的目标文件路径（环境变量）
TARGET_FILE="$CLAUDE_CODE_TOOL_ARGS"

# 如果环境变量为空，尝试从 stdin 或参数获取（根据 Claude Code 实际传递方式调整）
if [ -z "$TARGET_FILE" ]; then
    # 部分版本通过标准输入传递 JSON，这里简化处理：读取第一行作为路径
    read -r TARGET_FILE
fi

# 获取当前项目根目录（假设在项目根目录下执行 claude）
PROJECT_ROOT=$(pwd)

# 解析绝对路径（处理符号链接、相对路径）
# macOS 用户将 realpath 替换为 grealpath 或使用 readlink -f
if command -v realpath &> /dev/null; then
    ABS_TARGET=$(realpath "$TARGET_FILE" 2>/dev/null)
else
    ABS_TARGET=$(cd "$(dirname "$TARGET_FILE")" 2>/dev/null && pwd)/$(basename "$TARGET_FILE")
fi

# 检查是否在项目根目录内
if [[ "$ABS_TARGET" != "$PROJECT_ROOT"/* ]] && [[ "$ABS_TARGET" != "$PROJECT_ROOT" ]]; then
    echo "❌ 安全拦截：禁止编辑项目目录外的文件" >&2
    echo "   项目根目录: $PROJECT_ROOT" >&2
    echo "   试图编辑: $TARGET_FILE -> $ABS_TARGET" >&2
    exit 2  # 非零退出码阻止 Edit 操作
fi

exit 0
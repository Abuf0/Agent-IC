#!/bin/bash
# rm-safe.sh
# 两层安全策略：极度危险永远阻止；一般危险需用户主动创建标记文件

# 读取 stdin 中的 JSON（Claude 传入的 Bash 工具调用信息）
INPUT_JSON=$(cat)

# 计算项目根目录（脚本位于 .claude/hooks/rm-safe.sh）
PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# 提取 command 字段（实际要执行的命令）
# 使用 grep/sed 提取，避免依赖 jq
COMMAND=$(echo "$INPUT_JSON" | grep -o '"command":\s*"[^"]*"' | head -1 | sed 's/"command":\s*"//;s/"//')

# 如果提取失败（可能 JSON 格式变化），尝试备用方法
if [[ -z "$COMMAND" ]]; then
    # 尝试提取第一个包含 "command" 的字段（允许空格和不同格式）
    COMMAND=$(echo "$INPUT_JSON" | sed -n 's/.*"command":\s*"\([^"]*\)".*/\1/p' | head -1)
fi

# 如果仍然为空，使用原始输入（安全回退）
if [[ -z "$COMMAND" ]]; then
    COMMAND="$INPUT_JSON"
fi


# ==================== 极度危险：永远阻止 ====================
if [[ "$COMMAND" =~ "rm -rf /" || "$COMMAND" =~ "rm -rf --no-preserve-root" || "$COMMAND" =~ "rm -fr /" || "$COMMAND" =~ "rm -rf /\*" ]]; then
    echo "❌ 极度危险操作被永久禁止：" >&2
    echo "   $COMMAND" >&2
    echo "   原因：该命令会破坏操作系统，且无法恢复。" >&2
    echo "   建议：在容器或虚拟机中测试，或使用安全删除工具（如 trash-cli）。" >&2
    exit 2
fi

# ==================== 所有 rm 命令：需要用户放行文件 ====================
if [[ "$COMMAND" =~ (^|[[:space:]])rm([[:space:]]|$) ]]; then
    ALLOW_FILE="$PROJECT_ROOT/.claude_allow_rm"
    if [[ -f "$ALLOW_FILE" ]]; then
        # 从命令中提取待删除的文件参数（过滤掉选项如 -f, -r, -rf 等）
        # 将命令分割成数组，然后过滤不以 '-' 开头的参数
        IFS=' ' read -ra PARTS <<< "$COMMAND"
        FILES_TO_DELETE=()
        for part in "${PARTS[@]}"; do
            # 跳过 'rm' 命令本身和以 '-' 开头的选项
            if [[ "$part" != "rm" && ! "$part" =~ ^- ]]; then
                FILES_TO_DELETE+=("$part")
            fi
        done

        if [ ${#FILES_TO_DELETE[@]} -eq 0 ]; then
            echo "⚠️  检测到 rm 命令但无文件参数，放行文件存在，继续执行..." >&2
            exit 0
        fi

        # 读取允许列表文件（每行一个文件路径，支持 # 注释和空行）
        ALLOWED_FILES=()
        if [[ -f "$ALLOW_FILE" ]]; then
            while IFS= read -r line || [[ -n "$line" ]]; do
                # 移除前后空白，跳过空行和注释行
                line_trimmed=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
                if [[ -n "$line_trimmed" && ! "$line_trimmed" =~ ^# ]]; then
                    # 规范化路径：移除前导 ./（如果存在）
                    normalized="${line_trimmed#./}"
                    ALLOWED_FILES+=("$normalized")
                fi
            done < "$ALLOW_FILE"
        fi

        # 检查每个待删除文件是否在允许列表中
        UNAUTHORIZED_FILES=()
        for file in "${FILES_TO_DELETE[@]}"; do
            # 规范化待删除文件路径：移除前导 ./（如果存在）
            file_normalized="${file#./}"
            FOUND=0
            for allowed in "${ALLOWED_FILES[@]}"; do
                # 允许列表已规范化，直接比较
                if [[ "$file_normalized" == "$allowed" ]]; then
                    FOUND=1
                    break
                fi
            done
            if [ $FOUND -eq 0 ]; then
                UNAUTHORIZED_FILES+=("$file")
            fi
        done

        if [ ${#UNAUTHORIZED_FILES[@]} -eq 0 ]; then
            echo "✅  所有待删除文件均在允许列表中，继续执行..." >&2
            exit 0
        else
            echo "❌  rm 命令包含未授权的文件：" >&2
            echo "   命令: $COMMAND" >&2
            echo "   未授权文件: ${UNAUTHORIZED_FILES[*]}" >&2
            echo "   允许列表: ${ALLOWED_FILES[*]}" >&2
            echo "   请将文件添加到 $ALLOW_FILE 或从 rm 命令中移除。" >&2
            exit 2
        fi
    else
        echo "⚠️  检测到 rm 命令：" >&2
        echo "   $COMMAND" >&2
        echo "" >&2
        echo "   安全策略要求您主动确认。" >&2
        echo "   如需允许此类操作，请创建放行文件：" >&2
        echo "   touch $ALLOW_FILE" >&2
        echo "" >&2
        echo "   创建后重新执行命令。" >&2
        echo "   （注意：放行文件不会影响极度危险命令的阻止）" >&2
        exit 2
    fi
fi

# ==================== 一般危险：需要用户放行文件 ====================
if [[ "$COMMAND" =~ "rm -rf ~" || "$COMMAND" =~ "rm -fr \." || "$COMMAND" =~ "rm -rf \$HOME" ]]; then
    ALLOW_FILE="$PROJECT_ROOT/.claude_allow_rm"
    if [[ -f "$ALLOW_FILE" ]]; then
        echo "⚠️  检测到一般危险命令，但放行文件存在 ($ALLOW_FILE)，继续执行..." >&2
        exit 0
    else
        echo "⚠️  检测到一般危险命令：" >&2
        echo "   $COMMAND" >&2
        echo "" >&2
        echo "   安全策略要求您主动确认。" >&2
        echo "   如需允许此类操作，请创建放行文件：" >&2
        echo "   touch $ALLOW_FILE" >&2
        echo "" >&2
        echo "   创建后重新执行命令。" >&2
        echo "   （注意：放行文件不会影响极度危险命令的阻止）" >&2
        exit 2
    fi
fi

# 未匹配任何危险模式，允许执行
exit 0
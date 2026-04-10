---
name: clean_temp
description: 删除项目目录下的所有 Git worktree 目录（排除主仓库）以及所有 temp_* 开头的临时文件/目录。操作前会列出待删除项并请求确认。
---

# 清理 Worktrees 和临时文件

## 适用场景
- 项目积累了大量不再使用的 worktree（如 `../worktrees/*`）
- 存在临时文件或目录（如 `temp_*`）需要批量清理
- 准备归档或迁移项目，希望保持目录整洁

## 安全约束
- **绝不删除当前所在的主仓库目录**（通过检查路径是否包含 `.git` 来识别）
- **绝不删除系统目录或用户目录**（只操作当前项目根目录及其同级目录）
- **删除前必须列出所有待删除项，并等待用户明确确认**

## 操作步骤

### 1. 定位目标目录
- 当前项目根目录：`$(pwd)`
- worktree 常见位置：`../worktrees/`（与项目根目录同级）
- temp_* 文件：项目根目录下所有匹配 `temp_*` 的文件或目录，以及 `worktrees/` 内部的 `temp_*`

### 2. 扫描并列出待删除项
执行以下 Bash 命令（仅扫描，不删除）：

```bash
# 列出 worktree 目录（假设在 ../worktrees/）
echo "=== Worktree 目录 ==="
ls -d ../worktrees/*/ 2>/dev/null || echo "无"

# 列出项目根目录下的 temp_* 
echo "=== 项目根目录下的 temp_* ==="
ls -d temp_* 2>/dev/null || echo "无"

# 列出每个 worktree 内部的 temp_*
echo "=== Worktree 内部的 temp_* ==="
for wt in ../worktrees/*/; do
    if [ -d "$wt" ]; then
        ls -d "$wt"/temp_* 2>/dev/null | sed "s|^|  - |"
    fi
done
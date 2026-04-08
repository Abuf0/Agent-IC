---
description: 批量审查 rtl/rtl_splitter/ 目录下的所有 RTL 文件，每个文件独立调用 code-reviewer，最后汇总报告。
---

请严格按照以下步骤执行批量审查任务：

### 步骤 1：获取待审查文件列表
- 检查当前项目根目录下的rtl目录下是否存在 `rtl_splitter/` 文件夹。
- 如果不存在，提示用户：“未找到 rtl_splitter/ 目录，请先运行 `code_splitter` 拆分 RTL 文件。” 并终止。
- 如果存在，使用 `Bash` 工具执行以下命令获取文件路径列表：
  - Linux/macOS: `ls rtl_splitter/*.v rtl_splitter/*.sv 2>/dev/null`
  - Windows (Git Bash/WSL): 同上；若使用原生 cmd，请提示用户切换到 Git Bash。
- 将列表存储为数组变量 `files`。

### 步骤 2：循环调用 code-reviewer subagent
- 对 `files` 中的**每一个文件**，依次执行：
  1. 调用 `code-reviewer` subagent，传入该文件路径作为参数。
  2. 等待 subagent 完成（输出 “已审查...结果保存至...”）。
  3. **不要**累积文件内容或中间结果到主对话中。
  4. 继续处理下一个文件。
- 如果某个文件调用失败，记录错误并继续处理下一个。

### 步骤 3：汇总所有 JSON 结果
- 所有 subagent 执行完毕后，使用 `Read` 工具读取 `/tmp/review_*.json` 文件（匹配模式 `/tmp/review_*.json`）。
- 合并所有 JSON 中的 `issues` 和 `optimizations` 字段。
- 生成一个 Markdown 格式的汇总报告，包含：
  - **总体摘要**：审查文件总数、发现的问题总数（按严重程度分类）。
  - **详细问题表格**：列包含 `文件路径`、`行号`、`严重程度`、`问题描述`、`建议方案`。
  - **优化建议列表**：每个文件的优化建议汇总。
  - **SPEC 完整性**：每个文件的 `spec_complete` 状态，若有缺失，建议补充。
- 将汇总报告写入 `/tmp/review_summary.md`。

### 步骤 4：输出结果
- 在对话中输出以下内容（不要输出完整报告）：
  批量审查完成！
  共审查 X 个文件，发现 Y 个问题（高: H, 中: M, 低: L）。
  详细报告已生成：`/tmp/review_summary.md`
- 可选：提示用户可以用 `cat /tmp/review_summary.md` 查看报告。

### 注意事项
- 整个过程中，主对话只保留文件列表和调用状态，不保留文件内容。
- 每个 subagent 独立运行，不会导致上下文溢出。
- 如果文件数量 > 20，建议分批执行（每 10 个一组），避免单个命令运行时间过长。
# Git管理指南 - fp_mac RTL项目

## 📋 目录
- [分支策略](#分支策略)
- [提交规范](#提交规范)
- [工作流程](#工作流程)
- [Git钩子配置](#git钩子配置)
- [CI/CD集成](#cicd集成)
- [常用命令](#常用命令)

## 🌿 分支策略

### 主要分支
- **main**: 生产就绪代码，始终稳定
- **develop**: 集成开发分支，功能合并点

### 支持分支
- **feature/***: 新功能开发 (从`develop`分支创建)
- **bugfix/***: 缺陷修复 (从`develop`分支创建)
- **release/***: 版本发布准备 (从`develop`分支创建)
- **hotfix/***: 紧急生产修复 (从`main`分支创建)

### RTL特定分支
- **rtl/***: RTL设计修改 (模块级修改)
- **verif/***: 验证环境开发
- **constraint/***: 约束文件修改
- **doc/***: 文档更新

## 📝 提交规范

### 提交信息格式
```
<type>(<scope>): <subject>

<body>

<footer>
```

### 类型 (Type)
- **feat**: 新功能 (RTL功能、验证功能)
- **fix**: 缺陷修复 (RTL bug、验证环境bug)
- **docs**: 文档更新 (SPEC、README、注释)
- **style**: 代码格式 (不影响功能)
- **refactor**: 重构 (不改变功能)
- **test**: 测试相关 (测试用例、验证环境)
- **chore**: 构建/工具更新 (Makefile、脚本)

### 范围 (Scope) - RTL特定
- **rtl**: RTL代码修改
- **verif**: 验证环境修改
- **constraint**: 约束文件修改
- **lint**: Lint检查相关
- **synth**: 综合相关
- **pkg**: 包/模块化

### 示例
```
feat(rtl): 添加浮点乘法器流水线

- 实现3级流水线乘法器
- 添加流水线控制逻辑
- 更新相关状态机

Close #123
```

```
fix(verif): 修复随机测试覆盖率漏洞

- 添加边界条件测试
- 修复浮点特殊值测试
- 更新覆盖率收集脚本

See also #45
```

## 🔄 工作流程

### 1. 功能开发流程
```bash
# 1. 从develop创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/fp-mac-pipeline

# 2. 开发并提交
git add .
git commit -m "feat(rtl): 添加乘法器流水线"

# 3. 推送并创建PR
git push origin feature/fp-mac-pipeline
# 在GitHub/GitLab创建Pull Request到develop
```

### 2. 验证开发流程
```bash
# 1. 创建验证分支
git checkout -b verif/coverage-enhancement develop

# 2. 开发测试用例
# 3. 运行验证并确保通过
make test

# 4. 提交验证代码
git add test/
git commit -m "test(verif): 增强边界条件覆盖"
```

### 3. 发布流程
```bash
# 1. 创建发布分支
git checkout -b release/v1.0.0 develop

# 2. 版本号更新
# 更新版本文件、标签等
# 3. 合并到main和develop
git checkout main
git merge --no-ff release/v1.0.0
git tag -a v1.0.0 -m "Release v1.0.0"
git checkout develop
git merge --no-ff release/v1.0.0
```

## ⚙️ Git钩子配置

### 预提交钩子 (.git/hooks/pre-commit)
```bash
#!/bin/bash
# 运行代码检查
echo "Running pre-commit checks..."

# 检查SystemVerilog语法
iverilog -tnull rtl/fp_mac.sv 2>/dev/null || {
    echo "SystemVerilog syntax error detected"
    exit 1
}

# 运行Python语法检查
python -m py_compile test/test_fma.py 2>/dev/null || {
    echo "Python syntax error detected"
    exit 1
}

echo "Pre-commit checks passed"
```

### 提交信息钩子 (.git/hooks/commit-msg)
```bash
#!/bin/bash
# 验证提交信息格式
MSG_FILE=$1
MSG=$(cat "$MSG_FILE")

# 提交信息格式正则
REGEX="^(feat|fix|docs|style|refactor|test|chore)(\(rtl|verif|constraint|lint|synth|pkg\))?: .{1,50}"

if ! [[ $MSG =~ $REGEX ]]; then
    echo "Invalid commit message format"
    echo "Expected: <type>(<scope>): <subject>"
    echo "Where type: feat, fix, docs, style, refactor, test, chore"
    echo "Scope: rtl, verif, constraint, lint, synth, pkg (optional)"
    exit 1
fi
```

## 🚀 CI/CD集成

### GitHub Actions示例 (.github/workflows/ci.yml)
```yaml
name: RTL CI Pipeline

on: [push, pull_request]

jobs:
  lint-check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Lint Check
        run: |
          # 添加Lint检查脚本
          echo "Lint check placeholder"

  verification:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Python
        uses: actions/setup-python@v2
        with:
          python-version: '3.9'
      - name: Install Cocotb
        run: pip install cocotb
      - name: Run Tests
        run: |
          cd test
          make
```

### 验证质量门禁
- ✅ 所有测试通过
- ✅ Lint检查无错误
- ✅ 代码覆盖率 >90%
- ✅ 文档更新完整

## 🛠️ 常用命令

### 日常开发
```bash
# 查看状态
git status
git log --oneline --graph --all

# 分支管理
git branch -avv
git checkout -b <branch-name>
git branch -d <branch-name>

# 暂存和提交
git add -p  # 交互式暂存
git commit -v  # 详细提交

# 同步远程
git fetch --all
git pull --rebase
git push origin <branch-name>
```

### RTL特定工作流
```bash
# 1. 创建RTL修改分支
git checkout -b rtl/pipeline-optimization develop

# 2. 开发后运行验证
cd test && make clean && make

# 3. 如果验证通过，提交代码
git add rtl/fp_mac.sv
git commit -m "feat(rtl): 优化乘法器流水线"

# 4. 创建验证更新分支
git checkout -b verif/pipeline-tests develop
git merge rtl/pipeline-optimization

# 5. 更新测试用例
# 6. 提交验证代码
git add test/
git commit -m "test(verif): 添加流水线测试用例"

# 7. 合并回develop
git checkout develop
git merge --no-ff rtl/pipeline-optimization
git merge --no-ff verif/pipeline-tests
```

### 标签管理
```bash
# 创建版本标签
git tag -a v1.0.0 -m "Release version 1.0.0"

# 推送标签
git push origin v1.0.0

# 列出所有标签
git tag -l

# 查看标签详情
git show v1.0.0
```

## 📊 分支生命周期

```
feature/rtl-optimization
    │
    ├── 开发RTL修改
    │
verif/rtl-optimization-tests
    │
    ├── 开发验证用例
    │
develop (集成测试)
    │
release/v1.1.0 (版本准备)
    │
main (生产发布) ← hotfix/critical-bug
    │
v1.1.0 (标签)
```

## 🔍 代码审查流程

1. **创建PR**: 功能分支 → develop
2. **自动化检查**: CI运行测试和Lint
3. **人工审查**: 至少1名评审员
4. **修改请求**: 根据反馈更新代码
5. **合并**: Squash合并保持历史整洁

## 📁 .gitignore增强建议

根据项目进展，可能需要在.gitignore中添加：

```gitignore
# 综合工具输出
reports/
outputs/
work/

# 仿真波形
*.vpd
*.evcd

# 覆盖率数据
*.ucdb
*.cov

# 项目文件
*.qpf
*.qsf
*.xpr
```

---

**最后更新**: 2026-04-06  
**维护者**: RTL开发团队
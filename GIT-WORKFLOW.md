# Git 分支管理策略

## 🌟 分支命名规范

```
main        # 主分支，用于生产环境
develop     # 开发分支，用于开发环境
feature/*   # 功能分支，用于新功能开发
hotfix/*    # 紧急修复分支，用于生产环境bug修复
release/*   # 发布分支，用于版本发布
```

## 🚀 快速开始

### 1. 初始化分支策略

```bash
# 使用脚本（推荐）
chmod +x git-branch-setup.sh
./git-branch-setup.sh  # 选择选项 1

# 手动执行
git checkout main
git checkout -b develop
git push -u origin develop
```

## 📋 常用命令

### 初始化和基础操作

```bash
# 1. 创建并切换到develop分支
git checkout main
git checkout -b develop
git push -u origin develop

# 2. 查看所有分支
git branch -a

# 3. 查看当前分支
git branch --show-current
```

### 功能开发工作流

```bash
# 1. 创建功能分支
git checkout develop
git pull origin develop
git checkout -b feature/user-authentication
git push -u origin feature/user-authentication

# 2. 开发过程中提交
git add .
git commit -m "feat: add user login functionality"
git push origin feature/user-authentication

# 3. 功能完成后合并到develop
git checkout develop
git pull origin develop
git merge --no-ff feature/user-authentication
git push origin develop

# 4. 删除功能分支
git branch -d feature/user-authentication
git push origin --delete feature/user-authentication
```

### 热修复工作流

```bash
# 1. 创建热修复分支（从main分支）
git checkout main
git pull origin main
git checkout -b hotfix/fix-critical-bug
git push -u origin hotfix/fix-critical-bug

# 2. 修复bug并提交
git add .
git commit -m "hotfix: fix critical login bug"
git push origin hotfix/fix-critical-bug

# 3. 合并到main分支
git checkout main
git merge --no-ff hotfix/fix-critical-bug
git push origin main

# 4. 合并到develop分支
git checkout develop
git merge --no-ff hotfix/fix-critical-bug
git push origin develop

# 5. 删除热修复分支
git branch -d hotfix/fix-critical-bug
git push origin --delete hotfix/fix-critical-bug
```

### 发布工作流

```bash
# 1. 创建发布分支（从develop分支）
git checkout develop
git pull origin develop
git checkout -b release/1.0.0
git push -u origin release/1.0.0

# 2. 发布准备（版本号更新、文档等）
git add .
git commit -m "chore: prepare for release 1.0.0"
git push origin release/1.0.0

# 3. 合并到main分支并打标签
git checkout main
git merge --no-ff release/1.0.0
git tag -a v1.0.0 -m "Release version 1.0.0"
git push origin main
git push origin v1.0.0

# 4. 合并回develop分支
git checkout develop
git merge --no-ff release/1.0.0
git push origin develop

# 5. 删除发布分支
git branch -d release/1.0.0
git push origin --delete release/1.0.0
```

## 🛠️ 脚本使用方法

### 运行分支管理脚本

```bash
chmod +x git-branch-setup.sh
./git-branch-setup.sh
```

### 脚本功能选项

1. **初始化分支策略** - 创建develop分支
2. **创建功能分支** - 创建feature/*分支
3. **创建热修复分支** - 创建hotfix/*分支
4. **创建发布分支** - 创建release/*分支
5. **合并功能分支** - 将feature分支合并到develop
6. **合并热修复分支** - 将hotfix分支合并到main和develop
7. **合并发布分支** - 将release分支合并到main和develop并打标签
8. **查看分支状态** - 显示所有分支和标签
9. **删除已合并分支** - 清理已合并的分支

## 📊 工作流程图

```
main     ──●──────●──────●──────●─→ (生产环境)
           │      ↑      ↑      ↑
           │   hotfix  release  hotfix
           │      │      │      │
develop    ●──●───●──●───●──●───●─→ (开发环境)
              │     │     │
            feature feature feature
              │     │     │
              ●─────●─────●
```

## 🎯 分支保护建议

### GitHub 分支保护规则

```bash
# 对于main分支的保护设置：
# 1. Require pull request reviews before merging
# 2. Require status checks to pass before merging
# 3. Require up-to-date branches before merging
# 4. Include administrators in these restrictions
```

### 自动化检查

在 `.github/workflows/` 中添加分支检查：

```yaml
# .github/workflows/branch-check.yml
name: Branch Check
on:
  pull_request:
    branches: [ main, develop ]

jobs:
  check-branch-naming:
    runs-on: ubuntu-latest
    steps:
      - name: Check branch naming
        run: |
          if [[ "${{ github.head_ref }}" =~ ^(feature|hotfix|release)/.+ ]]; then
            echo "✅ Branch naming is correct"
          else
            echo "❌ Branch must follow naming convention: feature/*, hotfix/*, release/*"
            exit 1
          fi
```

## 📚 提交信息规范

### Conventional Commits

```bash
feat: add new user authentication feature
fix: resolve login validation bug
docs: update API documentation
style: format code with prettier
refactor: restructure user service
test: add unit tests for login function
chore: update dependencies
```

### 提交示例

```bash
# 功能开发
git commit -m "feat(auth): add JWT token validation"

# Bug修复
git commit -m "fix(login): resolve password validation issue"

# 文档更新
git commit -m "docs(api): update endpoint documentation"

# 发布准备
git commit -m "chore(release): bump version to 1.0.0"
```

## 🔧 常用Git别名

将以下内容添加到 `~/.gitconfig`：

```ini
[alias]
    # 分支操作
    co = checkout
    br = branch
    sw = switch
    
    # 快速创建分支
    feature = "!f() { git checkout develop && git pull origin develop && git checkout -b feature/$1; }; f"
    hotfix = "!f() { git checkout main && git pull origin main && git checkout -b hotfix/$1; }; f"
    release = "!f() { git checkout develop && git pull origin develop && git checkout -b release/$1; }; f"
    
    # 状态和日志
    st = status
    lg = log --oneline --graph --decorate --all
    
    # 合并操作
    merge-feature = "!f() { git checkout develop && git pull origin develop && git merge --no-ff feature/$1; }; f"
    
    # 清理分支
    cleanup = "!git branch --merged develop | grep 'feature/' | xargs git branch -d"
```

## 🚨 注意事项

1. **永远不要直接在main分支开发**
2. **hotfix分支必须同时合并到main和develop**
3. **release分支合并后要打版本标签**
4. **定期清理已合并的分支**
5. **使用 --no-ff 进行合并以保持分支历史**

## 📞 快速参考

```bash
# 初始化
./git-branch-setup.sh  # 选择 1

# 日常开发
git checkout develop
git pull origin develop
git checkout -b feature/my-feature
# ... 开发 ...
git push -u origin feature/my-feature
# ... 创建PR到develop分支 ...

# 紧急修复
git checkout main
git checkout -b hotfix/urgent-fix
# ... 修复 ...
git push -u origin hotfix/urgent-fix
# ... 创建PR到main分支 ...

# 版本发布
git checkout develop
git checkout -b release/1.0.0
# ... 准备发布 ...
# ... 合并到main并打标签 ...
``` 
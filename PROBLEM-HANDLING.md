# 问题处理指南

## 🚨 概述

当CI/CD流水线或部署过程中遇到问题时，本指南提供了标准的处理流程，确保问题能够有序、可追溯地得到解决。

## 📋 问题分类

### 1. CI/CD检查失败
- 代码格式问题 (Black, isort)
- 代码质量问题 (flake8, mypy)
- 测试失败 (单元测试、集成测试)
- 安全检查失败 (Bandit, pip-audit)
- Docker构建失败
- GitHub Actions版本过时问题

### 2. 部署问题
- 容器启动失败
- 健康检查失败
- 服务器连接问题
- 镜像拉取失败

### 3. 功能问题
- API功能异常
- 业务逻辑错误
- 性能问题

### 4. 紧急生产问题
- 生产环境宕机
- 数据安全问题
- 严重性能问题

## 🔧 处理流程

### 1. CI/CD检查失败处理

#### 步骤1: 创建hotfix分支
```bash
# 从develop分支创建hotfix分支
git checkout develop
git pull origin develop
git checkout -b hotfix/fix-ci-$(date +%Y%m%d%H%M)

# 或者使用描述性名称
git checkout -b hotfix/fix-black-formatting
git checkout -b hotfix/fix-unit-tests
git checkout -b hotfix/fix-security-issues
```

#### 步骤2: 本地诊断问题
```bash
# 运行本地CI/CD测试脚本
bash test-ci-cd.sh

# 或者单独运行各项检查
black --check .           # 代码格式检查
isort --check-only .       # 导入排序检查
flake8 .                   # 代码规范检查
pytest tests/ -v           # 运行测试
bandit -r .                # 安全检查
```

#### 步骤3: 修复问题
```bash
# 修复代码格式
black .
isort .

# 修复测试问题
# 编辑测试文件或源代码

# 修复安全问题
# 更新依赖或修复代码

# 修复GitHub Actions版本问题
bash update-github-actions.sh

# 重新测试
pytest tests/ -v
```

#### 步骤4: 提交修复
```bash
git add .
git commit -m "hotfix: fix CI/CD issues

- Fix code formatting with black and isort
- Fix unit test failures
- Resolve security warnings
- Update dependencies
- Update GitHub Actions to latest versions"

git push origin hotfix/fix-ci-$(date +%Y%m%d%H%M)
```

#### 步骤5: 创建Pull Request
```bash
# 创建PR到develop分支
# 标题: [HOTFIX] Fix CI/CD Issues
# 描述: 详细说明修复的问题和解决方案
```

### 2. 部署问题处理

#### 步骤1: 快速回滚（如果需要）
```bash
# 在服务器上执行回滚
./scripts/deploy.sh rollback
```

#### 步骤2: 分析问题
```bash
# 查看容器日志
docker logs fastapi-books-development

# 查看部署脚本日志
# 检查GitHub Actions日志

# 查看服务器资源
docker stats
df -h
free -m
```

#### 步骤3: 创建修复分支
```bash
git checkout develop
git pull origin develop
git checkout -b hotfix/fix-deployment-$(date +%Y%m%d%H%M)
```

#### 步骤4: 修复部署问题
```bash
# 可能的修复：
# - 更新Dockerfile
# - 修改部署脚本
# - 调整容器配置
# - 修复依赖问题

# 本地测试Docker构建
docker build -t fastapi-books-test .
docker run -p 8000:8000 fastapi-books-test
```

### 3. 功能问题处理

#### 对于非紧急功能问题：
```bash
# 创建feature分支
git checkout develop
git pull origin develop
git checkout -b feature/fix-api-bug-$(date +%Y%m%d)

# 修复功能
# 添加/更新测试
# 本地验证

git add .
git commit -m "feat: fix API endpoint bug

- Fix book rating query issue
- Add comprehensive test coverage
- Update API documentation"

git push origin feature/fix-api-bug-$(date +%Y%m%d)
```

### 4. GitHub Actions版本问题处理

#### 常见GitHub Actions错误：
- `Missing download info for actions/xxx@v3`
- `Error downloading action`
- `Action not found`
- `Deprecated action warning`

#### 处理步骤：

##### 步骤1: 检查过时的action版本
```bash
# 运行版本检查脚本
bash update-github-actions.sh

# 手动检查工作流文件
grep -r "uses:" .github/workflows/
```

##### 步骤2: 更新到最新版本
```bash
# 创建修复分支
git checkout develop
git pull origin develop
git checkout -b hotfix/update-github-actions-$(date +%Y%m%d)

# 更新常见的过时版本
sed -i 's/actions\/upload-artifact@v3/actions\/upload-artifact@v4/g' .github/workflows/*.yml
sed -i 's/actions\/setup-python@v4/actions\/setup-python@v5/g' .github/workflows/*.yml
sed -i 's/actions\/cache@v3/actions\/cache@v4/g' .github/workflows/*.yml
sed -i 's/docker\/setup-buildx-action@v3/docker\/setup-buildx-action@v4/g' .github/workflows/*.yml
sed -i 's/docker\/login-action@v3/docker\/login-action@v4/g' .github/workflows/*.yml
sed -i 's/codecov\/codecov-action@v3/codecov\/codecov-action@v4/g' .github/workflows/*.yml
```

##### 步骤3: 验证更新
```bash
# 检查语法
yamllint .github/workflows/*.yml

# 提交更改
git add .github/workflows/
git commit -m "hotfix: update GitHub Actions to latest versions

- Update actions/upload-artifact v3 → v4
- Update actions/setup-python v4 → v5  
- Update actions/cache v3 → v4
- Update Docker actions to latest versions
- Fix Missing download info errors"

git push origin hotfix/update-github-actions-$(date +%Y%m%d)
```

##### 推荐的action版本：
| Action                       | 推荐版本 | 说明           |
| ---------------------------- | -------- | -------------- |
| `actions/checkout`           | v4       | 代码检出       |
| `actions/setup-python`       | v5       | Python环境设置 |
| `actions/cache`              | v4       | 依赖缓存       |
| `actions/upload-artifact`    | v4       | 文件上传       |
| `docker/setup-buildx-action` | v4       | Docker Buildx  |
| `docker/login-action`        | v4       | Docker登录     |
| `docker/build-push-action`   | v6       | Docker构建推送 |
| `codecov/codecov-action`     | v4       | 代码覆盖率     |

### 5. 紧急生产问题处理

#### 步骤1: 立即回滚生产环境
```bash
# 在生产服务器执行
./scripts/deploy.sh rollback
```

#### 步骤2: 创建紧急hotfix分支
```bash
# 从main分支创建
git checkout main
git pull origin main
git checkout -b hotfix/urgent-production-fix-$(date +%Y%m%d%H%M)
```

#### 步骤3: 快速修复
```bash
# 最小化修复，只修复紧急问题
# 添加必要的测试

git add .
git commit -m "hotfix: urgent production fix

- Fix critical security vulnerability
- Add regression test
- Verified in staging environment"

git push origin hotfix/urgent-production-fix-$(date +%Y%m%d%H%M)
```

#### 步骤4: 紧急部署流程
```bash
# 创建PR到main分支
# 快速代码审查（至少一人审查）
# 合并后自动部署到生产环境
# 验证修复效果

# 将修复合并回develop分支
git checkout develop
git pull origin develop
git merge main
git push origin develop
```

## 📊 问题处理记录

### 创建问题处理模板

对于每个问题，创建GitHub Issue记录：

```markdown
## 问题描述
- **问题类型**: CI/CD失败 / 部署问题 / 功能问题 / 紧急生产问题
- **影响范围**: 开发环境 / 生产环境
- **严重程度**: 低 / 中 / 高 / 紧急
- **发现时间**: YYYY-MM-DD HH:MM

## 问题详情
详细描述问题现象、错误信息、影响范围等

## 解决方案
- **修复分支**: hotfix/fix-xxx
- **修复内容**: 具体修复了什么
- **测试验证**: 如何验证修复效果

## 预防措施
如何避免类似问题再次发生
```

## 🚀 自动化问题处理

### 创建问题处理脚本

<script>
#!/bin/bash
# fix-ci-issues.sh - 自动修复常见CI问题

echo "🔧 自动修复CI/CD问题..."

# 修复代码格式
echo "📝 修复代码格式..."
black .
isort .

# 更新依赖
echo "📦 检查依赖更新..."
pip-audit --fix

# 运行测试
echo "🧪 运行测试..."
pytest tests/ -v

echo "✅ 自动修复完成，请检查结果并提交更改"
</script>

## 🔄 最佳实践

### 1. **永远不要直接修改develop/main分支**
```bash
# ❌ 错误做法
git checkout develop
# 直接在develop上修改

# ✅ 正确做法
git checkout develop
git checkout -b hotfix/fix-issue
# 在hotfix分支上修改
```

### 2. **保持修复的原子性**
- 每个hotfix分支只解决一个特定问题
- 避免在同一个分支中混合多种类型的修复

### 3. **及时沟通**
- 在团队群组中及时通报问题和修复进展
- 更新相关的Issue和PR状态

### 4. **文档化问题和解决方案**
- 记录问题的根本原因
- 分享解决方案给团队成员
- 更新相关文档和流程

### 5. **测试驱动修复**
- 先添加重现问题的测试
- 修复问题使测试通过
- 确保修复不会引入新问题

## 📈 问题预防

### 1. **本地开发最佳实践**
```bash
# 提交前总是运行本地检查
bash test-ci-cd.sh

# 或者设置git hooks
# .git/hooks/pre-commit
#!/bin/bash
black --check . && isort --check-only . && flake8 . && pytest tests/
```

### 2. **定期维护**
```bash
# 定期更新依赖
pip install --upgrade pip
pip install -r requirements-dev-compatible.txt --upgrade

# 定期清理Docker资源
docker system prune -f
```

### 3. **监控和警报**
- 设置GitHub Actions失败通知
- 监控部署状态
- 定期检查安全漏洞

---

**记住**: 
- 🔄 **遵循既定工作流程**
- 📝 **记录问题和解决方案** 
- 🧪 **测试所有修复**
- 🤝 **及时沟通团队** 
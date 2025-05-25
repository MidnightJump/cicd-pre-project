# CI/CD 完整指南

## 🚀 概述

本项目实现了完整的 CI/CD 流水线，包括：

- ✅ **单元测试** (Unit Tests)
- ✅ **集成测试** (Integration Tests)  
- ✅ **代码风格检查** (Styling Checks)
- ✅ **代码质量检查** (Linting Checks)
- ✅ **安全检查** (Security Checks)
- ✅ **容器安全扫描** (Container Security Scan)
- ✅ **自动化部署** (Automated Deployment)

## 📋 工作流程

### 1. 代码质量检查 (Code Quality)

```yaml
- Black 代码格式化检查
- isort 导入排序检查  
- flake8 代码规范检查
- mypy 类型检查
```

### 2. 安全检查 (Security Checks)

```yaml
- Bandit 安全漏洞扫描
- pip-audit 依赖漏洞检查
- 生成安全报告
```

### 3. 测试阶段 (Testing)

#### 单元测试
- 多Python版本测试 (3.9, 3.10, 3.11)
- 代码覆盖率检查 (最低80%)
- 生成覆盖率报告

#### 集成测试
- API端点集成测试
- 完整工作流测试
- 并发请求测试

### 4. Docker构建 (Docker Build)

```yaml
- 多架构构建 (linux/amd64, linux/arm64)
- 镜像推送到 GitHub Container Registry
- 生成 SBOM (Software Bill of Materials)
- 容器安全扫描 (Trivy)
```

### 5. 自动化部署 (Deployment)

```yaml
- 开发环境部署 (develop分支)
- 生产环境部署 (main分支)
- 健康检查验证
- 自动回滚机制
```

## 🔧 配置要求

### GitHub Secrets 配置

在 GitHub 仓库设置中添加以下 Secrets：

```bash
# 服务器配置
DEV_SERVER_HOST=your-dev-server.com      # 开发服务器地址
PROD_SERVER_HOST=your-prod-server.com    # 生产服务器地址
SERVER_USERNAME=deploy                    # 服务器用户名
SERVER_SSH_KEY=-----BEGIN PRIVATE KEY----- # SSH私钥
SERVER_SSH_PORT=22                        # SSH端口（可选，默认22）

# 容器注册表（自动配置）
GITHUB_TOKEN=ghp_xxxxxxxxxxxx            # GitHub Token（自动生成）
```

### 服务器环境要求

```bash
# 服务器需要安装：
- Docker Engine
- curl
- 网络访问权限

# 用户权限：
- Docker 组成员
- sudo 权限（可选）
```

## 📁 项目结构

```
cicd-pre-project/
├── .github/
│   └── workflows/
│       ├── ci-cd.yml          # 主CI/CD流水线
│       └── deploy.yml         # 部署工作流
├── scripts/
│   └── deploy.sh              # 服务器部署脚本
├── tests/
│   ├── __init__.py
│   ├── test_books.py          # 单元测试
│   └── integration/
│       └── test_api_integration.py  # 集成测试
├── books2.py                  # 主应用文件
├── requirements.txt           # 生产依赖
├── requirements-dev-compatible.txt  # 开发依赖
├── Dockerfile                 # Docker构建文件
├── docker-compose.yml         # 本地开发配置
├── pytest.ini                # 测试配置
├── pyproject.toml            # 项目配置
└── CI-CD-GUIDE.md            # 本文档
```

## 🚦 触发条件

### 自动触发

```yaml
# CI/CD 流水线触发条件：
- push到 main 或 develop 分支
- 创建 Pull Request 到 main 或 develop 分支
- 发布 Release

# 部署触发条件：
- CI/CD 流水线成功完成后
- 根据分支自动选择环境
```

### 手动触发

```bash
# 在 GitHub Actions 页面手动触发
# 或使用 GitHub CLI
gh workflow run "CI/CD Pipeline"
```

## 📊 测试覆盖率

### 当前测试覆盖的功能

```python
✅ 获取所有书籍 (GET /books)
✅ 根据ID获取书籍 (GET /books/{id})
✅ 根据评分查询书籍 (GET /books/?book_rating=X)
✅ 根据发布日期查询书籍 (GET /books/publish/?published_date=X)
✅ 创建新书籍 (POST /create-book)
✅ 数据验证测试
✅ 错误处理测试
✅ 并发请求测试
```

### 添加新测试

```python
# 在 tests/ 目录下创建新的测试文件
# 文件名必须以 test_ 开头

# 单元测试示例
def test_new_feature():
    response = client.get("/new-endpoint")
    assert response.status_code == 200

# 集成测试示例  
def test_integration_workflow():
    # 测试完整的业务流程
    pass
```

## 🔍 代码质量标准

### Black 代码格式化

```bash
# 检查格式
black --check .

# 自动格式化
black .
```

### isort 导入排序

```bash
# 检查导入排序
isort --check-only .

# 自动排序
isort .
```

### flake8 代码规范

```bash
# 检查代码规范
flake8 .
```

### mypy 类型检查

```bash
# 类型检查
mypy books2.py
```

## 🛡️ 安全检查

### Bandit 安全扫描

```bash
# 运行安全扫描
bandit -r . --severity-level medium
```

### 依赖漏洞检查

```bash
# 检查依赖漏洞
pip-audit --desc
```

## 🐳 Docker 部署

### 本地构建测试

```bash
# 构建开发镜像
docker build --target development -t fastapi-books:dev .

# 构建生产镜像
docker build --target production -t fastapi-books:prod .

# 运行容器
docker run -p 8000:8000 fastapi-books:prod
```

### 服务器部署

```bash
# 在服务器上使用部署脚本
./scripts/deploy.sh deploy latest

# 查看状态
./scripts/deploy.sh status

# 查看日志
./scripts/deploy.sh logs

# 回滚
./scripts/deploy.sh rollback
```

## 📈 监控和日志

### 健康检查

```bash
# 容器健康检查端点
curl http://localhost:8000/books

# 检查容器健康状态
docker inspect --format='{{.State.Health.Status}}' container-name
```

### 日志查看

```bash
# 查看容器日志
docker logs fastapi-books

# 实时查看日志
docker logs -f fastapi-books
```

## 🔄 工作流程示例

### 功能开发流程

```bash
1. 创建功能分支
   git checkout develop
   git checkout -b feature/new-api

2. 开发功能并添加测试
   # 编写代码
   # 添加单元测试
   # 添加集成测试

3. 本地测试
   pytest tests/
   black --check .
   flake8 .

4. 提交代码
   git add .
   git commit -m "feat: add new API endpoint"
   git push origin feature/new-api

5. 创建 Pull Request
   # GitHub 自动运行 CI/CD 检查
   # 代码审查
   # 合并到 develop 分支

6. 自动部署到开发环境
   # CI/CD 自动触发
   # 部署到开发服务器
   # 健康检查验证
```

### 生产发布流程

```bash
1. 从 develop 创建 release 分支
   git checkout develop
   git checkout -b release/1.0.0

2. 发布准备
   # 更新版本号
   # 更新文档
   # 最终测试

3. 合并到 main 分支
   git checkout main
   git merge --no-ff release/1.0.0
   git tag v1.0.0

4. 自动部署到生产环境
   # CI/CD 自动触发
   # 部署到生产服务器
   # 健康检查验证
```

## 🚨 故障排除

### 常见问题

1. **测试失败**
   ```bash
   # 查看详细错误信息
   pytest -v --tb=long
   
   # 运行特定测试
   pytest tests/test_books.py::test_specific_function
   ```

2. **Docker构建失败**
   ```bash
   # 检查依赖冲突
   pip install -r requirements-dev-compatible.txt
   
   # 本地构建测试
   docker build --no-cache .
   ```

3. **部署失败**
   ```bash
   # 检查服务器连接
   ssh user@server
   
   # 检查Docker状态
   docker ps
   docker logs container-name
   
   # 手动回滚
   ./scripts/deploy.sh rollback
   ```

4. **安全检查失败**
   ```bash
   # 查看安全报告
   bandit -r . -f json
   
   # 更新依赖
   pip install --upgrade package-name
   ```

## 📚 参考资源

- [GitHub Actions 文档](https://docs.github.com/en/actions)
- [Docker 最佳实践](https://docs.docker.com/develop/dev-best-practices/)
- [FastAPI 测试指南](https://fastapi.tiangolo.com/tutorial/testing/)
- [pytest 文档](https://docs.pytest.org/)

## 🤝 贡献指南

1. Fork 项目
2. 创建功能分支
3. 添加测试
4. 确保所有检查通过
5. 提交 Pull Request

---

**注意**: 确保在生产环境中正确配置所有 Secrets 和环境变量！ 
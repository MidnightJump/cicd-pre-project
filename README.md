# FastAPI Books CI/CD Project

## 🚀 项目概述

这是一个完整的FastAPI应用CI/CD项目，展示了现代软件开发的最佳实践，包括自动化测试、代码质量检查、安全扫描、Docker容器化和自动部署。

## ✨ 功能特性

### 📚 应用功能
- **书籍管理API**: 完整的CRUD操作
- **数据验证**: 使用Pydantic进行数据验证
- **查询功能**: 支持按评分、发布日期查询
- **RESTful设计**: 符合REST API设计规范

### 🔄 CI/CD功能
- **✅ 单元测试** (Unit Tests)
- **✅ 集成测试** (Integration Tests)
- **✅ 代码风格检查** (Black, isort)
- **✅ 代码质量检查** (flake8, mypy)
- **✅ 安全检查** (Bandit, pip-audit)
- **✅ 容器安全扫描** (Trivy)
- **✅ 自动化部署** (Docker + SSH)
- **✅ 健康检查** (Health Checks)
- **✅ 自动回滚** (Rollback)

## 📋 API端点

| 方法 | 端点                                    | 描述                 |
| ---- | --------------------------------------- | -------------------- |
| GET  | `/books`                                | 获取所有书籍         |
| GET  | `/books/{book_id}`                      | 根据ID获取书籍       |
| GET  | `/books/?book_rating={rating}`          | 根据评分查询书籍     |
| GET  | `/books/publish/?published_date={year}` | 根据发布年份查询书籍 |
| POST | `/create-book`                          | 创建新书籍           |

## 🏗️ 项目结构

```
cicd-pre-project/
├── .github/workflows/          # GitHub Actions工作流
│   ├── ci-cd.yml              # 主CI/CD流水线
│   └── deploy.yml             # 部署工作流
├── scripts/                   # 部署脚本
│   └── deploy.sh              # 服务器部署脚本
├── tests/                     # 测试文件
│   ├── test_books.py          # 单元测试
│   └── integration/           # 集成测试
├── books2.py                  # 主应用文件
├── requirements.txt           # 生产依赖
├── requirements-dev-compatible.txt  # 开发依赖
├── Dockerfile                 # Docker构建文件
├── docker-compose.yml         # 本地开发配置
├── pytest.ini                # 测试配置
├── pyproject.toml            # 项目配置
└── 文档/                      # 完整文档
    ├── CI-CD-GUIDE.md         # CI/CD完整指南
    ├── SECRETS-SETUP.md       # GitHub Secrets配置
    ├── DEPLOYMENT.md          # 部署指南
    └── GIT-WORKFLOW.md        # Git工作流程
```

## 🚦 快速开始

### 1. 本地开发

```bash
# 克隆项目
git clone https://github.com/your-username/cicd-pre-project.git
cd cicd-pre-project

# 安装依赖
pip install -r requirements.txt
pip install -r requirements-dev-compatible.txt

# 运行应用
python books2.py

# 运行测试
pytest tests/ -v

# 代码质量检查
black --check .
flake8 .
bandit -r .
```

### 2. Docker运行

```bash
# 构建镜像
docker build -t fastapi-books .

# 运行容器
docker run -p 8000:8000 fastapi-books

# 使用docker-compose
docker-compose up
```

### 3. 本地CI/CD测试

```bash
# 运行本地CI/CD测试脚本
bash test-ci-cd.sh
```

## 🔧 CI/CD配置

### GitHub Actions工作流

#### 主CI/CD流水线 (`.github/workflows/ci-cd.yml`)
- **触发条件**: push到main/develop分支，PR创建
- **包含步骤**:
  1. 代码质量检查 (Black, isort, flake8, mypy)
  2. 安全检查 (Bandit, pip-audit)
  3. 单元测试 (多Python版本)
  4. 集成测试 (API端点测试)
  5. Docker构建和推送
  6. 容器安全扫描

#### 部署工作流 (`.github/workflows/deploy.yml`)
- **触发条件**: 主CI/CD流水线成功完成
- **部署环境**:
  - `develop` 分支 → 开发环境
  - `main` 分支 → 生产环境
- **包含功能**: SSH部署、健康检查、自动回滚

### 必需的GitHub Secrets

```bash
DEV_SERVER_HOST=your-dev-server.com      # 开发服务器
PROD_SERVER_HOST=your-prod-server.com    # 生产服务器
SERVER_USERNAME=deploy                    # SSH用户名
SERVER_SSH_KEY=-----BEGIN PRIVATE KEY----- # SSH私钥
SERVER_SSH_PORT=22                        # SSH端口（可选）
```

## 📊 测试覆盖率

当前测试覆盖的功能：
- ✅ 所有API端点测试
- ✅ 数据验证测试
- ✅ 错误处理测试
- ✅ 并发请求测试
- ✅ 完整工作流测试

目标覆盖率：**80%+**

## 🛡️ 安全特性

- **代码安全扫描**: Bandit静态分析
- **依赖漏洞检查**: pip-audit检查
- **容器安全扫描**: Trivy漏洞扫描
- **SSH密钥认证**: 安全的服务器访问
- **环境隔离**: 开发/生产环境分离

## 🐳 Docker部署

### 多阶段构建
- **Base**: 基础Python环境
- **Development**: 开发环境（包含开发工具）
- **Production**: 生产环境（精简镜像）

### 部署脚本功能
```bash
./scripts/deploy.sh deploy [tag]    # 部署指定版本
./scripts/deploy.sh status          # 查看状态
./scripts/deploy.sh logs            # 查看日志
./scripts/deploy.sh rollback        # 回滚
./scripts/deploy.sh cleanup         # 清理旧镜像
```

## 📈 监控和日志

### 健康检查
- **容器健康检查**: 内置健康检查机制
- **API健康检查**: 自动验证API响应
- **部署验证**: 部署后自动验证

### 日志管理
- **应用日志**: 结构化日志输出
- **部署日志**: 详细的部署过程记录
- **错误追踪**: 完整的错误堆栈信息

## 🔄 工作流程

### 开发流程
1. 创建功能分支 (`feature/new-feature`)
2. 开发功能并添加测试
3. 本地测试验证
4. 提交代码并创建PR
5. 自动CI/CD检查
6. 代码审查和合并
7. 自动部署到对应环境

### 发布流程
1. 从develop创建release分支
2. 发布准备和最终测试
3. 合并到main分支
4. 创建Git标签
5. 自动部署到生产环境

## 📚 文档

- **[CI/CD完整指南](CI-CD-GUIDE.md)**: 详细的CI/CD配置和使用指南
- **[GitHub Secrets配置](SECRETS-SETUP.md)**: 安全配置步骤
- **[部署指南](DEPLOYMENT.md)**: Docker部署完整指南
- **[Git工作流程](GIT-WORKFLOW.md)**: 分支管理和工作流程

## 🛠️ 开发工具

### 代码质量工具
- **Black**: 代码格式化
- **isort**: 导入排序
- **flake8**: 代码规范检查
- **mypy**: 类型检查

### 测试工具
- **pytest**: 测试框架
- **pytest-cov**: 覆盖率报告
- **httpx**: 异步HTTP客户端测试

### 安全工具
- **Bandit**: 安全漏洞扫描
- **pip-audit**: 依赖漏洞检查
- **Trivy**: 容器安全扫描

## 🤝 贡献指南

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

### 贡献要求
- ✅ 添加相应的测试
- ✅ 确保所有CI检查通过
- ✅ 遵循代码规范
- ✅ 更新相关文档

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 📞 支持

如果您遇到问题或有疑问：

1. 查看 [CI-CD-GUIDE.md](CI-CD-GUIDE.md) 获取详细指南
2. 检查 [Issues](https://github.com/your-username/cicd-pre-project/issues) 页面
3. 创建新的Issue描述问题

## 🎯 路线图

- [ ] 添加数据库支持
- [ ] 实现用户认证
- [ ] 添加API文档 (Swagger)
- [ ] 集成监控系统 (Prometheus)
- [ ] 添加缓存层 (Redis)
- [ ] 实现微服务架构

---

**⭐ 如果这个项目对您有帮助，请给它一个星标！**
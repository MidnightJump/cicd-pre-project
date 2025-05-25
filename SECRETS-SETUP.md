# GitHub Secrets 配置指南

## 🔐 概述

为了让CI/CD流水线正常工作，您需要在GitHub仓库中配置以下Secrets。这些Secrets用于安全地存储敏感信息，如服务器凭据和API密钥。

## 📋 必需的Secrets

### 1. 服务器配置

#### `DEV_SERVER_HOST`
- **描述**: 开发服务器的IP地址或域名
- **示例**: `192.168.1.100` 或 `dev.example.com`
- **用途**: 部署到开发环境

#### `PROD_SERVER_HOST`
- **描述**: 生产服务器的IP地址或域名
- **示例**: `192.168.1.200` 或 `api.example.com`
- **用途**: 部署到生产环境

#### `SERVER_USERNAME`
- **描述**: 服务器SSH登录用户名
- **示例**: `deploy` 或 `ubuntu`
- **用途**: SSH连接到服务器

#### `SERVER_SSH_KEY`
- **描述**: SSH私钥内容
- **格式**: 完整的私钥文件内容
- **用途**: SSH身份验证

#### `SERVER_SSH_PORT` (可选)
- **描述**: SSH端口号
- **默认值**: `22`
- **示例**: `2222`
- **用途**: 自定义SSH端口

## 🔧 配置步骤

### 步骤1: 生成SSH密钥对

在您的本地机器上生成SSH密钥对：

```bash
# 生成新的SSH密钥对
ssh-keygen -t rsa -b 4096 -C "github-actions@yourdomain.com" -f ~/.ssh/github_actions

# 查看公钥内容
cat ~/.ssh/github_actions.pub

# 查看私钥内容（用于GitHub Secret）
cat ~/.ssh/github_actions
```

### 步骤2: 配置服务器

将公钥添加到服务器的authorized_keys：

```bash
# 在服务器上执行
mkdir -p ~/.ssh
echo "你的公钥内容" >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### 步骤3: 测试SSH连接

```bash
# 测试SSH连接
ssh -i ~/.ssh/github_actions username@server_ip

# 测试Docker权限
docker ps
```

### 步骤4: 在GitHub中添加Secrets

1. 打开您的GitHub仓库
2. 点击 **Settings** 标签
3. 在左侧菜单中选择 **Secrets and variables** → **Actions**
4. 点击 **New repository secret**
5. 添加以下Secrets：

#### 添加 `DEV_SERVER_HOST`
- **Name**: `DEV_SERVER_HOST`
- **Secret**: 您的开发服务器地址

#### 添加 `PROD_SERVER_HOST`
- **Name**: `PROD_SERVER_HOST`
- **Secret**: 您的生产服务器地址

#### 添加 `SERVER_USERNAME`
- **Name**: `SERVER_USERNAME`
- **Secret**: SSH用户名

#### 添加 `SERVER_SSH_KEY`
- **Name**: `SERVER_SSH_KEY`
- **Secret**: 完整的SSH私钥内容，包括：
```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAFwAAAAdzc2gtcn
...（私钥内容）...
-----END OPENSSH PRIVATE KEY-----
```

#### 添加 `SERVER_SSH_PORT` (如果需要)
- **Name**: `SERVER_SSH_PORT`
- **Secret**: SSH端口号（如：`2222`）

## 🖥️ 服务器环境准备

### 安装Docker

```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 将用户添加到docker组
sudo usermod -aG docker $USER

# 重新登录或执行
newgrp docker

# 验证安装
docker --version
```

### 配置防火墙

```bash
# 开放应用端口
sudo ufw allow 8000/tcp

# 如果使用自定义SSH端口
sudo ufw allow 2222/tcp
```

### 创建部署目录

```bash
# 创建部署目录
mkdir -p ~/deployments/fastapi-books
cd ~/deployments/fastapi-books
```

## 🔍 验证配置

### 本地验证

```bash
# 测试SSH连接
ssh -i ~/.ssh/github_actions username@server_ip "docker --version"

# 测试Docker权限
ssh -i ~/.ssh/github_actions username@server_ip "docker ps"
```

### GitHub Actions验证

1. 推送代码到 `develop` 或 `main` 分支
2. 查看 GitHub Actions 运行结果
3. 检查部署日志

## 🚨 安全注意事项

### SSH密钥安全
- ✅ 使用专用的SSH密钥对
- ✅ 定期轮换SSH密钥
- ✅ 限制SSH密钥权限
- ❌ 不要在代码中硬编码密钥

### 服务器安全
- ✅ 使用非root用户部署
- ✅ 配置防火墙规则
- ✅ 定期更新系统
- ✅ 监控登录日志

### GitHub Secrets安全
- ✅ 只添加必要的Secrets
- ✅ 定期审查Secrets使用
- ✅ 使用环境保护规则
- ❌ 不要在日志中输出Secrets

## 🔄 环境管理

### 开发环境
- 分支: `develop`
- 服务器: `DEV_SERVER_HOST`
- 端口: `8000`
- 自动部署: ✅

### 生产环境
- 分支: `main`
- 服务器: `PROD_SERVER_HOST`
- 端口: `8000`
- 自动部署: ✅
- 环境保护: 建议启用

## 📊 监控和日志

### 部署监控

```bash
# 查看容器状态
docker ps -f name=fastapi-books

# 查看容器日志
docker logs fastapi-books-production

# 查看资源使用
docker stats fastapi-books-production
```

### 健康检查

```bash
# API健康检查
curl http://your-server:8000/books

# 容器健康状态
docker inspect --format='{{.State.Health.Status}}' fastapi-books-production
```

## 🛠️ 故障排除

### 常见问题

1. **SSH连接失败**
   ```bash
   # 检查SSH密钥格式
   ssh-keygen -l -f ~/.ssh/github_actions
   
   # 测试连接
   ssh -v -i ~/.ssh/github_actions username@server
   ```

2. **Docker权限问题**
   ```bash
   # 检查用户组
   groups $USER
   
   # 重新添加到docker组
   sudo usermod -aG docker $USER
   ```

3. **端口访问问题**
   ```bash
   # 检查端口占用
   sudo netstat -tlnp | grep :8000
   
   # 检查防火墙
   sudo ufw status
   ```

4. **部署失败**
   ```bash
   # 查看GitHub Actions日志
   # 检查服务器日志
   journalctl -u docker
   ```

## 📞 获取帮助

如果遇到问题，请：

1. 检查GitHub Actions运行日志
2. 验证所有Secrets配置正确
3. 测试SSH连接和Docker权限
4. 查看服务器系统日志

---

**重要提醒**: 
- 🔐 保护好您的SSH私钥
- 🔄 定期轮换密钥
- 📊 监控部署状态
- 🚨 及时处理安全警告 
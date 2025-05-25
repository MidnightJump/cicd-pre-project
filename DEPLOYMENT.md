# FastAPI Books Management - Ubuntu Docker 部署指南

## 前置要求

确保您的 Ubuntu 系统已安装以下软件：

### 1. 安装 Docker

```bash
# 更新包管理器
sudo apt update

# 安装必要的包
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# 添加 Docker 官方 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 添加 Docker 仓库
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安装 Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io

# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 重新登录或运行
newgrp docker
```

### 2. 安装 Docker Compose

```bash
# 下载 Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# 添加执行权限
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装
docker-compose --version
```

## 部署方式

### 方式一：使用运行脚本（推荐）

```bash
# 给脚本添加执行权限
chmod +x run.sh

# 运行脚本
./run.sh
```

### 方式二：使用 Docker Compose

#### 开发模式（带热重载）

```bash
# 构建并启动开发环境
docker-compose up app

# 后台运行
docker-compose up -d app

# 查看日志
docker-compose logs -f app
```

#### 生产模式

```bash
# 构建并启动生产环境
docker-compose up app-prod

# 后台运行
docker-compose up -d app-prod

# 查看日志
docker-compose logs -f app-prod
```

### 方式三：直接使用 Docker

#### 构建镜像

```bash
# 构建开发镜像
docker build --target development -t fastapi-books:dev .

# 构建生产镜像
docker build --target production -t fastapi-books:prod .
```

#### 运行容器

```bash
# 运行开发容器
docker run -d -p 8000:8000 -v $(pwd):/app --name fastapi-books-dev fastapi-books:dev

# 运行生产容器
docker run -d -p 8000:8000 --name fastapi-books-prod fastapi-books:prod
```

## 访问应用

- **应用地址**: http://localhost:8000
- **API 文档**: http://localhost:8000/docs
- **ReDoc 文档**: http://localhost:8000/redoc

## 管理命令

### 查看运行状态

```bash
# 查看容器状态
docker ps

# 查看所有容器（包括停止的）
docker ps -a

# 使用 Docker Compose 查看状态
docker-compose ps
```

### 查看日志

```bash
# 查看容器日志
docker logs fastapi-books-prod

# 实时查看日志
docker logs -f fastapi-books-prod

# 使用 Docker Compose 查看日志
docker-compose logs -f app-prod
```

### 停止和清理

```bash
# 停止容器
docker stop fastapi-books-prod

# 停止并删除容器
docker rm -f fastapi-books-prod

# 使用 Docker Compose 停止
docker-compose down

# 停止并删除所有相关容器、网络、镜像
docker-compose down --rmi all -v
```

### 进入容器

```bash
# 进入运行中的容器
docker exec -it fastapi-books-prod /bin/bash

# 使用 Docker Compose 进入容器
docker-compose exec app-prod /bin/bash
```

## 测试 API

### 基本测试

```bash
# 测试健康检查
curl http://localhost:8000/books

# 获取特定书籍
curl http://localhost:8000/books/1

# 按评分查询
curl "http://localhost:8000/books/?book_rating=5"

# 按发布日期查询
curl "http://localhost:8000/books/publish/?published_date=2030"
```

### 创建新书籍

```bash
curl -X POST "http://localhost:8000/create-book" \
     -H "Content-Type: application/json" \
     -d '{
       "title": "新书籍",
       "author": "作者名",
       "description": "书籍描述",
       "rating": 4,
       "published_date": 2024
     }'
```

## 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 查看占用 8000 端口的进程
   sudo lsof -i :8000
   
   # 或者使用其他端口
   docker run -p 8001:8000 fastapi-books:prod
   ```

2. **Docker 权限问题**
   ```bash
   # 确保用户在 docker 组中
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. **镜像构建失败**
   ```bash
   # 清理 Docker 缓存
   docker system prune -a
   
   # 重新构建（不使用缓存）
   docker build --no-cache -t fastapi-books:prod .
   ```

4. **容器无法启动**
   ```bash
   # 查看详细错误信息
   docker logs fastapi-books-prod
   
   # 检查容器配置
   docker inspect fastapi-books-prod
   ```

## 性能优化

### 生产环境建议

1. **资源限制**
   ```bash
   docker run -d -p 8000:8000 \
     --memory="512m" \
     --cpus="0.5" \
     --name fastapi-books-prod \
     fastapi-books:prod
   ```

2. **健康检查**
   ```bash
   docker run -d -p 8000:8000 \
     --health-cmd="curl -f http://localhost:8000/books || exit 1" \
     --health-interval=30s \
     --health-timeout=10s \
     --health-retries=3 \
     --name fastapi-books-prod \
     fastapi-books:prod
   ```

3. **自动重启**
   ```bash
   docker run -d -p 8000:8000 \
     --restart=unless-stopped \
     --name fastapi-books-prod \
     fastapi-books:prod
   ``` 
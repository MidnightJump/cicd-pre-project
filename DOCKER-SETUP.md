# Ubuntu Docker 安装和换源完整指南

## 🚀 快速安装

### 方法一：使用自动安装脚本（推荐）

```bash
# 1. 下载并运行完整安装脚本
chmod +x ubuntu-docker-install.sh
./ubuntu-docker-install.sh
```

### 方法二：手动安装步骤

#### 1. 更新系统并安装依赖

```bash
# 更新包索引
sudo apt update

# 安装必要的依赖
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common
```

#### 2. 添加 Docker 官方 GPG 密钥

```bash
# 创建密钥目录
sudo mkdir -p /etc/apt/keyrings

# 下载并添加 GPG 密钥
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```

#### 3. 添加 Docker 仓库

```bash
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

#### 4. 安装 Docker

```bash
# 更新包索引
sudo apt update

# 安装 Docker Engine、CLI 和相关插件
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

#### 5. 配置用户权限

```bash
# 将当前用户添加到 docker 组
sudo usermod -aG docker $USER

# 启动 Docker 服务
sudo systemctl start docker
sudo systemctl enable docker

# 重新登录或运行以下命令使权限生效
newgrp docker
```

## 🔧 配置镜像加速器

### 方法一：使用配置脚本（推荐）

```bash
# 运行镜像源配置脚本
chmod +x docker-mirror-config.sh
./docker-mirror-config.sh
```

### 方法二：手动配置

#### 创建配置文件

```bash
sudo mkdir -p /etc/docker
```

#### 选择镜像源

**中科大镜像源（推荐）：**
```bash
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn"
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
```

**多镜像源配置（最佳）：**
```bash
cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://docker.mirrors.ustc.edu.cn",
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://ccr.ccs.tencentyun.com"
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF
```

#### 重启 Docker 服务

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

## ✅ 验证安装

### 检查 Docker 版本

```bash
docker --version
docker compose version
```

### 检查镜像源配置

```bash
docker info | grep -A 10 "Registry Mirrors"
```

### 测试拉取镜像

```bash
# 测试拉取官方镜像
docker pull hello-world
docker run hello-world

# 如果成功，您会看到 "Hello from Docker!" 的消息
```

## 🔥 常用镜像源地址

| 镜像源 | 地址                                 | 说明                 |
| ------ | ------------------------------------ | -------------------- |
| 中科大 | `https://docker.mirrors.ustc.edu.cn` | 速度快，稳定性好     |
| 网易   | `https://hub-mirror.c.163.com`       | 国内老牌镜像源       |
| 阿里云 | `https://mirror.ccs.tencentyun.com`  | 需要注册获取专属地址 |
| 腾讯云 | `https://mirror.ccs.tencentyun.com`  | 腾讯云提供           |
| 百度云 | `https://mirror.baidubce.com`        | 百度云提供           |

## 🐛 常见问题解决

### 1. 权限问题

```bash
# 如果遇到权限错误，运行：
sudo usermod -aG docker $USER
newgrp docker

# 或者重新登录系统
```

### 2. 服务启动失败

```bash
# 检查 Docker 服务状态
sudo systemctl status docker

# 重启 Docker 服务
sudo systemctl restart docker

# 查看详细日志
sudo journalctl -u docker.service
```

### 3. 镜像拉取缓慢

```bash
# 重新配置镜像源
./docker-mirror-config.sh

# 或者测试不同的镜像源
```

### 4. 配置文件错误

```bash
# 检查配置文件语法
sudo docker info

# 如果有错误，重新生成配置文件
sudo rm /etc/docker/daemon.json
./docker-mirror-config.sh
```

## 📋 快速命令参考

```bash
# 安装 Docker
./ubuntu-docker-install.sh

# 配置镜像源
./docker-mirror-config.sh

# 测试安装
docker run hello-world

# 查看 Docker 信息
docker info

# 查看镜像列表
docker images

# 查看运行中的容器
docker ps

# 停止所有容器
docker stop $(docker ps -q)

# 清理未使用的镜像
docker system prune -a
```

## 🎯 使用建议

1. **推荐使用多镜像源配置**，可以提高拉取成功率
2. **定期更新 Docker** 到最新版本
3. **配置日志轮转**，避免日志文件过大
4. **使用非 root 用户** 运行 Docker 命令
5. **定期清理** 不需要的镜像和容器

## 🔗 相关链接

- [Docker 官方文档](https://docs.docker.com/)
- [Docker Hub](https://hub.docker.com/)
- [Docker Compose 文档](https://docs.docker.com/compose/)

---

完成安装后，您就可以开始使用 Docker 构建和运行容器化应用了！ 
#!/bin/bash

# Docker 镜像加速器配置脚本
# 适用于中国大陆用户

set -e

echo "🐳 配置 Docker 镜像加速器..."

# 创建 Docker 配置目录
sudo mkdir -p /etc/docker

# 配置镜像加速器
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
  }
}
EOF

echo "✅ Docker 配置文件已创建"

# 重启 Docker 服务
echo "🔄 重启 Docker 服务..."
sudo systemctl daemon-reload
sudo systemctl restart docker

# 验证配置
echo "🔍 验证 Docker 配置..."
docker info | grep -A 10 "Registry Mirrors"

echo "✅ Docker 镜像加速器配置完成！"
echo ""
echo "现在可以尝试构建镜像："
echo "docker build -t fastapi-books:latest ." 
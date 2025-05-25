#!/bin/bash

# Ubuntu Docker 安装和配置脚本
# 支持 Ubuntu 18.04/20.04/22.04

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}Ubuntu Docker 安装和配置脚本${NC}"
echo "========================================"

# 检查是否为 root 用户
if [[ $EUID -eq 0 ]]; then
   echo -e "${RED}请不要使用 root 用户运行此脚本${NC}"
   exit 1
fi

# 检查 Ubuntu 版本
echo -e "${BLUE}检查系统版本...${NC}"
. /etc/lsb-release
echo "当前系统: $DISTRIB_DESCRIPTION"

# 1. 卸载旧版本 Docker
echo -e "${YELLOW}步骤 1: 卸载旧版本 Docker...${NC}"
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

# 2. 更新系统包
echo -e "${YELLOW}步骤 2: 更新系统包...${NC}"
sudo apt-get update

# 3. 安装必要的依赖包
echo -e "${YELLOW}步骤 3: 安装依赖包...${NC}"
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common

# 4. 添加 Docker 官方 GPG 密钥
echo -e "${YELLOW}步骤 4: 添加 Docker GPG 密钥...${NC}"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# 5. 添加 Docker 官方 APT 仓库
echo -e "${YELLOW}步骤 5: 添加 Docker 仓库...${NC}"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 6. 更新包索引
echo -e "${YELLOW}步骤 6: 更新包索引...${NC}"
sudo apt-get update

# 7. 安装 Docker Engine
echo -e "${YELLOW}步骤 7: 安装 Docker Engine...${NC}"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 8. 将当前用户添加到 docker 组
echo -e "${YELLOW}步骤 8: 配置用户权限...${NC}"
sudo usermod -aG docker $USER

# 9. 启动并设置开机自启
echo -e "${YELLOW}步骤 9: 启动 Docker 服务...${NC}"
sudo systemctl start docker
sudo systemctl enable docker

# 10. 配置镜像加速器
echo -e "${YELLOW}步骤 10: 配置镜像加速器...${NC}"
sudo mkdir -p /etc/docker

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

# 11. 重新加载配置并重启 Docker
echo -e "${YELLOW}步骤 11: 重启 Docker 服务...${NC}"
sudo systemctl daemon-reload
sudo systemctl restart docker

# 12. 验证安装
echo -e "${YELLOW}步骤 12: 验证安装...${NC}"
echo "Docker 版本信息:"
docker --version
docker compose version

echo ""
echo "Docker 配置信息:"
docker info | grep -A 10 "Registry Mirrors" || echo "镜像加速器配置未生效，请重新登录"

echo ""
echo -e "${GREEN}✅ Docker 安装完成！${NC}"
echo -e "${YELLOW}重要提示:${NC}"
echo "1. 请重新登录或运行 'newgrp docker' 使用户组权限生效"
echo "2. 测试运行: docker run hello-world"
echo "3. 如果遇到权限问题，请注销并重新登录"

# 测试 Docker 是否正常工作
echo ""
read -p "是否立即测试 Docker 安装？(y/n): " test_docker
if [[ $test_docker == "y" || $test_docker == "Y" ]]; then
    echo -e "${BLUE}测试 Docker...${NC}"
    if docker run hello-world; then
        echo -e "${GREEN}✅ Docker 测试成功！${NC}"
    else
        echo -e "${RED}❌ Docker 测试失败，请重新登录后再试${NC}"
        echo "运行命令: newgrp docker"
    fi
fi 
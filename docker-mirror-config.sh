#!/bin/bash

# Docker 镜像源配置脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}Docker 镜像源配置脚本${NC}"
echo "============================"

# 检查 Docker 是否已安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装，请先安装 Docker${NC}"
    echo "运行安装脚本: ./ubuntu-docker-install.sh"
    exit 1
fi

echo -e "${BLUE}选择镜像源:${NC}"
echo "1) 中科大镜像源 (推荐)"
echo "2) 阿里云镜像源"
echo "3) 腾讯云镜像源"
echo "4) 网易镜像源"
echo "5) 百度镜像源"
echo "6) 配置多个镜像源 (推荐)"
echo "7) 恢复默认配置"
read -p "请选择 (1-7): " choice

# 备份原有配置
if [ -f /etc/docker/daemon.json ]; then
    echo -e "${YELLOW}备份原有配置...${NC}"
    sudo cp /etc/docker/daemon.json /etc/docker/daemon.json.backup.$(date +%Y%m%d_%H%M%S)
fi

# 创建配置目录
sudo mkdir -p /etc/docker

case $choice in
    1)
        echo -e "${YELLOW}配置中科大镜像源...${NC}"
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
        ;;
    2)
        echo -e "${YELLOW}配置阿里云镜像源...${NC}"
        echo -e "${BLUE}提示: 您可以登录阿里云容器镜像服务获取专属加速地址${NC}"
        cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com"
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
        ;;
    3)
        echo -e "${YELLOW}配置腾讯云镜像源...${NC}"
        cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://mirror.ccs.tencentyun.com"
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
        ;;
    4)
        echo -e "${YELLOW}配置网易镜像源...${NC}"
        cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com"
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
        ;;
    5)
        echo -e "${YELLOW}配置百度镜像源...${NC}"
        cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "registry-mirrors": [
    "https://mirror.baidubce.com"
  ],
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
        ;;
    6)
        echo -e "${YELLOW}配置多个镜像源...${NC}"
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
        ;;
    7)
        echo -e "${YELLOW}恢复默认配置...${NC}"
        cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "dns": ["8.8.8.8", "8.8.4.4"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m",
    "max-file": "3"
  }
}
EOF
        ;;
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac

# 重启 Docker 服务
echo -e "${YELLOW}重启 Docker 服务...${NC}"
sudo systemctl daemon-reload
sudo systemctl restart docker

# 验证配置
echo -e "${YELLOW}验证配置...${NC}"
echo "当前 Docker 配置:"
docker info | grep -A 10 "Registry Mirrors" || echo "未找到镜像源配置"

echo ""
echo -e "${GREEN}✅ Docker 镜像源配置完成！${NC}"
echo -e "${BLUE}测试命令:${NC}"
echo "docker pull hello-world" 
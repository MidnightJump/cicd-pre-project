#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}FastAPI Books Management - Docker 部署脚本${NC}"
echo "=========================================="

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装，请先安装 Docker${NC}"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}错误: Docker Compose 未安装，请先安装 Docker Compose${NC}"
    exit 1
fi

# 选择运行模式
echo "请选择运行模式:"
echo "1) 开发模式 (带热重载)"
echo "2) 生产模式"
echo "3) 构建镜像"
echo "4) 构建镜像 (使用国内镜像源)"
echo "5) 配置 Docker 镜像加速器"
echo "6) 停止所有容器"
echo "7) 检查网络连接"
read -p "请输入选择 (1-7): " choice

case $choice in
    1)
        echo -e "${YELLOW}启动开发模式...${NC}"
        docker-compose up app
        ;;
    2)
        echo -e "${YELLOW}启动生产模式...${NC}"
        docker-compose up app-prod
        ;;
    3)
        echo -e "${YELLOW}构建 Docker 镜像...${NC}"
        docker build -t fastapi-books:latest .
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}镜像构建完成！${NC}"
            echo "运行命令: docker run -p 8000:8000 fastapi-books:latest"
        else
            echo -e "${RED}镜像构建失败！请尝试选项 4 使用国内镜像源${NC}"
        fi
        ;;
    4)
        echo -e "${YELLOW}使用国内镜像源构建 Docker 镜像...${NC}"
        docker build -f Dockerfile.cn -t fastapi-books:latest .
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}镜像构建完成！${NC}"
            echo "运行命令: docker run -p 8000:8000 fastapi-books:latest"
        else
            echo -e "${RED}镜像构建失败！请检查网络连接或选择选项 5 配置镜像加速器${NC}"
        fi
        ;;
    5)
        echo -e "${YELLOW}配置 Docker 镜像加速器...${NC}"
        chmod +x setup-docker.sh
        ./setup-docker.sh
        ;;
    6)
        echo -e "${YELLOW}停止所有容器...${NC}"
        docker-compose down
        ;;
    7)
        echo -e "${BLUE}检查网络连接...${NC}"
        echo "测试连接到 Docker Hub:"
        curl -I https://registry-1.docker.io/ --connect-timeout 10 || echo -e "${RED}无法连接到 Docker Hub${NC}"
        echo ""
        echo "测试连接到阿里云镜像:"
        curl -I https://registry.cn-hangzhou.aliyuncs.com/ --connect-timeout 10 || echo -e "${RED}无法连接到阿里云镜像${NC}"
        echo ""
        echo "当前 Docker 配置:"
        docker info | grep -A 5 "Registry Mirrors" || echo "未配置镜像加速器"
        ;;
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac 
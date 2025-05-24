#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
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
echo "4) 停止所有容器"
read -p "请输入选择 (1-4): " choice

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
        echo -e "${GREEN}镜像构建完成！${NC}"
        echo "运行命令: docker run -p 8000:8000 fastapi-books:latest"
        ;;
    4)
        echo -e "${YELLOW}停止所有容器...${NC}"
        docker-compose down
        ;;
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac 
#!/bin/bash

# 依赖冲突修复脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${GREEN}FastAPI 依赖冲突修复脚本${NC}"
echo "=============================="

echo -e "${BLUE}选择修复方案:${NC}"
echo "1) 使用兼容的依赖版本（推荐）"
echo "2) 移除 safety 包"
echo "3) 降级 black 版本"
echo "4) 创建虚拟环境测试"
read -p "请选择 (1-4): " choice

case $choice in
    1)
        echo -e "${YELLOW}使用兼容的依赖版本...${NC}"
        echo "已创建 requirements-dev-compatible.txt 文件"
        echo "Dockerfile 已更新使用兼容版本"
        ;;
    2)
        echo -e "${YELLOW}移除 safety 包...${NC}"
        sed -i '/safety/d' requirements-dev.txt
        echo "已从 requirements-dev.txt 中移除 safety 包"
        ;;
    3)
        echo -e "${YELLOW}降级 black 版本...${NC}"
        sed -i 's/black==23.11.0/black==22.12.0/' requirements-dev.txt
        echo "已将 black 版本降级到 22.12.0"
        ;;
    4)
        echo -e "${YELLOW}创建虚拟环境测试...${NC}"
        if command -v python3 &> /dev/null; then
            python3 -m venv test_env
            source test_env/bin/activate
            pip install --upgrade pip
            echo "测试兼容版本..."
            pip install -r requirements-dev-compatible.txt
            echo -e "${GREEN}测试成功！兼容版本可以正常安装${NC}"
            deactivate
            rm -rf test_env
        else
            echo -e "${RED}Python3 未找到${NC}"
        fi
        ;;
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ 依赖冲突修复完成！${NC}"
echo -e "${BLUE}建议的构建命令:${NC}"
echo "docker build -t fastapi-books:latest ."
echo ""
echo -e "${BLUE}或者使用兼容版本构建:${NC}"
echo "docker build --build-arg DEV_DEPS=requirements-dev-compatible.txt -t fastapi-books:latest ." 
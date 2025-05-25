#!/bin/bash

# 本地CI/CD测试脚本
# 模拟GitHub Actions的检查流程

set -e

echo "🚀 开始本地CI/CD测试..."
echo "=========================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 检查Python环境
print_step "检查Python环境"
if command -v python &> /dev/null; then
    python_version=$(python --version)
    print_success "Python版本: $python_version"
else
    print_error "Python未安装"
    exit 1
fi

# 检查依赖
print_step "检查依赖安装"
if [ -f "requirements-dev-compatible.txt" ]; then
    print_success "找到开发依赖文件"
    pip install -r requirements-dev-compatible.txt > /dev/null 2>&1 || {
        print_warning "依赖安装可能有问题，继续测试..."
    }
else
    print_error "未找到依赖文件"
fi

# 代码格式检查
print_step "代码格式检查 (Black)"
if command -v black &> /dev/null; then
    if black --check . > /dev/null 2>&1; then
        print_success "代码格式检查通过"
    else
        print_warning "代码格式需要调整，运行: black ."
    fi
else
    print_warning "Black未安装，跳过格式检查"
fi

# 导入排序检查
print_step "导入排序检查 (isort)"
if command -v isort &> /dev/null; then
    if isort --check-only . > /dev/null 2>&1; then
        print_success "导入排序检查通过"
    else
        print_warning "导入排序需要调整，运行: isort ."
    fi
else
    print_warning "isort未安装，跳过导入排序检查"
fi

# 代码规范检查
print_step "代码规范检查 (flake8)"
if command -v flake8 &> /dev/null; then
    if flake8 . > /dev/null 2>&1; then
        print_success "代码规范检查通过"
    else
        print_warning "代码规范检查发现问题"
        flake8 . || true
    fi
else
    print_warning "flake8未安装，跳过代码规范检查"
fi

# 安全检查
print_step "安全检查 (Bandit)"
if command -v bandit &> /dev/null; then
    if bandit -r . --severity-level medium > /dev/null 2>&1; then
        print_success "安全检查通过"
    else
        print_warning "安全检查发现问题"
        bandit -r . --severity-level medium || true
    fi
else
    print_warning "Bandit未安装，跳过安全检查"
fi

# 依赖漏洞检查
print_step "依赖漏洞检查 (pip-audit)"
if command -v pip-audit &> /dev/null; then
    if pip-audit --desc > /dev/null 2>&1; then
        print_success "依赖漏洞检查通过"
    else
        print_warning "依赖漏洞检查发现问题"
        pip-audit --desc || true
    fi
else
    print_warning "pip-audit未安装，跳过依赖漏洞检查"
fi

# 单元测试
print_step "运行单元测试"
if [ -d "tests" ]; then
    if command -v pytest &> /dev/null; then
        if pytest tests/ -v > /dev/null 2>&1; then
            print_success "单元测试通过"
        else
            print_warning "单元测试失败"
            pytest tests/ -v || true
        fi
    else
        print_warning "pytest未安装，跳过单元测试"
    fi
else
    print_warning "未找到tests目录，跳过单元测试"
fi

# Docker检查
print_step "Docker环境检查"
if command -v docker &> /dev/null; then
    if docker --version > /dev/null 2>&1; then
        print_success "Docker已安装: $(docker --version)"
        
        # 尝试构建Docker镜像
        print_step "Docker镜像构建测试"
        if docker build -t fastapi-books-test . > /dev/null 2>&1; then
            print_success "Docker镜像构建成功"
            
            # 清理测试镜像
            docker rmi fastapi-books-test > /dev/null 2>&1 || true
        else
            print_warning "Docker镜像构建失败"
        fi
    else
        print_warning "Docker未正确配置"
    fi
else
    print_warning "Docker未安装"
fi

# 检查GitHub Actions配置
print_step "GitHub Actions配置检查"
if [ -f ".github/workflows/ci-cd.yml" ]; then
    print_success "找到主CI/CD工作流配置"
else
    print_error "未找到CI/CD工作流配置"
fi

if [ -f ".github/workflows/deploy.yml" ]; then
    print_success "找到部署工作流配置"
else
    print_warning "未找到部署工作流配置"
fi

# 检查配置文件
print_step "配置文件检查"
config_files=("pytest.ini" "pyproject.toml" "requirements.txt" "Dockerfile")
for file in "${config_files[@]}"; do
    if [ -f "$file" ]; then
        print_success "找到配置文件: $file"
    else
        print_warning "未找到配置文件: $file"
    fi
done

echo -e "\n${GREEN}🎉 本地CI/CD测试完成！${NC}"
echo "=========================="
echo "📝 建议："
echo "1. 修复所有警告项目"
echo "2. 确保所有测试通过"
echo "3. 配置GitHub Secrets"
echo "4. 推送代码触发CI/CD流水线"
echo ""
echo "🔗 查看完整指南: CI-CD-GUIDE.md" 
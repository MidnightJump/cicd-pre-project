#!/bin/bash

# 自动修复常见CI/CD问题脚本
# 使用方法: ./fix-ci-issues.sh

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_step() {
    echo -e "\n${BLUE}🔧 $1${NC}"
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

echo -e "${GREEN}🚀 自动修复CI/CD问题...${NC}"
echo "================================"

# 检查当前分支
current_branch=$(git branch --show-current)
if [[ "$current_branch" == "main" || "$current_branch" == "develop" ]]; then
    print_error "不能在 $current_branch 分支上直接修复问题！"
    echo "请先创建 hotfix 分支："
    echo "  git checkout -b hotfix/fix-ci-$(date +%Y%m%d%H%M)"
    exit 1
fi

print_success "当前分支: $current_branch"

# 1. 修复代码格式
print_step "修复代码格式问题"
if command -v black &> /dev/null; then
    black .
    print_success "Black代码格式化完成"
else
    print_warning "Black未安装，跳过代码格式化"
fi

if command -v isort &> /dev/null; then
    isort .
    print_success "导入排序完成"
else
    print_warning "isort未安装，跳过导入排序"
fi

# 2. 检查代码规范
print_step "检查代码规范"
if command -v flake8 &> /dev/null; then
    if flake8 . > /dev/null 2>&1; then
        print_success "代码规范检查通过"
    else
        print_warning "代码规范检查发现问题，请手动修复："
        flake8 . || true
    fi
else
    print_warning "flake8未安装，跳过代码规范检查"
fi

# 3. 类型检查
print_step "类型检查"
if command -v mypy &> /dev/null; then
    if mypy books2.py --ignore-missing-imports > /dev/null 2>&1; then
        print_success "类型检查通过"
    else
        print_warning "类型检查发现问题，请手动修复："
        mypy books2.py --ignore-missing-imports || true
    fi
else
    print_warning "mypy未安装，跳过类型检查"
fi

# 4. 修复测试问题
print_step "修复测试问题"
if [ -f "fix-test-issues.sh" ]; then
    print_warning "运行测试修复脚本..."
    bash fix-test-issues.sh > /dev/null 2>&1 || true
fi

# 5. 运行测试
print_step "运行测试"
if command -v pytest &> /dev/null; then
    if [ -d "tests" ]; then
        if pytest tests/ -v > /dev/null 2>&1; then
            print_success "所有测试通过"
        else
            print_warning "测试失败，请检查并修复："
            pytest tests/ -v || true
        fi
    else
        print_warning "未找到tests目录，运行测试修复脚本"
        if [ -f "fix-test-issues.sh" ]; then
            bash fix-test-issues.sh
        fi
    fi
else
    print_warning "pytest未安装，跳过测试"
fi

# 6. 安全检查
print_step "安全检查"
if command -v bandit &> /dev/null; then
    if bandit -r . --severity-level medium > /dev/null 2>&1; then
        print_success "安全检查通过"
    else
        print_warning "安全检查发现问题，请检查："
        bandit -r . --severity-level medium || true
    fi
else
    print_warning "bandit未安装，跳过安全检查"
fi

# 7. 依赖漏洞检查
print_step "依赖漏洞检查"
if command -v pip-audit &> /dev/null; then
    if pip-audit --desc > /dev/null 2>&1; then
        print_success "依赖漏洞检查通过"
    else
        print_warning "发现依赖漏洞，尝试自动修复..."
        pip-audit --fix || true
    fi
else
    print_warning "pip-audit未安装，跳过依赖漏洞检查"
fi

# 8. Docker构建测试
print_step "Docker构建测试"
if command -v docker &> /dev/null; then
    if docker build -t fastapi-books-test . > /dev/null 2>&1; then
        print_success "Docker镜像构建成功"
        # 清理测试镜像
        docker rmi fastapi-books-test > /dev/null 2>&1 || true
    else
        print_warning "Docker镜像构建失败，请检查Dockerfile"
    fi
else
    print_warning "Docker未安装，跳过Docker构建测试"
fi

# 9. 检查是否有更改需要提交
print_step "检查文件更改"
if git diff --quiet && git diff --staged --quiet; then
    print_success "没有文件更改，所有问题已修复"
else
    print_warning "发现文件更改，请审查后提交："
    echo ""
    git status
    echo ""
    echo "建议的提交命令："
    echo "  git add ."
    echo "  git commit -m \"hotfix: fix CI/CD issues"
    echo ""
    echo "  - Fix code formatting with black and isort"
    echo "  - Resolve linting issues"
    echo "  - Fix security warnings"
    echo "  - Update dependencies\""
    echo ""
    echo "  git push origin $current_branch"
fi

echo ""
echo -e "${GREEN}🎉 自动修复完成！${NC}"
echo "================================"
echo "📝 下一步："
echo "1. 审查所有更改"
echo "2. 提交更改到当前分支"
echo "3. 创建PR到develop分支"
echo "4. 等待CI/CD检查通过"
echo ""
echo "🔗 查看问题处理指南: PROBLEM-HANDLING.md" 
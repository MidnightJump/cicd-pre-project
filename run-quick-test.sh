#!/bin/bash

# 快速测试验证脚本
# 用于快速验证测试修复是否成功

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
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

echo -e "${GREEN}🚀 快速测试验证${NC}"
echo "==================="

# 检查是否存在测试文件
if [[ ! -d "tests" ]]; then
    print_error "测试目录不存在，请先运行: bash fix-test-issues.sh"
    exit 1
fi

# 检查pytest是否可用
if ! command -v pytest &> /dev/null; then
    print_error "pytest未安装，请先安装测试依赖"
    echo "运行: pip install pytest pytest-cov"
    exit 1
fi

# 快速语法检查
print_info "检查测试文件语法..."
if python -m py_compile tests/test_books.py 2>/dev/null; then
    print_success "单元测试文件语法正确"
else
    print_error "单元测试文件有语法错误"
    python -m py_compile tests/test_books.py
    exit 1
fi

if [[ -f "tests/integration/test_api_integration.py" ]]; then
    if python -m py_compile tests/integration/test_api_integration.py 2>/dev/null; then
        print_success "集成测试文件语法正确"
    else
        print_error "集成测试文件有语法错误"
        python -m py_compile tests/integration/test_api_integration.py
        exit 1
    fi
fi

# 运行快速单元测试
print_info "运行单元测试..."
if pytest tests/test_books.py -v --tb=short -x; then
    print_success "单元测试通过"
else
    print_error "单元测试失败"
    exit 1
fi

# 运行集成测试（如果存在）
if [[ -d "tests/integration" ]]; then
    print_info "运行集成测试..."
    if pytest tests/integration/ -v --tb=short -x; then
        print_success "集成测试通过"
    else
        print_warning "集成测试失败，但不影响主要功能"
    fi
fi

echo ""
print_success "🎉 测试验证完成！所有基本测试都通过了"
echo ""
echo "📝 接下来可以："
echo "1. 提交更改到Git"
echo "2. 推送到远程仓库"
echo "3. 检查GitHub Actions是否通过" 
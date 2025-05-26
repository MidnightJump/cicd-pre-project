#!/bin/bash

# GitHub Actions版本更新脚本
# 自动检查和更新工作流中的action版本到最新稳定版本

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

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

echo -e "${GREEN}🔄 GitHub Actions版本更新检查${NC}"
echo "======================================="

# 检查工作流文件是否存在
if [[ ! -d ".github/workflows" ]]; then
    print_error "未找到 .github/workflows 目录"
    exit 1
fi

workflow_files=(.github/workflows/*.yml .github/workflows/*.yaml)
if [[ ! -f "${workflow_files[0]}" ]]; then
    print_error "未找到工作流文件"
    exit 1
fi

print_info "检查的工作流文件:"
for file in "${workflow_files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "  - $file"
    fi
done

echo ""

# 定义推荐的action版本
declare -A recommended_versions=(
    ["actions/checkout"]="v4"
    ["actions/setup-python"]="v5"
    ["actions/cache"]="v4" 
    ["actions/upload-artifact"]="v4"
    ["actions/download-artifact"]="v4"
    ["docker/setup-buildx-action"]="v4"
    ["docker/login-action"]="v4"
    ["docker/build-push-action"]="v6"
    ["docker/metadata-action"]="v5"
    ["github/codeql-action/upload-sarif"]="v3"
    ["codecov/codecov-action"]="v4"
    ["appleboy/ssh-action"]="v1.1.0"
    ["aquasecurity/trivy-action"]="master"
    ["anchore/sbom-action"]="v0"
)

# 检查每个工作流文件
for workflow_file in "${workflow_files[@]}"; do
    if [[ ! -f "$workflow_file" ]]; then
        continue
    fi
    
    print_info "检查文件: $workflow_file"
    
    # 查找所有使用的actions
    while IFS= read -r line; do
        if [[ $line =~ uses:[[:space:]]*([^@]+)@([^[:space:]]+) ]]; then
            action_name="${BASH_REMATCH[1]}"
            current_version="${BASH_REMATCH[2]}"
            
            # 检查是否有推荐版本
            if [[ -n "${recommended_versions[$action_name]}" ]]; then
                recommended_version="${recommended_versions[$action_name]}"
                
                if [[ "$current_version" != "$recommended_version" ]]; then
                    print_warning "发现过时版本: $action_name@$current_version → $recommended_version"
                else
                    print_success "版本最新: $action_name@$current_version"
                fi
            else
                print_info "未知action: $action_name@$current_version"
            fi
        fi
    done < "$workflow_file"
    
    echo ""
done

# 提供更新建议
echo -e "${BLUE}📋 更新建议:${NC}"
echo "1. 手动更新过时的action版本"
echo "2. 或者使用以下命令自动更新:"
echo ""
echo "   # 更新所有actions/upload-artifact@v3 到 v4"
echo "   sed -i 's/actions\/upload-artifact@v3/actions\/upload-artifact@v4/g' .github/workflows/*.yml"
echo ""
echo "   # 更新所有actions/cache@v3 到 v4"  
echo "   sed -i 's/actions\/cache@v3/actions\/cache@v4/g' .github/workflows/*.yml"
echo ""
echo "   # 更新Docker相关actions"
echo "   sed -i 's/docker\/setup-buildx-action@v3/docker\/setup-buildx-action@v4/g' .github/workflows/*.yml"
echo "   sed -i 's/docker\/login-action@v3/docker\/login-action@v4/g' .github/workflows/*.yml"
echo "   sed -i 's/docker\/build-push-action@v5/docker\/build-push-action@v6/g' .github/workflows/*.yml"
echo ""

# 检查是否有常见的过时版本
echo -e "${BLUE}🔍 常见问题检查:${NC}"

# 检查是否使用了过时的Node.js版本
for workflow_file in "${workflow_files[@]}"; do
    if [[ -f "$workflow_file" ]] && grep -q "node-version.*16" "$workflow_file"; then
        print_warning "发现使用Node.js 16，建议升级到18或20"
    fi
done

# 检查是否使用了过时的Python版本设置
for workflow_file in "${workflow_files[@]}"; do
    if [[ -f "$workflow_file" ]] && grep -q "actions/setup-python@v4" "$workflow_file"; then
        print_warning "建议升级 actions/setup-python 到 v5"
    fi
done

# 检查是否使用了已弃用的set-output
for workflow_file in "${workflow_files[@]}"; do
    if [[ -f "$workflow_file" ]] && grep -q "set-output" "$workflow_file"; then
        print_error "发现使用已弃用的 set-output，请改用 \$GITHUB_OUTPUT"
    fi
done

echo ""
echo -e "${GREEN}✨ 检查完成！${NC}"
echo "======================================="
echo "📚 更多信息:"
echo "- GitHub Actions更新日志: https://github.blog/changelog/"
echo "- Actions市场: https://github.com/marketplace?type=actions"
echo "- 版本兼容性: https://docs.github.com/en/actions" 
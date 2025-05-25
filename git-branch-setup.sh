#!/bin/bash

# Git 分支管理脚本
# 实现标准的分支策略：main, develop, feature/*, hotfix/*, release/*

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${GREEN}Git 分支管理脚本${NC}"
echo "=================="

# 检查是否在git仓库中
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}错误: 当前目录不是Git仓库${NC}"
    exit 1
fi

# 显示当前分支状态
echo -e "${BLUE}当前分支状态:${NC}"
git branch -a

echo ""
echo -e "${BLUE}选择操作:${NC}"
echo "1) 初始化分支策略（创建develop分支）"
echo "2) 创建功能分支 (feature/*)"
echo "3) 创建热修复分支 (hotfix/*)"
echo "4) 创建发布分支 (release/*)"
echo "5) 合并功能分支到develop"
echo "6) 合并热修复分支"
echo "7) 合并发布分支"
echo "8) 查看分支状态"
echo "9) 删除已合并的分支"
read -p "请选择 (1-9): " choice

case $choice in
    1)
        echo -e "${YELLOW}初始化分支策略...${NC}"
        
        # 确保在main分支
        git checkout main
        git pull origin main 2>/dev/null || echo "警告: 无法从远程拉取main分支"
        
        # 创建develop分支
        if git show-ref --verify --quiet refs/heads/develop; then
            echo "develop分支已存在"
        else
            git checkout -b develop
            echo -e "${GREEN}✅ 创建develop分支成功${NC}"
        fi
        
        # 推送到远程
        git push -u origin develop 2>/dev/null || echo "警告: 无法推送到远程仓库"
        
        echo -e "${GREEN}✅ 分支策略初始化完成${NC}"
        ;;
        
    2)
        echo -e "${YELLOW}创建功能分支...${NC}"
        read -p "请输入功能名称（例如：user-auth）: " feature_name
        
        if [[ -z "$feature_name" ]]; then
            echo -e "${RED}错误: 功能名称不能为空${NC}"
            exit 1
        fi
        
        # 切换到develop分支并更新
        git checkout develop
        git pull origin develop 2>/dev/null || echo "警告: 无法从远程拉取develop分支"
        
        # 创建功能分支
        branch_name="feature/$feature_name"
        git checkout -b "$branch_name"
        git push -u origin "$branch_name" 2>/dev/null || echo "警告: 无法推送到远程仓库"
        
        echo -e "${GREEN}✅ 功能分支 '$branch_name' 创建成功${NC}"
        echo -e "${BLUE}提示: 开发完成后使用选项5合并到develop分支${NC}"
        ;;
        
    3)
        echo -e "${YELLOW}创建热修复分支...${NC}"
        read -p "请输入修复描述（例如：fix-login-bug）: " hotfix_name
        
        if [[ -z "$hotfix_name" ]]; then
            echo -e "${RED}错误: 修复描述不能为空${NC}"
            exit 1
        fi
        
        # 切换到main分支并更新
        git checkout main
        git pull origin main 2>/dev/null || echo "警告: 无法从远程拉取main分支"
        
        # 创建热修复分支
        branch_name="hotfix/$hotfix_name"
        git checkout -b "$branch_name"
        git push -u origin "$branch_name" 2>/dev/null || echo "警告: 无法推送到远程仓库"
        
        echo -e "${GREEN}✅ 热修复分支 '$branch_name' 创建成功${NC}"
        echo -e "${BLUE}提示: 修复完成后使用选项6合并到main和develop分支${NC}"
        ;;
        
    4)
        echo -e "${YELLOW}创建发布分支...${NC}"
        read -p "请输入版本号（例如：1.0.0）: " version
        
        if [[ -z "$version" ]]; then
            echo -e "${RED}错误: 版本号不能为空${NC}"
            exit 1
        fi
        
        # 切换到develop分支并更新
        git checkout develop
        git pull origin develop 2>/dev/null || echo "警告: 无法从远程拉取develop分支"
        
        # 创建发布分支
        branch_name="release/$version"
        git checkout -b "$branch_name"
        git push -u origin "$branch_name" 2>/dev/null || echo "警告: 无法推送到远程仓库"
        
        echo -e "${GREEN}✅ 发布分支 '$branch_name' 创建成功${NC}"
        echo -e "${BLUE}提示: 发布测试完成后使用选项7合并到main和develop分支${NC}"
        ;;
        
    5)
        echo -e "${YELLOW}合并功能分支到develop...${NC}"
        
        # 显示所有功能分支
        echo "现有的功能分支:"
        git branch | grep "feature/" || echo "没有功能分支"
        
        read -p "请输入要合并的功能分支名（不含feature/前缀）: " feature_name
        branch_name="feature/$feature_name"
        
        # 检查分支是否存在
        if ! git show-ref --verify --quiet refs/heads/"$branch_name"; then
            echo -e "${RED}错误: 分支 '$branch_name' 不存在${NC}"
            exit 1
        fi
        
        # 切换到develop分支并合并
        git checkout develop
        git pull origin develop 2>/dev/null || echo "警告: 无法从远程拉取"
        git merge --no-ff "$branch_name" -m "Merge $branch_name into develop"
        git push origin develop 2>/dev/null || echo "警告: 无法推送到远程仓库"
        
        echo -e "${GREEN}✅ 功能分支合并完成${NC}"
        read -p "是否删除本地功能分支? (y/n): " delete_branch
        if [[ $delete_branch == "y" || $delete_branch == "Y" ]]; then
            git branch -d "$branch_name"
            git push origin --delete "$branch_name" 2>/dev/null || echo "警告: 无法删除远程分支"
        fi
        ;;
        
    6)
        echo -e "${YELLOW}合并热修复分支...${NC}"
        
        # 显示所有热修复分支
        echo "现有的热修复分支:"
        git branch | grep "hotfix/" || echo "没有热修复分支"
        
        read -p "请输入要合并的热修复分支名（不含hotfix/前缀）: " hotfix_name
        branch_name="hotfix/$hotfix_name"
        
        # 检查分支是否存在
        if ! git show-ref --verify --quiet refs/heads/"$branch_name"; then
            echo -e "${RED}错误: 分支 '$branch_name' 不存在${NC}"
            exit 1
        fi
        
        # 合并到main分支
        git checkout main
        git pull origin main 2>/dev/null || echo "警告: 无法从远程拉取"
        git merge --no-ff "$branch_name" -m "Merge $branch_name into main"
        git push origin main 2>/dev/null || echo "警告: 无法推送到远程仓库"
        
        # 合并到develop分支
        git checkout develop
        git pull origin develop 2>/dev/null || echo "警告: 无法从远程拉取"
        git merge --no-ff "$branch_name" -m "Merge $branch_name into develop"
        git push origin develop 2>/dev/null || echo "警告: 无法推送到远程仓库"
        
        echo -e "${GREEN}✅ 热修复分支合并完成${NC}"
        read -p "是否删除本地热修复分支? (y/n): " delete_branch
        if [[ $delete_branch == "y" || $delete_branch == "Y" ]]; then
            git branch -d "$branch_name"
            git push origin --delete "$branch_name" 2>/dev/null || echo "警告: 无法删除远程分支"
        fi
        ;;
        
    7)
        echo -e "${YELLOW}合并发布分支...${NC}"
        
        # 显示所有发布分支
        echo "现有的发布分支:"
        git branch | grep "release/" || echo "没有发布分支"
        
        read -p "请输入要合并的发布分支版本号: " version
        branch_name="release/$version"
        
        # 检查分支是否存在
        if ! git show-ref --verify --quiet refs/heads/"$branch_name"; then
            echo -e "${RED}错误: 分支 '$branch_name' 不存在${NC}"
            exit 1
        fi
        
        # 合并到main分支并打标签
        git checkout main
        git pull origin main 2>/dev/null || echo "警告: 无法从远程拉取"
        git merge --no-ff "$branch_name" -m "Merge $branch_name into main"
        git tag -a "v$version" -m "Release version $version"
        git push origin main 2>/dev/null || echo "警告: 无法推送到远程仓库"
        git push origin "v$version" 2>/dev/null || echo "警告: 无法推送标签到远程仓库"
        
        # 合并到develop分支
        git checkout develop
        git pull origin develop 2>/dev/null || echo "警告: 无法从远程拉取"
        git merge --no-ff "$branch_name" -m "Merge $branch_name into develop"
        git push origin develop 2>/dev/null || echo "警告: 无法推送到远程仓库"
        
        echo -e "${GREEN}✅ 发布分支合并完成，版本标签 v$version 已创建${NC}"
        read -p "是否删除本地发布分支? (y/n): " delete_branch
        if [[ $delete_branch == "y" || $delete_branch == "Y" ]]; then
            git branch -d "$branch_name"
            git push origin --delete "$branch_name" 2>/dev/null || echo "警告: 无法删除远程分支"
        fi
        ;;
        
    8)
        echo -e "${YELLOW}分支状态概览...${NC}"
        echo ""
        echo -e "${BLUE}所有分支:${NC}"
        git branch -a
        echo ""
        echo -e "${BLUE}最近的标签:${NC}"
        git tag -l | tail -5 || echo "没有标签"
        echo ""
        echo -e "${BLUE}当前分支:${NC}"
        git branch --show-current
        ;;
        
    9)
        echo -e "${YELLOW}删除已合并的分支...${NC}"
        echo "已合并到develop的功能分支:"
        git branch --merged develop | grep "feature/" | head -10 || echo "没有已合并的功能分支"
        echo ""
        echo "已合并到main的热修复和发布分支:"
        git branch --merged main | grep -E "(hotfix/|release/)" | head -10 || echo "没有已合并的热修复或发布分支"
        echo ""
        read -p "是否删除所有已合并的feature分支? (y/n): " delete_features
        if [[ $delete_features == "y" || $delete_features == "Y" ]]; then
            git branch --merged develop | grep "feature/" | xargs -r git branch -d
            echo "已删除合并到develop的功能分支"
        fi
        ;;
        
    *)
        echo -e "${RED}无效选择${NC}"
        exit 1
        ;;
esac 
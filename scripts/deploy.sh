#!/bin/bash

# 服务器部署脚本
# 用于在服务器上部署Docker容器

set -e

# 配置变量
CONTAINER_NAME="fastapi-books"
IMAGE_NAME="ghcr.io/midnightjump/cicd-pre-project"
PORT="8000"
NETWORK_NAME="app-network"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 函数：打印带颜色的消息
print_message() {
    echo -e "${2}${1}${NC}"
}

# 函数：检查命令是否存在
check_command() {
    if ! command -v $1 &> /dev/null; then
        print_message "错误: $1 未安装" $RED
        exit 1
    fi
}

# 函数：创建网络（如果不存在）
create_network() {
    if ! docker network ls | grep -q $NETWORK_NAME; then
        print_message "创建Docker网络: $NETWORK_NAME" $YELLOW
        docker network create $NETWORK_NAME
    else
        print_message "Docker网络 $NETWORK_NAME 已存在" $BLUE
    fi
}

# 函数：停止并删除旧容器
cleanup_old_container() {
    if docker ps -a | grep -q $CONTAINER_NAME; then
        print_message "停止并删除旧容器: $CONTAINER_NAME" $YELLOW
        docker stop $CONTAINER_NAME || true
        docker rm $CONTAINER_NAME || true
    fi
}

# 函数：拉取最新镜像
pull_image() {
    local tag=${1:-latest}
    print_message "拉取镜像: $IMAGE_NAME:$tag" $YELLOW
    docker pull $IMAGE_NAME:$tag
}

# 函数：运行新容器
run_container() {
    local tag=${1:-latest}
    print_message "启动新容器: $CONTAINER_NAME" $YELLOW
    
    docker run -d \
        --name $CONTAINER_NAME \
        --network $NETWORK_NAME \
        -p $PORT:8000 \
        --restart unless-stopped \
        --health-cmd="curl -f http://localhost:8000/books || exit 1" \
        --health-interval=30s \
        --health-timeout=10s \
        --health-retries=3 \
        -e ENVIRONMENT=production \
        $IMAGE_NAME:$tag
}

# 函数：等待容器健康检查
wait_for_health() {
    print_message "等待容器健康检查..." $YELLOW
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null | grep -q "healthy"; then
            print_message "容器健康检查通过" $GREEN
            return 0
        fi
        
        print_message "等待健康检查... ($attempt/$max_attempts)" $BLUE
        sleep 10
        ((attempt++))
    done
    
    print_message "容器健康检查超时" $RED
    return 1
}

# 函数：验证部署
verify_deployment() {
    print_message "验证部署..." $YELLOW
    
    # 检查容器是否运行
    if ! docker ps | grep -q $CONTAINER_NAME; then
        print_message "容器未运行" $RED
        return 1
    fi
    
    # 检查API是否响应
    if curl -f http://localhost:$PORT/books > /dev/null 2>&1; then
        print_message "API响应正常" $GREEN
    else
        print_message "API响应异常" $RED
        return 1
    fi
    
    print_message "部署验证成功" $GREEN
}

# 函数：回滚到上一个版本
rollback() {
    print_message "开始回滚..." $YELLOW
    
    # 获取上一个镜像版本
    local previous_image=$(docker images $IMAGE_NAME --format "table {{.Tag}}" | grep -v TAG | head -2 | tail -1)
    
    if [ -z "$previous_image" ]; then
        print_message "没有找到上一个版本的镜像" $RED
        return 1
    fi
    
    print_message "回滚到版本: $previous_image" $YELLOW
    cleanup_old_container
    run_container $previous_image
    
    if wait_for_health && verify_deployment; then
        print_message "回滚成功" $GREEN
    else
        print_message "回滚失败" $RED
        return 1
    fi
}

# 函数：显示日志
show_logs() {
    print_message "显示容器日志:" $BLUE
    docker logs --tail 50 -f $CONTAINER_NAME
}

# 函数：显示状态
show_status() {
    print_message "容器状态:" $BLUE
    docker ps -f name=$CONTAINER_NAME
    echo ""
    print_message "容器健康状态:" $BLUE
    docker inspect --format='{{.State.Health.Status}}' $CONTAINER_NAME 2>/dev/null || echo "无健康检查信息"
    echo ""
    print_message "资源使用情况:" $BLUE
    docker stats --no-stream $CONTAINER_NAME 2>/dev/null || echo "无法获取资源信息"
}

# 主函数
main() {
    print_message "FastAPI Books 部署脚本" $GREEN
    print_message "======================" $GREEN
    
    # 检查必要的命令
    check_command docker
    check_command curl
    
    # 解析命令行参数
    case "${1:-deploy}" in
        deploy)
            local tag=${2:-latest}
            print_message "开始部署版本: $tag" $GREEN
            
            create_network
            cleanup_old_container
            pull_image $tag
            run_container $tag
            
            if wait_for_health && verify_deployment; then
                print_message "部署成功完成!" $GREEN
                show_status
            else
                print_message "部署失败，开始回滚..." $RED
                rollback
            fi
            ;;
        rollback)
            rollback
            ;;
        logs)
            show_logs
            ;;
        status)
            show_status
            ;;
        stop)
            print_message "停止容器..." $YELLOW
            docker stop $CONTAINER_NAME
            ;;
        start)
            print_message "启动容器..." $YELLOW
            docker start $CONTAINER_NAME
            ;;
        restart)
            print_message "重启容器..." $YELLOW
            docker restart $CONTAINER_NAME
            ;;
        cleanup)
            print_message "清理旧镜像..." $YELLOW
            docker image prune -f
            docker images $IMAGE_NAME --format "table {{.Repository}}:{{.Tag}}\t{{.CreatedAt}}" | tail -n +2 | head -n -3 | awk '{print $1}' | xargs -r docker rmi
            ;;
        *)
            echo "用法: $0 {deploy|rollback|logs|status|stop|start|restart|cleanup} [tag]"
            echo ""
            echo "命令说明:"
            echo "  deploy [tag]  - 部署指定版本（默认latest）"
            echo "  rollback      - 回滚到上一个版本"
            echo "  logs          - 查看容器日志"
            echo "  status        - 查看容器状态"
            echo "  stop          - 停止容器"
            echo "  start         - 启动容器"
            echo "  restart       - 重启容器"
            echo "  cleanup       - 清理旧镜像"
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@" 
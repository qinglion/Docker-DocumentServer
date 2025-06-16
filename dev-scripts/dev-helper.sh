#!/bin/bash

# ONLYOFFICE DocumentServer 开发辅助脚本
# 提供常用的开发操作命令

set -e

COMPOSE_FILE="docker-compose.dev.yml"
CONTAINER_NAME="onlyoffice-documentserver-dev"

# 显示帮助信息
show_help() {
    echo "🛠️  ONLYOFFICE DocumentServer 开发辅助工具"
    echo ""
    echo "用法: $0 [命令]"
    echo ""
    echo "可用命令:"
    echo "  start          启动开发环境"
    echo "  stop           停止开发环境"
    echo "  restart        重启开发环境"
    echo "  logs           查看日志"
    echo "  shell          进入容器shell"
    echo "  build          构建前端资源"
    echo "  sync           同步前端代码到容器"
    echo "  clean          清理开发环境"
    echo "  status         查看服务状态"
    echo "  db-shell       连接数据库"
    echo "  redis-cli      连接Redis"
    echo "  rabbitmq       打开RabbitMQ管理界面"
    echo "  tools          启动开发工具容器"
    echo "  help           显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start       # 启动开发环境"
    echo "  $0 logs -f     # 实时查看日志"
    echo "  $0 shell       # 进入主容器"
}

# 启动开发环境
start_dev() {
    echo "🚀 启动 ONLYOFFICE DocumentServer 开发环境..."
    docker-compose -f $COMPOSE_FILE up -d
    echo "✅ 开发环境已启动"
    echo "📍 访问地址: http://localhost:8080"
    echo "🗄️  数据库: localhost:5432 (用户: onlyoffice, 密码: onlyoffice)"
    echo "🐰 RabbitMQ管理: http://localhost:15672 (用户: guest, 密码: guest)"
    echo "📊 Redis: localhost:6379"
}

# 停止开发环境
stop_dev() {
    echo "🛑 停止 ONLYOFFICE DocumentServer 开发环境..."
    docker-compose -f $COMPOSE_FILE down
    echo "✅ 开发环境已停止"
}

# 重启开发环境
restart_dev() {
    echo "🔄 重启 ONLYOFFICE DocumentServer 开发环境..."
    docker-compose -f $COMPOSE_FILE restart
    echo "✅ 开发环境已重启"
}

# 查看日志
show_logs() {
    shift
    docker-compose -f $COMPOSE_FILE logs "$@" $CONTAINER_NAME
}

# 进入容器shell
enter_shell() {
    echo "🐚 进入 $CONTAINER_NAME 容器..."
    docker exec -it $CONTAINER_NAME /bin/bash
}

# 构建前端资源
build_frontend() {
    echo "🔨 构建前端资源..."
    ./dev-scripts/build-frontend.sh
}

# 同步前端代码
sync_frontend() {
    echo "🔄 同步前端代码..."
    ./dev-scripts/sync-frontend.sh
}

# 清理开发环境
clean_dev() {
    echo "🧹 清理 ONLYOFFICE DocumentServer 开发环境..."
    docker-compose -f $COMPOSE_FILE down -v --remove-orphans
    docker system prune -f
    echo "✅ 开发环境已清理"
}

# 查看服务状态
show_status() {
    echo "📊 ONLYOFFICE DocumentServer 开发环境状态:"
    docker-compose -f $COMPOSE_FILE ps
}

# 连接数据库
db_shell() {
    echo "🗄️  连接到 PostgreSQL 数据库..."
    docker exec -it onlyoffice-postgresql-dev psql -U onlyoffice -d onlyoffice
}

# 连接Redis
redis_cli() {
    echo "📊 连接到 Redis..."
    docker exec -it onlyoffice-redis-dev redis-cli
}

# 打开RabbitMQ管理界面
rabbitmq_mgmt() {
    echo "🐰 打开 RabbitMQ 管理界面..."
    echo "访问: http://localhost:15672"
    echo "用户名: guest"
    echo "密码: guest"
    if command -v open >/dev/null 2>&1; then
        open http://localhost:15672
    elif command -v xdg-open >/dev/null 2>&1; then
        xdg-open http://localhost:15672
    fi
}

# 启动开发工具容器
start_tools() {
    echo "🛠️  启动开发工具容器..."
    docker-compose -f $COMPOSE_FILE --profile tools up -d onlyoffice-dev-tools
    echo "✅ 开发工具容器已启动"
    echo "💡 进入工具容器: docker exec -it onlyoffice-dev-tools sh"
}

# 主逻辑
case "${1:-help}" in
    start)
        start_dev
        ;;
    stop)
        stop_dev
        ;;
    restart)
        restart_dev
        ;;
    logs)
        show_logs "$@"
        ;;
    shell)
        enter_shell
        ;;
    build)
        build_frontend
        ;;
    sync)
        sync_frontend
        ;;
    clean)
        clean_dev
        ;;
    status)
        show_status
        ;;
    db-shell)
        db_shell
        ;;
    redis-cli)
        redis_cli
        ;;
    rabbitmq)
        rabbitmq_mgmt
        ;;
    tools)
        start_tools
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ 未知命令: $1"
        echo ""
        show_help
        exit 1
        ;;
esac 
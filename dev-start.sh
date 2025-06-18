#!/bin/bash

# ONLYOFFICE DocumentServer 开发环境快速启动脚本
# 一键启动完整的开发环境

set -e

echo "🚀 ONLYOFFICE DocumentServer 开发环境启动器"
echo "=============================================="
echo "📦 此脚本将自动："
echo "   1. 停止冲突的容器"
echo "   2. 构建并启动开发环境"
echo "   3. 构建前端资源 (web-apps & sdkjs)"
echo "   4. 同步代码到容器"
echo "   5. 验证服务启动"
echo ""

# 检查 Docker 是否运行
if ! docker info >/dev/null 2>&1; then
    echo "❌ 错误: Docker 未运行，请先启动 Docker"
    exit 1
fi

# 检查必要的目录是否存在
if [ ! -d "../DocumentServer" ]; then
    echo "❌ 错误: 未找到 DocumentServer 源代码目录"
    echo "请确保项目结构如下："
    echo "  your-workspace/"
    echo "  ├── DocumentServer/"
    echo "  ├── Docker-DocumentServer/ (当前目录)"
    echo "  ├── build_tools/"
    echo "  └── document-server-package/"
    exit 1
fi

# 停止可能运行的生产环境容器
echo "🛑 停止可能冲突的容器..."
docker-compose down 2>/dev/null || true

# 清理旧的开发环境（如果存在）
echo "🧹 清理旧的开发环境..."
docker-compose -f docker-compose.dev.yml down 2>/dev/null || true

# 构建并启动开发环境
echo "🔨 构建并启动开发环境..."
docker-compose -f docker-compose.dev.yml up -d --build

# 等待服务启动
echo "⏳ 等待服务启动..."
sleep 10

# 检查服务状态
echo "📊 检查服务状态..."
docker-compose -f docker-compose.dev.yml ps

# 构建前端资源
echo "🔨 构建前端资源..."
if [ -d "../DocumentServer/web-apps/build" ]; then
    echo "🔨 构建 web-apps (开发模式 - 保留console.log)..."
    cd ../DocumentServer/web-apps/build
    if [ ! -d "node_modules" ]; then
        echo "📥 安装 web-apps 依赖..."
        npm install
    fi
    if [ -f "Gruntfile.js" ]; then
        echo "🔨 执行 web-apps Grunt 构建 (开发模式)..."
        # 使用新添加的开发模式任务，跳过terser压缩以保留console.log
        npx grunt dev
        echo "✅ web-apps 构建完成 (开发模式 - 已保留console.log)"
    else
        echo "⚠️  未找到 Gruntfile.js，使用默认构建..."
        npx grunt
    fi
    cd - > /dev/null
else
    echo "⚠️  未找到 web-apps/build 目录，跳过前端构建"
fi

# 构建 sdkjs（如果存在）
if [ -d "../DocumentServer/sdkjs/build" ] && [ -f "../DocumentServer/sdkjs/build/package.json" ]; then
    echo "🔨 构建 sdkjs (开发模式 - 保留console.log)..."
    cd ../DocumentServer/sdkjs/build
    if [ ! -d "node_modules" ]; then
        echo "📥 安装 sdkjs 依赖..."
        npm install
    fi
    if [ -f "Gruntfile.js" ]; then
        echo "🔨 执行 sdkjs Grunt 构建 (开发模式)..."
        # 使用开发模式任务，保留console.log用于调试
        npx grunt compile-sdk-dev copy-other
        echo "✅ sdkjs 构建完成 (开发模式 - 已保留console.log)"
    fi
    cd - > /dev/null
fi

# 同步前端代码
echo "🔄 同步前端代码..."
./dev-scripts/sync-frontend.sh

# 重启服务以确保更改生效
echo "🔄 重启DocumentServer服务..."
docker exec onlyoffice-documentserver-dev supervisorctl restart ds:docservice

# 等待 DocumentServer 完全启动
echo "⏳ 等待 DocumentServer 启动完成..."
for i in {1..30}; do
    if curl -s http://localhost:8080/healthcheck >/dev/null 2>&1; then
        echo "✅ DocumentServer 启动成功！"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  DocumentServer 启动可能需要更多时间，请稍后检查"
        break
    fi
    sleep 2
    echo -n "."
done

echo ""
echo "🎉 开发环境启动完成！"
echo "=============================================="
echo "✅ 已完成:"
echo "   ✓ Docker 容器启动"
echo "   ✓ 前端资源构建 (web-apps & sdkjs)"
echo "   ✓ 代码同步到容器"
echo "   ✓ 服务健康检查通过"
echo ""
echo "📍 访问地址:"
echo "   主服务:        http://localhost:8080"
echo "   欢迎页面:      http://localhost:8080/welcome/"
echo ""
echo "🛠️  开发工具:"
echo "   数据库:        localhost:5432 (用户: onlyoffice, 密码: onlyoffice)"
echo "   RabbitMQ管理:  http://localhost:15672 (用户: guest, 密码: guest)"
echo "   Redis:         localhost:6379"
echo ""
echo "📝 开发工作流:"
echo "   1. 修改前端代码: ../DocumentServer/web-apps/ 或 ../DocumentServer/sdkjs/"
echo "   2. 重新构建:     ./dev-scripts/dev-helper.sh build"
echo "   3. 同步代码:     ./dev-scripts/dev-helper.sh sync"
echo "   4. 重启服务:     ./dev-scripts/dev-helper.sh restart"
echo ""
echo "📝 常用命令:"
echo "   查看日志:      ./dev-scripts/dev-helper.sh logs -f"
echo "   进入容器:      ./dev-scripts/dev-helper.sh shell"
echo "   停止环境:      ./dev-scripts/dev-helper.sh stop"
echo ""
echo "💡 提示: 现在可以直接访问 http://localhost:8080 开始开发！"
echo "==============================================" 
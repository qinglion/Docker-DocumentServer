#!/bin/bash

# ONLYOFFICE DocumentServer 前端构建脚本
# 用于在开发环境中快速构建前端资源

set -e

echo "🚀 开始构建 ONLYOFFICE DocumentServer 前端资源..."

# 检查是否在正确的目录
if [ ! -d "../DocumentServer" ]; then
    echo "❌ 错误: 请确保在 Docker-DocumentServer 目录中运行此脚本"
    exit 1
fi

# 构建 web-apps
echo "📦 构建 web-apps..."
cd ../DocumentServer/web-apps/build

# 安装依赖（如果需要）
if [ ! -d "node_modules" ]; then
    echo "📥 安装 web-apps 依赖..."
    npm install
fi

# 执行构建
echo "🔨 执行 Grunt 构建..."
npx grunt

echo "✅ web-apps 构建完成"

# 构建 sdkjs（如果有构建脚本）
cd ../../sdkjs/build
if [ -f "package.json" ]; then
    echo "📦 构建 sdkjs..."
    
    if [ ! -d "node_modules" ]; then
        echo "📥 安装 sdkjs 依赖..."
        npm install
    fi
    
    if [ -f "Gruntfile.js" ]; then
        echo "🔨 执行 sdkjs Grunt 构建 (开发模式，保留console.log)..."
        # 使用开发专用任务保留 console.log
        npx grunt compile-sdk-dev copy-other
        echo "✅ sdkjs 构建完成 (开发模式 - 已保留console.log)"
    fi
fi

echo "🎉 所有前端资源构建完成！"
echo "💡 提示: 重启 Docker 容器以应用更改:"
echo "   docker-compose -f docker-compose.dev.yml restart onlyoffice-documentserver-dev" 
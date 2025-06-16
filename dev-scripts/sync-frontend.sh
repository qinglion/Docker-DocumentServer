#!/bin/bash

# ONLYOFFICE DocumentServer 前端代码同步脚本
# 将源代码同步到容器内的正确位置

set -e

CONTAINER_NAME="onlyoffice-documentserver-dev"

echo "🔄 同步前端代码到容器..."

# 检查容器是否运行
if ! docker ps | grep -q $CONTAINER_NAME; then
    echo "❌ 错误: 容器 $CONTAINER_NAME 未运行"
    echo "请先启动开发环境: ./dev-scripts/dev-helper.sh start"
    exit 1
fi

# 等待容器完全启动
echo "⏳ 等待容器启动完成..."
sleep 5

# 同步 web-apps 构建产物
echo "📦 同步 web-apps 构建产物..."
docker exec $CONTAINER_NAME bash -c "
    if [ -d /opt/src/web-apps/deploy ]; then
        cp -rf /opt/src/web-apps/deploy/* /var/www/onlyoffice/documentserver/web-apps/
        echo '✅ web-apps 构建产物同步完成'
    else
        echo '⚠️  web-apps 构建产物目录不存在，使用源代码: /opt/src/web-apps/deploy'
        if [ -d /opt/src/web-apps ]; then
            cp -rf /opt/src/web-apps/* /var/www/onlyoffice/documentserver/web-apps/
            echo '✅ web-apps 源代码同步完成'
        fi
    fi
"

# 同步 sdkjs 构建产物（重要：这里包含了我们的console.log）
echo "📦 同步 sdkjs 构建产物..."
docker exec $CONTAINER_NAME bash -c "
    if [ -d /opt/src/sdkjs/deploy/sdkjs ]; then
        cp -rf /opt/src/sdkjs/deploy/sdkjs/* /var/www/onlyoffice/documentserver/sdkjs/
        echo '✅ sdkjs 构建产物同步完成（包含console.log）'
        
        # 重新生成gzip文件以包含最新更改
        echo '🔄 重新生成gzip文件...'
        cd /var/www/onlyoffice/documentserver/sdkjs
        find . -name '*.js' -not -name '*.min.js' | while read file; do
            if [ -f \"\${file}.gz\" ]; then
                gzip -c \"\$file\" > \"\${file}.gz.new\" && mv \"\${file}.gz.new\" \"\${file}.gz\"
                echo \"  ✅ 更新: \${file}.gz\"
            fi
        done
        echo '✅ gzip文件重新生成完成'
    else
        echo '⚠️  sdkjs 构建产物目录不存在，使用源代码: /opt/src/sdkjs/deploy/sdkjs'
        if [ -d /opt/src/sdkjs ]; then
            cp -rf /opt/src/sdkjs/* /var/www/onlyoffice/documentserver/sdkjs/
            echo '✅ sdkjs 源代码同步完成'
        fi
    fi
"

# 重启 nginx 以应用更改
echo "🔄 重启 nginx..."
docker exec $CONTAINER_NAME nginx -s reload

echo "🎉 前端代码同步完成！"
echo "💡 提示: 访问 http://localhost:8080 查看效果" 
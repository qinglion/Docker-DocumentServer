# ONLYOFFICE DocumentServer 开发环境脚本

这个目录包含了用于 ONLYOFFICE DocumentServer 开发环境的辅助脚本和配置文件。

## 文件说明

### 脚本文件

- **`dev-helper.sh`** - 主要的开发辅助脚本，提供所有常用的开发操作命令
- **`build-frontend.sh`** - 前端资源构建脚本，用于编译 web-apps 和 sdkjs
- **`../dev-start.sh`** - 一键启动开发环境的快速启动脚本

### 配置文件

- **`init-db.sql`** - PostgreSQL 数据库初始化脚本
- **`../env.dev.example`** - 开发环境变量配置示例

## 快速开始

### 1. 启动开发环境

```bash
# 方法一：使用快速启动脚本（推荐新手）
./dev-start.sh

# 方法二：使用开发辅助脚本
./dev-scripts/dev-helper.sh start
```

### 2. 常用开发命令

```bash
# 查看所有可用命令
./dev-scripts/dev-helper.sh help

# 查看服务状态
./dev-scripts/dev-helper.sh status

# 查看实时日志
./dev-scripts/dev-helper.sh logs -f

# 进入主容器进行调试
./dev-scripts/dev-helper.sh shell

# 构建前端资源
./dev-scripts/dev-helper.sh build

# 重启服务（应用代码更改）
./dev-scripts/dev-helper.sh restart
```

### 3. 数据库和缓存操作

```bash
# 连接 PostgreSQL 数据库
./dev-scripts/dev-helper.sh db-shell

# 连接 Redis
./dev-scripts/dev-helper.sh redis-cli

# 打开 RabbitMQ 管理界面
./dev-scripts/dev-helper.sh rabbitmq
```

## 开发工作流

### 前端开发

1. 修改 `../DocumentServer/web-apps/` 或 `../DocumentServer/sdkjs/` 中的文件
2. 运行构建脚本：`./dev-scripts/dev-helper.sh build`
3. 重启服务：`./dev-scripts/dev-helper.sh restart`
4. 在浏览器中访问 http://localhost:8080 查看效果

### 后端开发

1. 修改 `../DocumentServer/server/` 中的 Node.js 代码
2. 重启服务：`./dev-scripts/dev-helper.sh restart`
3. 查看日志确认更改生效：`./dev-scripts/dev-helper.sh logs -f`

### 调试技巧

- **查看容器内部**：`./dev-scripts/dev-helper.sh shell`
- **监控日志**：`./dev-scripts/dev-helper.sh logs -f`
- **检查数据库**：`./dev-scripts/dev-helper.sh db-shell`
- **测试 API**：使用 curl 或 Postman 测试 http://localhost:8080 的 API

## 环境配置

### 端口映射

- **8080** - DocumentServer 主服务
- **8443** - DocumentServer HTTPS
- **5432** - PostgreSQL 数据库
- **6379** - Redis
- **5672** - RabbitMQ AMQP
- **15672** - RabbitMQ 管理界面

### 数据持久化

开发环境使用 Docker volumes 来持久化数据：

- `onlyoffice_dev_data` - 应用数据
- `onlyoffice_dev_logs` - 日志文件
- `onlyoffice_dev_postgresql` - 数据库数据
- `onlyoffice_dev_redis` - Redis 数据

### 源代码挂载

以下目录会直接挂载到容器中，修改后无需重新构建镜像：

- `DocumentServer/web-apps/` → 容器内前端应用
- `DocumentServer/sdkjs/` → 容器内 SDK
- `DocumentServer/server/` → 容器内服务器代码
- `DocumentServer/dictionaries/` → 容器内词典
- `DocumentServer/core-fonts/` → 容器内字体

## 故障排除

### 常见问题

1. **端口冲突**：确保 8080、5432、6379、15672 端口未被占用
2. **权限问题**：确保脚本有执行权限：`chmod +x dev-scripts/*.sh`
3. **Docker 未运行**：确保 Docker Desktop 或 Docker 服务正在运行
4. **源代码路径错误**：确保项目目录结构正确

### 清理环境

```bash
# 停止并清理所有容器和数据
./dev-scripts/dev-helper.sh clean

# 重新开始
./dev-start.sh
```

## 生产部署

开发完成后，可以通过以下方式部署到生产环境：

1. **构建自定义 Docker 镜像**
2. **使用 build_tools 重新编译**
3. **使用 document-server-package 打包成 .deb**

详细说明请参考主 README.md 文件。

# ONLYOFFICE DocumentServer 开发工具

本目录包含用于 ONLYOFFICE DocumentServer 开发的工具脚本。

## 🚀 开发模式特性

### 保留console.log用于调试

开发环境现在支持保留`console.log`语句以便调试：

**自动启用：**
- 执行 `../dev-start.sh` 时会自动使用开发模式构建
- 执行 `./build-frontend.sh` 时也会使用开发模式

**手动构建：**
```bash
# 在 DocumentServer/sdkjs/build 目录中
npx grunt compile-sdk-dev copy-other  # 保留console.log的构建
npx grunt compile-sdk copy-other      # 生产模式构建（删除console.log）
```

**编译级别对比：**
- **生产模式**: `ADVANCED_OPTIMIZATIONS` - 删除所有console.log
- **开发模式**: `SIMPLE_OPTIMIZATIONS` - 保留console.log，仅进行基本优化

### 可用的开发任务

- `compile-word-dev` - 编译Word SDK（开发模式）
- `compile-cell-dev` - 编译Excel SDK（开发模式）  
- `compile-slide-dev` - 编译PowerPoint SDK（开发模式）
- `compile-sdk-dev` - 编译所有SDK（开发模式）

## 📁 脚本说明 

```bash
# 1. 启动开发环境（自动保留console.log）
./dev-start.sh

# 2. 修改代码后重新构建和同步
./dev-scripts/build-frontend.sh
./dev-scripts/sync-frontend.sh
```
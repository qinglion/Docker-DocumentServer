-- ONLYOFFICE DocumentServer 开发环境数据库初始化脚本
-- 这个脚本会在PostgreSQL容器首次启动时执行

-- 确保数据库和用户存在
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'onlyoffice') THEN
        CREATE USER onlyoffice WITH PASSWORD 'onlyoffice';
    END IF;
END
$$;

-- 确保数据库存在
SELECT 'CREATE DATABASE onlyoffice OWNER onlyoffice'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'onlyoffice')\gexec

-- 授予权限
GRANT ALL PRIVILEGES ON DATABASE onlyoffice TO onlyoffice;

-- 连接到onlyoffice数据库并创建必要的扩展
\c onlyoffice;

-- 创建UUID扩展（如果需要）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 输出初始化完成信息
\echo 'ONLYOFFICE DocumentServer 开发数据库初始化完成' 
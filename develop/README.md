# ONLYOFFICE DocumentServer 开发版本

这是一个包含了 [qinglion](https://github.com/qinglion) 修改版本的 `sdkjs` 和 `web-apps` 的 ONLYOFFICE DocumentServer 开发镜像。

## 特性

- 基于 `onlyoffice/documentserver:latest`
- 内置 [qinglion/sdkjs](https://github.com/qinglion/sdkjs) 和 [qinglion/web-apps](https://github.com/qinglion/web-apps) 源码
- 启用调试日志
- 自动启动测试示例
- 支持开发环境构建和热重载

## 使用方法

### 运行开发镜像

```bash
docker run -i -t -p 8080:80 --restart=always ccr.ccs.tencentyun.com/qinglion/documentserver:latest
```

### 访问编辑器

服务器启动成功后，在浏览器中访问 [http://localhost/example](http://localhost/example) 来测试文档编辑器。

**注意**: 请为 localhost 页面禁用广告拦截器，它可能会阻止某些脚本（如 Analytics.js）。

## 构建信息

- 镜像包含预构建的 `sdkjs` 和 `web-apps` 源码
- 无需手动挂载本地文件夹
- 支持多平台构建 (linux/amd64, linux/arm64)

## 开发

如果需要修改源码，可以：

1. Fork [qinglion/sdkjs](https://github.com/qinglion/sdkjs) 和 [qinglion/web-apps](https://github.com/qinglion/web-apps)
2. 修改 `Dockerfile` 中的 git clone 地址
3. 重新构建镜像

## 自动化构建

此镜像通过 GitHub Actions 自动构建，当以下情况发生时会触发构建：

- 手动触发工作流程

## 许可证

遵循 ONLYOFFICE DocumentServer 的许可证协议。 
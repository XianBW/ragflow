# RAGFlow前后端分离部署

## 概述

RAGFlow现在支持前后端分离部署，允许您单独构建和部署前端和后端容器，实现更灵活的部署架构。

## 🚀 快速开始

### 1. 验证环境
```bash
cd docker
./verify-files.sh
```

### 2. 构建镜像
```bash
./build-frontend-backend.sh
```

### 3. 启动服务
```bash
docker-compose -f docker-compose-frontend-backend.yml up -d
```

### 4. 访问服务
- 前端界面: http://localhost
- 后端API: http://localhost:9380

## 📁 文件结构

```
ragflow/
├── Dockerfile.frontend              # 前端专用Dockerfile
├── Dockerfile.backend               # 后端专用Dockerfile
├── docker/
│   ├── build-frontend-backend.sh    # 构建脚本
│   ├── test-frontend-backend.sh     # 测试脚本
│   ├── verify-files.sh              # 文件验证脚本
│   ├── docker-compose-frontend-backend.yml  # Docker Compose配置
│   ├── nginx/
│   │   └── frontend.conf           # 前端nginx配置
│   ├── README_frontend_backend.md   # 详细使用指南
│   ├── QUICK_START.md              # 快速开始指南
│   ├── TROUBLESHOOTING.md          # 故障排除指南
│   └── FRONTEND_BACKEND_SUMMARY.md # 功能总结
└── web/
    └── src/
        ├── conf.json               # 前端配置文件
        └── conf.json.template      # 配置文件模板
```

## 🔧 功能特性

### 1. 灵活的部署模式
- **单机部署**: 使用Docker Compose一键部署
- **手动部署**: 分别启动前端和后端容器
- **多实例部署**: 支持多个后端实例和负载均衡

### 2. 配置灵活性
- **环境变量**: 通过`API_SERVER_URL`配置后端地址
- **网络配置**: 支持自定义Docker网络
- **端口映射**: 灵活的端口配置

### 3. 监控和调试
- **健康检查**: 前端和后端都有健康检查端点
- **日志查看**: 详细的容器日志
- **网络诊断**: 容器间网络连接测试

## 📖 使用指南

### 构建镜像

```bash
# 构建前后端镜像
./build-frontend-backend.sh

# 只构建前端镜像
./build-frontend-backend.sh --frontend-only

# 只构建后端镜像
./build-frontend-backend.sh --backend-only

# 自定义镜像标签
./build-frontend-backend.sh -f my-frontend:v1.0 -b my-backend:v1.0
```

### 部署服务

```bash
# 使用Docker Compose
docker-compose -f docker/docker-compose-frontend-backend.yml up -d

# 手动部署
docker run -d --name ragflow-backend ragflow-backend:latest
docker run -d --name ragflow-frontend ragflow-frontend:latest
```

### 配置管理

```bash
# 通过环境变量配置
docker run -d -e API_SERVER_URL=http://your-backend:9380/ ragflow-frontend:latest

# 挂载自定义配置文件
docker run -d -v ./custom-conf.json:/ragflow/web/src/conf.json ragflow-frontend:latest
```

## 🧪 测试和验证

### 运行测试
```bash
cd docker
./test-frontend-backend.sh
```

### 验证文件
```bash
./verify-files.sh
```

### 健康检查
```bash
# 前端健康检查
curl http://localhost/health

# 后端健康检查
curl http://localhost:9380/health
```

## 🔍 监控和日志

### 查看服务状态
```bash
docker-compose -f docker/docker-compose-frontend-backend.yml ps
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose -f docker/docker-compose-frontend-backend.yml logs

# 查看特定服务日志
docker logs ragflow-frontend
docker logs ragflow-backend
```

### 网络诊断
```bash
# 检查容器间网络连接
docker exec ragflow-frontend ping ragflow-backend

# 检查网络配置
docker network ls
docker network inspect ragflow-network
```

## 🛠️ 故障排除

### 常见问题

1. **Docker守护进程未运行**
   ```bash
   # macOS
   open -a Docker
   
   # Linux
   sudo systemctl start docker
   ```

2. **端口冲突**
   ```bash
   # 使用不同端口
   docker run -d -p 8080:80 ragflow-frontend:latest
   docker run -d -p 9382:9380 ragflow-backend:latest
   ```

3. **网络连接问题**
   ```bash
   # 创建自定义网络
   docker network create ragflow-network
   docker run -d --network ragflow-network ragflow-backend:latest
   docker run -d --network ragflow-network ragflow-frontend:latest
   ```

### 调试步骤

1. **验证环境**
   ```bash
   ./verify-files.sh
   docker info
   ```

2. **逐步测试**
   ```bash
   ./build-frontend-backend.sh --frontend-only
   ./build-frontend-backend.sh --backend-only
   ```

3. **检查日志**
   ```bash
   docker logs ragflow-frontend
   docker logs ragflow-backend
   ```

## 📚 详细文档

- [快速开始指南](docker/QUICK_START.md) - 5分钟快速部署
- [详细使用指南](docker/README_frontend_backend.md) - 完整的使用说明
- [故障排除指南](docker/TROUBLESHOOTING.md) - 常见问题解决方案
- [功能总结](docker/FRONTEND_BACKEND_SUMMARY.md) - 功能特性总结

## 🎯 使用场景

### 1. 开发环境
- 快速构建和测试
- 独立的前端和后端开发
- 灵活的配置管理

### 2. 测试环境
- 多实例测试
- 负载均衡测试
- 故障恢复测试

### 3. 生产环境
- 高可用部署
- 水平扩展
- 监控和告警

## 🔒 安全考虑

### 网络安全
```bash
# 使用内部网络
docker network create ragflow-internal
docker run --network ragflow-internal ragflow-backend:latest
```

### 数据安全
```bash
# 使用加密存储
docker run -v encrypted-volume:/ragflow/data ragflow-backend:latest

# 定期备份
docker run --rm -v ragflow_data:/data -v /backup:/backup alpine tar czf /backup/ragflow_data.tar.gz -C /data .
```

## 📈 性能优化

### 构建优化
```bash
# 使用构建缓存
docker build --build-arg BUILDKIT_INLINE_CACHE=1 -f Dockerfile.frontend .

# 并行构建
./build-frontend-backend.sh --frontend-only &
./build-frontend-backend.sh --backend-only &
wait
```

### 运行时优化
```bash
# 限制资源使用
docker run -d --memory=2g --cpus=1 ragflow-backend:latest
docker run -d --memory=512m --cpus=0.5 ragflow-frontend:latest
```

## 🤝 贡献

如果您想为前后端分离部署功能做出贡献，请：

1. Fork项目
2. 创建功能分支
3. 提交更改
4. 创建Pull Request

## 📞 支持

如果您遇到问题，请：

1. 查看[故障排除指南](docker/TROUBLESHOOTING.md)
2. 运行验证脚本: `./verify-files.sh`
3. 收集错误日志和系统信息
4. 在GitHub上创建Issue

## 📄 许可证

本项目采用MIT许可证。详见[LICENSE](LICENSE)文件。 
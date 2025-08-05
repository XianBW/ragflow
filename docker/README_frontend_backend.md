# RAGFlow前后端分离部署指南

本文档介绍如何使用前后端分离的方式部署RAGFlow，包括构建镜像、配置和运行。

## 概述

RAGFlow现在支持前后端分离部署，您可以：
- 单独构建前端和后端镜像
- 独立部署前端和后端容器
- 灵活配置前端连接到不同的后端服务
- 实现更好的扩展性和维护性

## 文件结构

```
docker/
├── Dockerfile.frontend              # 前端专用Dockerfile
├── Dockerfile.backend               # 后端专用Dockerfile
├── build-frontend-backend.sh        # 构建脚本
├── docker-compose-frontend-backend.yml  # 前后端分离部署配置
├── nginx/
│   └── frontend.conf               # 前端nginx配置
└── README_frontend_backend.md      # 本文档
```

## 快速开始

### 1. 构建镜像

使用构建脚本构建前后端镜像：

```bash
# 构建前后端镜像
cd docker
./build-frontend-backend.sh

# 只构建前端镜像
./build-frontend-backend.sh --frontend-only

# 只构建后端镜像
./build-frontend-backend.sh --backend-only

# 自定义镜像标签
./build-frontend-backend.sh -f my-frontend:v1.0 -b my-backend:v1.0
```

### 2. 使用Docker Compose部署

```bash
# 启动前后端服务
docker-compose -f docker-compose-frontend-backend.yml up -d

# 查看服务状态
docker-compose -f docker-compose-frontend-backend.yml ps

# 查看日志
docker-compose -f docker-compose-frontend-backend.yml logs -f
```

### 3. 手动部署

```bash
# 启动后端服务
docker run -d \
  --name ragflow-backend \
  -p 9380:9380 \
  -p 9381:9381 \
  -v ragflow_data:/ragflow/data \
  -v ragflow_logs:/ragflow/logs \
  ragflow-backend:latest

# 启动前端服务
docker run -d \
  --name ragflow-frontend \
  -p 80:80 \
  -e API_SERVER_URL=http://ragflow-backend:9380/ \
  --link ragflow-backend \
  ragflow-frontend:latest
```

## 详细配置

### 前端配置

前端容器支持以下环境变量：

- `API_SERVER_URL`: API服务器地址（默认: http://localhost:9380/）

```bash
# 连接到不同的后端服务
docker run -d \
  --name ragflow-frontend \
  -p 80:80 \
  -e API_SERVER_URL=http://your-backend-server:9380/ \
  ragflow-frontend:latest
```

### 后端配置

后端容器支持原有的所有配置选项：

```bash
# 启动后端服务（禁用web服务器）
docker run -d \
  --name ragflow-backend \
  -p 9380:9380 \
  -p 9381:9381 \
  ragflow-backend:latest

# 启动任务执行器
docker run -d \
  --name ragflow-task-executor \
  -e PYTHONPATH=/ragflow/ \
  ragflow-backend:latest \
  ./entrypoint.sh --disable-webserver --workers=2
```

### 网络配置

在Docker Compose中，服务通过内部网络通信：

```yaml
networks:
  ragflow-network:
    driver: bridge
```

在手动部署中，可以使用Docker网络：

```bash
# 创建网络
docker network create ragflow-network

# 启动后端
docker run -d \
  --name ragflow-backend \
  --network ragflow-network \
  ragflow-backend:latest

# 启动前端
docker run -d \
  --name ragflow-frontend \
  --network ragflow-network \
  -e API_SERVER_URL=http://ragflow-backend:9380/ \
  ragflow-frontend:latest
```

## 部署模式

### 1. 单机部署

```bash
# 使用Docker Compose
docker-compose -f docker-compose-frontend-backend.yml up -d
```

### 2. 多实例部署

```bash
# 启动多个后端实例
docker run -d --name ragflow-backend-1 ragflow-backend:latest
docker run -d --name ragflow-backend-2 ragflow-backend:latest

# 启动前端，连接到负载均衡器
docker run -d \
  --name ragflow-frontend \
  -e API_SERVER_URL=http://load-balancer:9380/ \
  ragflow-frontend:latest
```

### 3. 生产环境部署

```bash
# 使用外部数据库
docker run -d \
  --name ragflow-backend \
  -e DATABASE_URL=postgresql://user:pass@db:5432/ragflow \
  ragflow-backend:latest

# 使用外部存储
docker run -d \
  --name ragflow-frontend \
  -v /path/to/storage:/ragflow/data \
  ragflow-frontend:latest
```

## 监控和日志

### 查看容器状态

```bash
# 查看所有容器
docker ps -a | grep ragflow

# 查看容器日志
docker logs ragflow-backend
docker logs ragflow-frontend
```

### 健康检查

```bash
# 检查前端健康状态
curl http://localhost/health

# 检查后端健康状态
curl http://localhost:9380/health
```

## 故障排除

### 常见问题

1. **前端无法连接到后端**
   ```bash
   # 检查网络连接
   docker exec ragflow-frontend ping ragflow-backend
   
   # 检查API服务器配置
   docker exec ragflow-frontend cat /ragflow/web/src/conf.json
   ```

2. **端口冲突**
   ```bash
   # 使用不同的端口
   docker run -d -p 8080:80 ragflow-frontend:latest
   docker run -d -p 9382:9380 ragflow-backend:latest
   ```

3. **权限问题**
   ```bash
   # 检查文件权限
   docker exec ragflow-backend ls -la /ragflow/data
   ```

### 调试模式

```bash
# 以调试模式启动
docker run -it --rm ragflow-backend:latest bash
docker run -it --rm ragflow-frontend:latest sh
```

## 性能优化

### 前端优化

- 启用nginx gzip压缩
- 配置静态文件缓存
- 使用CDN加速

### 后端优化

- 调整Python进程数
- 配置数据库连接池
- 启用缓存机制

## 安全考虑

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
```

## 扩展性

### 水平扩展

```bash
# 启动多个后端实例
docker run -d --name backend-1 ragflow-backend:latest
docker run -d --name backend-2 ragflow-backend:latest
docker run -d --name backend-3 ragflow-backend:latest
```

### 负载均衡

```bash
# 使用nginx作为负载均衡器
docker run -d --name nginx-lb \
  -v /path/to/nginx.conf:/etc/nginx/nginx.conf \
  nginx:alpine
```

## 总结

前后端分离部署提供了更好的灵活性和可扩展性。您可以根据实际需求选择合适的部署模式，并利用Docker的网络和存储功能实现高可用和高性能的RAGFlow部署。 
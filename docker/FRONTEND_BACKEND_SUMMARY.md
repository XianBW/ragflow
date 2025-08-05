# RAGFlow前后端分离部署功能总结

## 概述

本次新增了RAGFlow的前后端分离部署功能，允许用户单独构建和部署前端和后端容器，实现更灵活的部署架构。

## 新增文件

### 1. Dockerfile文件

#### `Dockerfile.frontend`
- **用途**: 专门用于构建前端镜像
- **特点**: 
  - 使用Node.js 20 Alpine作为基础镜像
  - 多阶段构建，最终使用nginx作为生产服务器
  - 包含配置脚本，支持动态配置API服务器地址
  - 体积小，启动快

#### `Dockerfile.backend`
- **用途**: 专门用于构建后端镜像
- **特点**:
  - 基于原有的完整Dockerfile
  - 只包含API服务器相关组件
  - 支持任务执行器模式
  - 保持与原有功能的完全兼容

### 2. 配置文件

#### `docker/nginx/frontend.conf`
- **用途**: 前端nginx配置文件
- **功能**:
  - API请求代理到后端容器
  - 静态文件缓存和gzip压缩
  - WebSocket支持
  - 健康检查端点
  - SPA路由支持

#### `docker/docker-compose-frontend-backend.yml`
- **用途**: 前后端分离部署的Docker Compose配置
- **特点**:
  - 包含前端、后端和任务执行器服务
  - 使用自定义网络进行容器间通信
  - 支持数据卷持久化
  - 自动重启策略

### 3. 构建和部署脚本

#### `docker/build-frontend-backend.sh`
- **用途**: 前后端镜像构建脚本
- **功能**:
  - 支持单独构建前端或后端镜像
  - 自定义镜像标签
  - 支持推送到镜像仓库
  - 详细的构建日志和错误处理

#### `docker/test-frontend-backend.sh`
- **用途**: 前后端分离部署测试脚本
- **功能**:
  - 自动检查必要文件
  - 构建缺失的镜像
  - 启动测试服务
  - 健康检查和网络连接测试
  - 详细的测试报告

### 4. 文档

#### `docker/README_frontend_backend.md`
- **用途**: 详细的使用指南
- **内容**:
  - 快速开始指南
  - 详细配置说明
  - 多种部署模式
  - 故障排除指南
  - 性能优化建议

## 功能特性

### 1. 灵活的部署模式

#### 单机部署
```bash
# 使用Docker Compose
docker-compose -f docker-compose-frontend-backend.yml up -d
```

#### 手动部署
```bash
# 启动后端
docker run -d --name ragflow-backend ragflow-backend:latest

# 启动前端
docker run -d --name ragflow-frontend ragflow-frontend:latest
```

#### 多实例部署
```bash
# 启动多个后端实例
docker run -d --name backend-1 ragflow-backend:latest
docker run -d --name backend-2 ragflow-backend:latest

# 前端连接到负载均衡器
docker run -d --name frontend ragflow-frontend:latest
```

### 2. 配置灵活性

#### 环境变量配置
```bash
# 通过环境变量配置API服务器
docker run -d -e API_SERVER_URL=http://your-backend:9380/ ragflow-frontend:latest
```

#### 网络配置
```bash
# 使用自定义网络
docker network create ragflow-network
docker run -d --network ragflow-network ragflow-backend:latest
docker run -d --network ragflow-network ragflow-frontend:latest
```

### 3. 监控和调试

#### 健康检查
- 前端: `http://localhost/health`
- 后端: `http://localhost:9380/health`

#### 日志查看
```bash
# 查看容器日志
docker logs ragflow-frontend
docker logs ragflow-backend
```

#### 调试模式
```bash
# 以交互模式启动
docker run -it --rm ragflow-backend:latest bash
docker run -it --rm ragflow-frontend:latest sh
```

## 使用示例

### 1. 快速开始

```bash
# 构建镜像
cd docker
./build-frontend-backend.sh

# 启动服务
docker-compose -f docker-compose-frontend-backend.yml up -d

# 测试服务
./test-frontend-backend.sh
```

### 2. 生产环境部署

```bash
# 构建生产镜像
./build-frontend-backend.sh -f ragflow-frontend:v1.0 -b ragflow-backend:v1.0

# 推送到镜像仓库
./build-frontend-backend.sh --push

# 部署到生产环境
docker run -d --name backend ragflow-backend:v1.0
docker run -d --name frontend ragflow-frontend:v1.0
```

### 3. 开发环境

```bash
# 只构建前端镜像
./build-frontend-backend.sh --frontend-only

# 连接到现有的后端服务
docker run -d -e API_SERVER_URL=http://dev-backend:9380/ ragflow-frontend:latest
```

## 优势

### 1. 部署灵活性
- 可以独立部署前端和后端
- 支持不同的扩展策略
- 便于A/B测试和灰度发布

### 2. 资源优化
- 前端镜像体积小，启动快
- 后端镜像专注于API服务
- 可以根据需求调整资源配置

### 3. 维护便利
- 前端和后端可以独立更新
- 便于故障隔离和调试
- 支持不同的监控策略

### 4. 扩展性
- 支持水平扩展
- 便于负载均衡配置
- 支持微服务架构

## 注意事项

### 1. 网络配置
- 确保前端和后端容器在同一网络中
- 正确配置API服务器地址
- 注意防火墙和端口配置

### 2. 数据持久化
- 后端数据需要持久化存储
- 前端配置可以通过环境变量或挂载文件配置
- 注意数据备份策略

### 3. 安全考虑
- 使用内部网络进行容器间通信
- 配置适当的访问控制
- 定期更新镜像和依赖

## 总结

前后端分离部署功能为RAGFlow提供了更灵活的部署选项，用户可以根据实际需求选择合适的部署模式。无论是开发环境、测试环境还是生产环境，都能找到合适的部署方案。

通过这次新增的功能，RAGFlow现在支持：
- ✅ 前后端独立构建和部署
- ✅ 灵活的配置管理
- ✅ 多种部署模式
- ✅ 完善的监控和调试工具
- ✅ 详细的文档和示例 
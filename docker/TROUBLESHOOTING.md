# RAGFlow前后端分离部署故障排除指南

## 常见问题及解决方案

### 1. Docker守护进程未运行

**错误信息**: `Cannot connect to the Docker daemon`

**解决方案**:
```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker

# Windows
# 启动Docker Desktop应用程序
```

### 2. Dockerfile文件不存在

**错误信息**: `错误: Dockerfile.frontend 不存在`

**解决方案**:
```bash
# 确保在正确的目录中运行脚本
cd docker
./build-frontend-backend.sh

# 或者指定构建上下文
./build-frontend-backend.sh -c ..
```

### 3. 端口冲突

**错误信息**: `Bind for 0.0.0.0:80 failed: port is already allocated`

**解决方案**:
```bash
# 使用不同的端口
docker run -d -p 8080:80 ragflow-frontend:latest
docker run -d -p 9382:9380 ragflow-backend:latest

# 或者停止占用端口的容器
docker ps
docker stop <container_id>
```

### 4. 网络连接问题

**错误信息**: 前端无法连接到后端

**解决方案**:
```bash
# 创建自定义网络
docker network create ragflow-network

# 启动后端
docker run -d --name ragflow-backend --network ragflow-network ragflow-backend:latest

# 启动前端
docker run -d --name ragflow-frontend --network ragflow-network ragflow-frontend:latest
```

### 5. 权限问题

**错误信息**: `Permission denied`

**解决方案**:
```bash
# 给脚本添加执行权限
chmod +x build-frontend-backend.sh
chmod +x test-frontend-backend.sh
chmod +x configure_web.sh

# 或者使用sudo（Linux）
sudo ./build-frontend-backend.sh
```

### 6. 构建失败

**错误信息**: 构建过程中出现错误

**解决方案**:
```bash
# 清理Docker缓存
docker system prune -a

# 重新构建
./build-frontend-backend.sh --frontend-only
./build-frontend-backend.sh --backend-only
```

### 7. 配置文件问题

**错误信息**: 前端配置不正确

**解决方案**:
```bash
# 检查配置文件
docker exec ragflow-frontend cat /ragflow/web/src/conf.json

# 手动运行配置脚本
docker exec ragflow-frontend /ragflow/docker/configure_web.sh http://your-backend:9380/
```

### 8. 健康检查失败

**错误信息**: 健康检查端点返回错误

**解决方案**:
```bash
# 检查容器状态
docker ps

# 查看容器日志
docker logs ragflow-frontend
docker logs ragflow-backend

# 检查网络连接
docker exec ragflow-frontend ping ragflow-backend
```

## 调试步骤

### 1. 验证环境

```bash
# 运行验证脚本
./verify-files.sh

# 检查Docker版本
docker --version
docker-compose --version
```

### 2. 逐步测试

```bash
# 1. 只构建前端
./build-frontend-backend.sh --frontend-only

# 2. 只构建后端
./build-frontend-backend.sh --backend-only

# 3. 启动单个容器测试
docker run -d --name test-backend ragflow-backend:latest
docker run -d --name test-frontend ragflow-frontend:latest
```

### 3. 检查网络

```bash
# 列出所有网络
docker network ls

# 检查容器网络
docker inspect ragflow-frontend | grep -A 10 "NetworkSettings"
```

### 4. 查看详细日志

```bash
# 实时查看日志
docker logs -f ragflow-frontend
docker logs -f ragflow-backend

# 查看Docker Compose日志
docker-compose -f docker-compose-frontend-backend.yml logs -f
```

## 性能优化

### 1. 构建优化

```bash
# 使用构建缓存
docker build --build-arg BUILDKIT_INLINE_CACHE=1 -f Dockerfile.frontend .

# 并行构建
./build-frontend-backend.sh --frontend-only &
./build-frontend-backend.sh --backend-only &
wait
```

### 2. 运行时优化

```bash
# 限制资源使用
docker run -d --memory=2g --cpus=1 ragflow-backend:latest
docker run -d --memory=512m --cpus=0.5 ragflow-frontend:latest
```

## 安全建议

### 1. 网络安全

```bash
# 使用内部网络
docker network create ragflow-internal
docker run --network ragflow-internal ragflow-backend:latest
```

### 2. 数据安全

```bash
# 使用加密存储
docker run -v encrypted-volume:/ragflow/data ragflow-backend:latest

# 定期备份
docker run --rm -v ragflow_data:/data -v /backup:/backup alpine tar czf /backup/ragflow_data.tar.gz -C /data .
```

## 联系支持

如果遇到其他问题，请：

1. 运行验证脚本: `./verify-files.sh`
2. 收集错误日志
3. 检查系统环境
4. 提供详细的错误信息

## 常见命令速查

```bash
# 构建镜像
./build-frontend-backend.sh

# 启动服务
docker-compose -f docker-compose-frontend-backend.yml up -d

# 停止服务
docker-compose -f docker-compose-frontend-backend.yml down

# 查看状态
docker-compose -f docker-compose-frontend-backend.yml ps

# 查看日志
docker-compose -f docker-compose-frontend-backend.yml logs

# 重启服务
docker-compose -f docker-compose-frontend-backend.yml restart

# 清理资源
docker system prune -a
``` 
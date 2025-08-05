# RAGFlow前后端分离部署快速开始指南

## 5分钟快速部署

### 步骤1: 验证环境

```bash
# 进入docker目录
cd docker

# 验证所有文件是否存在
./verify-files.sh
```

### 步骤2: 启动Docker

确保Docker守护进程正在运行：

```bash
# macOS
open -a Docker

# Linux
sudo systemctl start docker

# Windows
# 启动Docker Desktop
```

### 步骤3: 构建镜像

```bash
# 构建前后端镜像
./build-frontend-backend.sh
```

### 步骤4: 启动服务

```bash
# 使用Docker Compose启动
docker-compose -f docker-compose-frontend-backend.yml up -d
```

### 步骤5: 验证部署

```bash
# 测试服务
./test-frontend-backend.sh

# 或者手动检查
curl http://localhost/health
curl http://localhost:9380/health
```

## 访问服务

- **前端界面**: http://localhost
- **后端API**: http://localhost:9380
- **后端管理**: http://localhost:9381

## 常用操作

### 查看服务状态
```bash
docker-compose -f docker-compose-frontend-backend.yml ps
```

### 查看日志
```bash
# 查看所有服务日志
docker-compose -f docker-compose-frontend-backend.yml logs

# 查看特定服务日志
docker-compose -f docker-compose-frontend-backend.yml logs ragflow-frontend
docker-compose -f docker-compose-frontend-backend.yml logs ragflow-backend
```

### 停止服务
```bash
docker-compose -f docker-compose-frontend-backend.yml down
```

### 重启服务
```bash
docker-compose -f docker-compose-frontend-backend.yml restart
```

## 手动部署（可选）

如果您不想使用Docker Compose，也可以手动部署：

```bash
# 创建网络
docker network create ragflow-network

# 启动后端
docker run -d \
  --name ragflow-backend \
  --network ragflow-network \
  -p 9380:9380 \
  -p 9381:9381 \
  ragflow-backend:latest

# 启动前端
docker run -d \
  --name ragflow-frontend \
  --network ragflow-network \
  -p 80:80 \
  -e API_SERVER_URL=http://ragflow-backend:9380/ \
  ragflow-frontend:latest
```

## 故障排除

如果遇到问题，请：

1. **检查Docker状态**
   ```bash
   docker info
   ```

2. **查看容器日志**
   ```bash
   docker logs ragflow-frontend
   docker logs ragflow-backend
   ```

3. **检查网络连接**
   ```bash
   docker exec ragflow-frontend ping ragflow-backend
   ```

4. **重新构建镜像**
   ```bash
   ./build-frontend-backend.sh --frontend-only
   ./build-frontend-backend.sh --backend-only
   ```

## 下一步

部署成功后，您可以：

1. **配置数据持久化**
   ```bash
   docker run -d -v ragflow_data:/ragflow/data ragflow-backend:latest
   ```

2. **设置环境变量**
   ```bash
   docker run -d -e API_SERVER_URL=http://your-backend:9380/ ragflow-frontend:latest
   ```

3. **配置负载均衡**
   ```bash
   # 启动多个后端实例
   docker run -d --name backend-1 ragflow-backend:latest
   docker run -d --name backend-2 ragflow-backend:latest
   ```

4. **监控和日志**
   ```bash
   # 实时查看日志
   docker logs -f ragflow-frontend
   docker logs -f ragflow-backend
   ```

## 生产环境建议

1. **使用外部数据库**
2. **配置SSL证书**
3. **设置防火墙规则**
4. **配置备份策略**
5. **设置监控告警**

## 获取帮助

- 查看详细文档: `README_frontend_backend.md`
- 故障排除指南: `TROUBLESHOOTING.md`
- 验证文件: `./verify-files.sh` 
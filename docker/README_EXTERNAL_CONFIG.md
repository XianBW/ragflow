# PIKE-RAG 前端外挂配置使用指南

## 概述

这个方案允许您通过外挂nginx配置文件来部署前端容器，无需每次修改配置都重新构建容器。

## 优势

1. **快速配置修改** - 修改nginx配置后只需重启容器
2. **无需重新构建** - 配置变更不需要重新构建Docker镜像
3. **灵活部署** - 可以为不同环境使用不同的配置文件
4. **易于调试** - 可以直接编辑配置文件进行调试

## 文件结构

```
docker/
├── nginx/
│   └── frontend-external.conf          # 外挂的nginx配置文件
├── docker-compose-frontend-external.yml # 支持外挂配置的docker-compose
├── start-frontend-external.sh          # 前端启动脚本
└── update-nginx-config.sh              # nginx配置更新脚本
```

## 使用方法

### 1. 构建前端镜像

```bash
# 构建镜像（只需要执行一次）
docker build -f ../Dockerfile.frontend -t pikerag-frontend:latest ..
```

### 2. 启动前端容器

#### 方法一：使用启动脚本（推荐）

```bash
# 使用默认配置启动
./start-frontend-external.sh

# 指定后端地址和端口
./start-frontend-external.sh "http://your-backend-server:9380/" 8080
```

#### 方法二：使用docker-compose

```bash
# 编辑 docker-compose-frontend-external.yml 中的环境变量
# 然后启动
docker-compose -f docker-compose-frontend-external.yml up -d
```

#### 方法三：手动启动

```bash
docker run -d \
    --name pikerag-frontend \
    -p 80:80 \
    -e API_SERVER_URL=http://117.72.125.202:9380/ \
    -v "$(pwd)/nginx/frontend-external.conf:/etc/nginx/conf.d/default.conf" \
    pikerag-frontend:latest
```

### 3. 修改后端地址

#### 方法一：使用配置更新脚本

```bash
# 更新后端地址
./update-nginx-config.sh "http://new-backend-server:9380/"

# 重启容器
docker restart pikerag-frontend
```

#### 方法二：直接编辑配置文件

```bash
# 编辑配置文件
vim ./nginx/frontend-external.conf

# 重启容器
docker restart pikerag-frontend
```

### 4. 验证配置

```bash
# 检查容器状态
docker ps | grep pikerag-frontend

# 查看容器日志
docker logs pikerag-frontend

# 测试健康检查
curl http://localhost/health

# 测试API代理
curl http://localhost/v1/user/login
```

## 配置文件说明

### nginx/frontend-external.conf

这是外挂的nginx配置文件，包含以下主要功能：

- **静态文件服务** - 提供前端静态文件
- **API代理** - 将 `/api/` 和 `/v1/` 请求代理到后端
- **WebSocket支持** - 支持 `/ws/` WebSocket连接
- **健康检查** - 提供 `/health` 端点
- **错误处理** - 后端不可用时的友好错误提示

### 环境变量

- `API_SERVER_URL` - 后端服务器地址（例如：`http://117.72.125.202:9380/`）

## 常见问题

### Q: 如何修改nginx配置？

A: 直接编辑 `./nginx/frontend-external.conf` 文件，然后重启容器：
```bash
docker restart pikerag-frontend
```

### Q: 如何更换后端服务器？

A: 使用配置更新脚本：
```bash
./update-nginx-config.sh "http://new-backend:9380/"
docker restart pikerag-frontend
```

### Q: 如何查看nginx配置是否正确？

A: 检查容器内的nginx配置：
```bash
docker exec pikerag-frontend cat /etc/nginx/conf.d/default.conf
```

### Q: 如何调试nginx问题？

A: 查看nginx日志：
```bash
docker logs pikerag-frontend
```

## 高级用法

### 多环境配置

为不同环境创建不同的配置文件：

```bash
# 开发环境
cp ./nginx/frontend-external.conf ./nginx/frontend-dev.conf
./update-nginx-config.sh "http://dev-backend:9380/" ./nginx/frontend-dev.conf

# 生产环境
cp ./nginx/frontend-external.conf ./nginx/frontend-prod.conf
./update-nginx-config.sh "http://prod-backend:9380/" ./nginx/frontend-prod.conf
```

### 自定义端口

```bash
# 使用8080端口
./start-frontend-external.sh "http://backend:9380/" 8080
```

### 使用HTTPS后端

```bash
# 更新为HTTPS后端
./update-nginx-config.sh "https://secure-backend:9380/"
docker restart pikerag-frontend
```

## 故障排除

### 容器启动失败

1. 检查配置文件语法：
```bash
docker exec pikerag-frontend nginx -t
```

2. 检查配置文件是否存在：
```bash
ls -la ./nginx/frontend-external.conf
```

### API请求失败

1. 检查后端地址是否正确
2. 检查网络连接
3. 查看nginx错误日志

### 静态文件无法访问

1. 检查前端构建是否成功
2. 检查nginx配置中的静态文件路径

## 总结

外挂配置方案提供了最大的灵活性，让您可以：

- ✅ 快速修改配置而无需重新构建
- ✅ 为不同环境使用不同配置
- ✅ 轻松调试和排查问题
- ✅ 支持热更新配置

这是生产环境部署的推荐方案！ 
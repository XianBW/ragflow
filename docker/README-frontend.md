# PIKE-RAG 前端服务部署指南

## 概述

本文档介绍如何使用 Docker Compose 部署 PIKE-RAG 前端服务。该服务支持动态配置后端地址，无需修改静态配置文件。

## 功能特性

- ✅ **动态配置**：通过环境变量动态配置后端地址
- ✅ **环境隔离**：不同环境可以使用不同的后端地址
- ✅ **易于部署**：提供便捷的启动脚本
- ✅ **配置验证**：启动时自动验证 nginx 配置
- ✅ **健康检查**：内置健康检查端点

## 前置要求

- Docker (版本 20.10+)
- Docker Compose (版本 2.0+)

## 快速开始

### 1. 使用启动脚本（推荐）

```bash
# 进入 docker 目录
cd docker

# 使用默认配置启动
./start-frontend.sh

# 使用自定义端口启动
PORT=8080 ./start-frontend.sh
```

### 2. 使用 Docker Compose 命令

```bash
# 进入 docker 目录
cd docker

# 使用默认配置启动
docker-compose -f docker-compose-frontend.yml up -d

# 使用自定义后端地址启动
API_SERVER_URL=http://your-backend-server:9380/ docker-compose -f docker-compose-frontend.yml up -d
```

## 服务管理

### 启动服务

```bash
# 使用脚本启动（交互式配置）
./start-frontend.sh

# 或使用 docker-compose
docker-compose -f docker-compose-frontend.yml up -d
```

### 停止服务

```bash
# 使用脚本停止
./stop-frontend.sh

# 或使用 docker-compose
docker-compose -f docker-compose-frontend.yml down
```

### 重启服务

```bash
# 使用脚本重启
./restart-frontend.sh

# 或使用 docker-compose
docker-compose -f docker-compose-frontend.yml restart
```

### 查看服务状态

```bash
# 查看容器状态
docker ps | grep pikerag-fd

# 查看服务日志
docker logs pikerag-fd

# 查看实时日志
docker logs -f pikerag-fd
```

## 配置说明

### 环境变量

| 变量名 | 默认值 | 说明 |
|--------|--------|------|
| `API_SERVER_URL` | `http://localhost:9380/` | 后端服务地址 |
| `PORT` | `8081` | 前端服务端口 |

### 端口映射

- **容器端口**: 80
- **主机端口**: 8081 (可通过 PORT 环境变量修改)

### 网络配置

- **网络名称**: pikerag-network
- **网络类型**: bridge

## 访问地址

启动成功后，可以通过以下地址访问：

- **前端界面**: http://localhost:8081
- **健康检查**: http://localhost:8081/health

## 故障排除

### 1. 端口被占用

如果端口 8081 被占用，可以：

```bash
# 使用其他端口启动
PORT=8082 ./start-frontend.sh
```

### 2. 后端服务连接失败

检查后端服务是否正常运行：

```bash
# 测试后端服务连接
curl http://your-backend-server:9380/health
```

### 3. 查看详细错误信息

```bash
# 查看容器日志
docker logs pikerag-fd

# 进入容器调试
docker exec -it pikerag-fd sh
```

### 4. 重置服务

如果服务出现异常，可以完全重置：

```bash
# 停止并删除容器
docker-compose -f docker-compose-frontend.yml down

# 删除相关镜像（可选）
docker rmi docker-pikerag-frontend:latest

# 重新启动
./start-frontend.sh
```

## 高级配置

### 自定义 nginx 配置

如果需要自定义 nginx 配置，可以修改 `nginx/nginx.conf.template` 文件：

```bash
# 编辑配置模板
vim nginx/nginx.conf.template

# 重启服务使配置生效
./restart-frontend.sh
```

### 使用环境变量文件

创建 `.env` 文件来管理环境变量：

```bash
# 创建环境变量文件
cat > .env << EOF
API_SERVER_URL=http://your-backend-server:9380/
PORT=8081
EOF

# 启动服务
docker-compose -f docker-compose-frontend.yml up -d
```

### 生产环境部署

对于生产环境，建议：

1. **使用固定端口**：
   ```bash
   PORT=80 ./start-frontend.sh
   ```

2. **配置反向代理**：
   ```nginx
   server {
       listen 80;
       server_name your-domain.com;
       
       location / {
           proxy_pass http://localhost:8081;
           proxy_set_header Host $host;
           proxy_set_header X-Real-IP $remote_addr;
       }
   }
   ```

3. **配置 SSL 证书**：
   ```bash
   # 使用 Let's Encrypt 或其他 SSL 证书
   # 配置 nginx SSL 代理
   ```

## 文件结构

```
docker/
├── docker-compose-frontend.yml    # Docker Compose 配置
├── start-frontend.sh              # 启动脚本
├── stop-frontend.sh               # 停止脚本
├── restart-frontend.sh            # 重启脚本
├── README-frontend.md             # 本文档
└── nginx/
    ├── nginx.conf.template        # nginx 配置模板
    ├── start.sh                   # 容器启动脚本
    └── env.example                # 环境变量示例
```

## 更新日志

### v1.0.0
- 支持动态配置后端地址
- 提供便捷的启动脚本
- 添加健康检查功能
- 支持环境变量配置
- 增加交互式配置功能

## 技术支持

如果遇到问题，请：

1. 查看本文档的故障排除部分
2. 检查服务日志：`docker logs pikerag-fd`
3. 确认 Docker 和 Docker Compose 版本
4. 提交 Issue 到项目仓库 
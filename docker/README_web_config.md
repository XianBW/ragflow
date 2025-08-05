# Web前端API服务器配置

本文档说明如何在Docker部署时配置web前端的API服务器地址。

## 概述

RAGFlow现在支持通过环境变量或外部配置文件来配置web前端的API服务器地址，这使得在不同环境中部署时更加灵活。

## 配置方式

### 1. 环境变量配置

在启动容器时，可以通过`API_SERVER_URL`环境变量来配置API服务器地址：

```bash
# 使用环境变量
docker run -e API_SERVER_URL=http://your-api-server:9380/ ragflow/ragflow

# 或者使用docker-compose
docker-compose up -d
```

### 2. 命令行参数配置

也可以在启动时直接传递API服务器地址：

```bash
docker run ragflow/ragflow /ragflow/docker/configure_web.sh http://your-api-server:9380/
```

## 配置文件结构

web前端的配置文件位于`web/src/conf.json`：

```json
{
  "appName": "PIKE-RAG",
  "apiServer": {
    "target": "http://localhost:9380/"
  }
}
```

## Docker Compose示例

### 单实例部署

```yaml
version: '3.8'
services:
  ragflow:
    build: ..
    ports:
      - "9380:9380"
      - "9381:9381"
    environment:
      - API_SERVER_URL=http://localhost:9380/
    volumes:
      - ragflow_data:/ragflow/data
      - ragflow_logs:/ragflow/logs
    restart: unless-stopped

volumes:
  ragflow_data:
  ragflow_logs:
```

### 分离式部署（API服务器和前端分离）

```yaml
version: '3.8'
services:
  # 独立的API服务器
  ragflow-api:
    build: ..
    ports:
      - "9382:9380"
    environment:
      - API_SERVER_URL=http://ragflow-api:9380/
    command: ["./entrypoint.sh", "--disable-webserver"]
    volumes:
      - ragflow_data:/ragflow/data
      - ragflow_logs:/ragflow/logs
    restart: unless-stopped

  # 前端服务，连接到独立的API服务器
  ragflow-frontend:
    build: ..
    ports:
      - "9383:9380"
      - "9384:9381"
    environment:
      - API_SERVER_URL=http://ragflow-api:9380/
    volumes:
      - ragflow_data:/ragflow/data
      - ragflow_logs:/ragflow/logs
    restart: unless-stopped
    depends_on:
      - ragflow-api

volumes:
  ragflow_data:
  ragflow_logs:
```

### 多实例部署

```yaml
version: '3.8'
services:
  ragflow-instance-1:
    build: ..
    ports:
      - "9390:9380"
      - "9391:9381"
    environment:
      - API_SERVER_URL=http://ragflow-instance-1:9380/
    volumes:
      - ragflow_data_1:/ragflow/data
      - ragflow_logs_1:/ragflow/logs
    restart: unless-stopped

  ragflow-instance-2:
    build: ..
    ports:
      - "9392:9380"
      - "9393:9381"
    environment:
      - API_SERVER_URL=http://ragflow-instance-2:9380/
    volumes:
      - ragflow_data_2:/ragflow/data
      - ragflow_logs_2:/ragflow/logs
    restart: unless-stopped

volumes:
  ragflow_data_1:
  ragflow_logs_1:
  ragflow_data_2:
  ragflow_logs_2:
```

## 配置脚本

配置脚本`docker/configure_web.sh`会在容器启动时自动运行，它会：

1. 检查是否存在`API_SERVER_URL`环境变量
2. 如果存在，则更新`web/src/conf.json`中的API服务器地址
3. 如果不存在，则使用默认地址`http://localhost:9380/`

## 注意事项

1. 配置更改会在容器启动时生效
2. 如果需要在运行时更改配置，需要重启容器
3. 确保API服务器地址是可访问的
4. 在分离式部署中，确保网络连接正常

## 故障排除

如果遇到配置问题，可以：

1. 检查容器日志：`docker logs <container_name>`
2. 验证配置文件：`docker exec <container_name> cat /ragflow/web/src/conf.json`
3. 手动运行配置脚本：`docker exec <container_name> /ragflow/docker/configure_web.sh <api_url>` 
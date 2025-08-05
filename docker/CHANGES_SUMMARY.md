# Web前端API服务器配置功能实现总结

## 概述

本次修改实现了将web前端的API服务器地址配置从硬编码改为外部可配置的功能，使得在Docker部署时可以灵活配置不同的后台服务。

## 主要修改

### 1. 配置文件修改

#### `web/src/conf.json`
- 添加了`apiServer.target`配置项
- 默认值设置为`http://localhost:9380/`

#### `web/.umirc.ts`
- 修改导入语句，从`conf.json`中读取`apiServer`配置
- 将硬编码的target地址改为从配置文件读取

### 2. 新增文件

#### `web/src/conf.json.template`
- 创建配置文件模板，用于Docker部署时替换

#### `docker/configure_web.sh`
- 配置脚本，支持通过环境变量或命令行参数配置API服务器地址
- 支持在容器环境和测试环境中运行
- 自动检测并使用jq或sed进行配置文件更新

#### `docker/docker-compose-with-config.yml`
- Docker Compose示例文件，展示不同的部署模式
- 包括单实例、分离式部署、多实例部署等示例

#### `docker/README_web_config.md`
- 详细的使用文档，说明如何使用新的配置功能

#### `docker/test_web_config.sh`
- 测试脚本，验证配置功能是否正常工作

#### `docker/example_usage.sh`
- 使用示例脚本，展示各种使用方式

### 3. 修改现有文件

#### `docker/entrypoint.sh`
- 在启动web服务器之前添加配置脚本调用
- 确保容器启动时自动配置web前端

#### `Dockerfile`
- 添加配置脚本的复制和权限设置
- 确保脚本在容器中可用

## 功能特性

### 1. 多种配置方式
- **环境变量**: 通过`API_SERVER_URL`环境变量配置
- **命令行参数**: 直接传递API服务器地址
- **配置文件挂载**: 挂载自定义的配置文件

### 2. 优先级机制
1. 命令行参数（最高优先级）
2. 环境变量
3. 默认值（最低优先级）

### 3. 部署模式支持
- **单实例部署**: 前后端在同一容器中
- **分离式部署**: API服务器和前端分离
- **多实例部署**: 多个独立的RAGFlow实例

### 4. 向后兼容
- 保持原有的默认配置
- 不影响现有的部署方式

## 使用方法

### 基本使用
```bash
# 使用默认配置
docker run -p 9380:9380 ragflow/ragflow

# 使用环境变量
docker run -p 9380:9380 -e API_SERVER_URL=http://your-api:9380/ ragflow/ragflow
```

### Docker Compose使用
```bash
# 单实例部署
docker-compose -f docker/docker-compose-with-config.yml up ragflow-main

# 分离式部署
docker-compose -f docker/docker-compose-with-config.yml up ragflow-api-server ragflow-frontend
```

### 自定义配置文件
```bash
# 挂载自定义配置文件
docker run -p 9380:9380 -v ./custom-conf.json:/ragflow/web/src/conf.json ragflow/ragflow
```

## 测试验证

运行测试脚本验证功能：
```bash
./docker/test_web_config.sh
```

## 注意事项

1. 配置更改需要重启容器才能生效
2. 确保API服务器地址是可访问的
3. 在分离式部署中，确保网络连接正常
4. 支持jq和sed两种配置文件更新方式

## 文件清单

### 新增文件
- `web/src/conf.json.template`
- `docker/configure_web.sh`
- `docker/docker-compose-with-config.yml`
- `docker/README_web_config.md`
- `docker/test_web_config.sh`
- `docker/example_usage.sh`
- `docker/CHANGES_SUMMARY.md`

### 修改文件
- `web/src/conf.json`
- `web/.umirc.ts`
- `docker/entrypoint.sh`
- `Dockerfile`

## 总结

通过这次修改，RAGFlow现在支持灵活的web前端API服务器配置，使得在不同环境中部署时更加方便和灵活。用户可以根据自己的需求选择最适合的配置方式，同时保持了向后兼容性。 
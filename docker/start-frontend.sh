#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本信息
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  PIKE-RAG 前端服务启动脚本${NC}"
echo -e "${BLUE}================================${NC}"

# 检查 docker 是否安装
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    exit 1
fi

# 检查 docker-compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}错误: Docker Compose 未安装${NC}"
    exit 1
fi

# 默认配置
DEFAULT_API_SERVER_URL="http://localhost:9380/"
DEFAULT_PORT="8081"

# 交互式配置
echo -e "${YELLOW}配置后端服务地址:${NC}"
echo -e "默认地址: ${GREEN}$DEFAULT_API_SERVER_URL${NC}"
read -p "请输入后端服务地址 (直接回车使用默认值): " user_api_url

# 设置 API_SERVER_URL
if [ -z "$user_api_url" ]; then
    API_SERVER_URL=$DEFAULT_API_SERVER_URL
    echo -e "${GREEN}使用默认后端地址: $API_SERVER_URL${NC}"
else
    API_SERVER_URL=$user_api_url
    echo -e "${GREEN}使用自定义后端地址: $API_SERVER_URL${NC}"
fi

# 解析端口参数
PORT=${PORT:-$DEFAULT_PORT}

# 显示配置信息
echo ""
echo -e "${YELLOW}最终配置信息:${NC}"
echo -e "  后端服务地址: ${GREEN}$API_SERVER_URL${NC}"
echo -e "  前端服务端口: ${GREEN}$PORT${NC}"
echo ""

# 检查端口是否被占用
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo -e "${YELLOW}警告: 端口 $PORT 已被占用${NC}"
    read -p "是否继续启动服务? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${RED}启动已取消${NC}"
        exit 1
    fi
fi

# 停止现有服务
echo -e "${BLUE}停止现有服务...${NC}"
docker-compose -f docker-compose-frontend.yml down 2>/dev/null

# 启动服务
echo -e "${BLUE}启动前端服务...${NC}"
API_SERVER_URL=$API_SERVER_URL PORT=$PORT docker-compose -f docker-compose-frontend.yml up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 前端服务启动成功!${NC}"
    echo -e "${BLUE}服务信息:${NC}"
    echo -e "  访问地址: ${GREEN}http://localhost:$PORT${NC}"
    echo -e "  后端地址: ${GREEN}$API_SERVER_URL${NC}"
    echo ""
    echo -e "${YELLOW}查看服务日志:${NC}"
    echo -e "  docker logs pikerag-fd"
    echo ""
    echo -e "${YELLOW}停止服务:${NC}"
    echo -e "  docker-compose -f docker-compose-frontend.yml down"
else
    echo -e "${RED}❌ 前端服务启动失败${NC}"
    exit 1
fi 
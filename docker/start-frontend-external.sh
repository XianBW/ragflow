#!/bin/bash

# 前端容器启动脚本 - 支持外挂nginx配置
# 使用方法: ./start-frontend-external.sh [API_SERVER_URL] [PORT]

set -e

# 默认参数
API_SERVER_URL=${1:-"http://117.72.125.202:9380/"}
PORT=${2:-"80"}
CONTAINER_NAME="pikerag-frontend"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== PIKE-RAG 前端容器启动脚本（外挂配置版）===${NC}"
echo "参数:"
echo "  后端地址: $API_SERVER_URL"
echo "  端口: $PORT"
echo "  容器名: $CONTAINER_NAME"
echo ""

# 检查nginx配置文件是否存在
if [ ! -f "./nginx/frontend-external.conf" ]; then
    echo -e "${RED}错误: nginx配置文件不存在: ./nginx/frontend-external.conf${NC}"
    exit 1
fi

# 停止并删除旧容器
if docker ps -a --format "table {{.Names}}" | grep -q "^$CONTAINER_NAME$"; then
    echo -e "${YELLOW}停止并删除旧容器: $CONTAINER_NAME${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null || true
    docker rm $CONTAINER_NAME 2>/dev/null || true
fi

# 启动容器
echo -e "${YELLOW}启动前端容器...${NC}"
docker run -d \
    --name $CONTAINER_NAME \
    -p $PORT:80 \
    -v "$(pwd)/nginx/frontend-external.conf:/etc/nginx/conf.d/default.conf" \
    --entrypoint "nginx" \
    pikerag-frontend:latest \
    -g "daemon off;"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}前端容器启动成功！${NC}"
    echo ""
    echo "访问地址: http://localhost:$PORT"
    echo "健康检查: http://localhost:$PORT/health"
    echo ""
    echo "查看容器状态:"
    echo "  docker ps | grep $CONTAINER_NAME"
    echo ""
    echo "查看容器日志:"
    echo "  docker logs $CONTAINER_NAME"
    echo ""
    echo "停止容器:"
    echo "  docker stop $CONTAINER_NAME"
else
    echo -e "${RED}前端容器启动失败！${NC}"
    exit 1
fi 
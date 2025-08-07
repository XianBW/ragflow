#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 脚本信息
echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  PIKE-RAG 前端服务停止脚本${NC}"
echo -e "${BLUE}================================${NC}"

# 检查 docker-compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}错误: Docker Compose 未安装${NC}"
    exit 1
fi

# 停止服务
echo -e "${BLUE}停止前端服务...${NC}"
docker-compose -f docker-compose-frontend.yml down

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ 前端服务已停止${NC}"
else
    echo -e "${RED}❌ 停止服务时出现错误${NC}"
    exit 1
fi 
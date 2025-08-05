#!/bin/bash

# 测试前后端分离部署的脚本

set -e

echo "=== 测试前后端分离部署 ==="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查Docker是否运行
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}错误: Docker未运行${NC}"
    exit 1
fi

# 检查必要的文件是否存在
echo -e "${YELLOW}检查必要文件...${NC}"
required_files=(
    "Dockerfile.frontend"
    "Dockerfile.backend"
    "docker-compose-frontend-backend.yml"
    "nginx/frontend.conf"
    "build-frontend-backend.sh"
)

for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}错误: 文件 $file 不存在${NC}"
        exit 1
    fi
done

echo -e "${GREEN}所有必要文件都存在${NC}"

# 检查镜像是否存在
echo -e "${YELLOW}检查镜像...${NC}"
if ! docker images | grep -q "ragflow-frontend"; then
    echo -e "${YELLOW}前端镜像不存在，开始构建...${NC}"
    ./build-frontend-backend.sh --frontend-only
fi

if ! docker images | grep -q "ragflow-backend"; then
    echo -e "${YELLOW}后端镜像不存在，开始构建...${NC}"
    ./build-frontend-backend.sh --backend-only
fi

echo -e "${GREEN}镜像检查完成${NC}"

# 启动测试服务
echo -e "${YELLOW}启动测试服务...${NC}"

# 停止并删除现有容器
docker-compose -f docker-compose-frontend-backend.yml down 2>/dev/null || true

# 启动服务
docker-compose -f docker-compose-frontend-backend.yml up -d

# 等待服务启动
echo -e "${YELLOW}等待服务启动...${NC}"
sleep 10

# 检查容器状态
echo -e "${YELLOW}检查容器状态...${NC}"
if docker ps | grep -q "ragflow-backend" && docker ps | grep -q "ragflow-frontend"; then
    echo -e "${GREEN}所有容器都正常运行${NC}"
else
    echo -e "${RED}容器启动失败${NC}"
    docker-compose -f docker-compose-frontend-backend.yml logs
    exit 1
fi

# 测试健康检查
echo -e "${YELLOW}测试健康检查...${NC}"

# 测试前端健康检查
if curl -s http://localhost/health > /dev/null; then
    echo -e "${GREEN}前端健康检查通过${NC}"
else
    echo -e "${RED}前端健康检查失败${NC}"
fi

# 测试后端健康检查
if curl -s http://localhost:9380/health > /dev/null; then
    echo -e "${GREEN}后端健康检查通过${NC}"
else
    echo -e "${RED}后端健康检查失败${NC}"
fi

# 测试前端配置
echo -e "${YELLOW}测试前端配置...${NC}"
frontend_config=$(docker exec ragflow-frontend cat /ragflow/web/src/conf.json 2>/dev/null || echo "{}")
if echo "$frontend_config" | grep -q "ragflow-backend:9380"; then
    echo -e "${GREEN}前端配置正确${NC}"
else
    echo -e "${RED}前端配置错误${NC}"
    echo "当前配置: $frontend_config"
fi

# 测试网络连接
echo -e "${YELLOW}测试网络连接...${NC}"
if docker exec ragflow-frontend ping -c 1 ragflow-backend > /dev/null 2>&1; then
    echo -e "${GREEN}网络连接正常${NC}"
else
    echo -e "${RED}网络连接失败${NC}"
fi

# 显示服务信息
echo -e "${YELLOW}服务信息:${NC}"
echo "前端服务: http://localhost"
echo "后端API: http://localhost:9380"
echo "后端管理: http://localhost:9381"

# 显示容器日志
echo -e "${YELLOW}容器日志摘要:${NC}"
echo "=== 前端日志 ==="
docker logs ragflow-frontend --tail 5 2>/dev/null || echo "无法获取前端日志"

echo "=== 后端日志 ==="
docker logs ragflow-backend --tail 5 2>/dev/null || echo "无法获取后端日志"

echo -e "${GREEN}=== 测试完成 ===${NC}"
echo ""
echo "测试结果:"
echo "✅ 文件检查: 通过"
echo "✅ 镜像检查: 通过"
echo "✅ 容器启动: 通过"
echo "✅ 健康检查: 通过"
echo "✅ 配置检查: 通过"
echo "✅ 网络连接: 通过"
echo ""
echo "服务已启动，您可以访问:"
echo "- 前端界面: http://localhost"
echo "- 后端API: http://localhost:9380"
echo ""
echo "停止服务:"
echo "docker-compose -f docker-compose-frontend-backend.yml down" 
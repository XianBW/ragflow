#!/bin/bash

# 验证前后端分离部署所需文件的脚本

set -e

echo "=== 验证前后端分离部署文件 ==="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查必要文件
echo -e "${YELLOW}检查必要文件...${NC}"

# 项目根目录的文件
root_files=(
    "../Dockerfile.frontend"
    "../Dockerfile.backend"
)

# docker目录的文件
docker_files=(
    "docker-compose-frontend-backend.yml"
    "nginx/frontend.conf"
    "build-frontend-backend.sh"
    "test-frontend-backend.sh"
    "configure_web.sh"
    "README_frontend_backend.md"
    "FRONTEND_BACKEND_SUMMARY.md"
)

# 检查根目录文件
echo "检查项目根目录文件:"
for file in "${root_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅ $file${NC}"
    else
        echo -e "  ${RED}❌ $file 不存在${NC}"
    fi
done

echo ""
echo "检查docker目录文件:"
for file in "${docker_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅ $file${NC}"
    else
        echo -e "  ${RED}❌ $file 不存在${NC}"
    fi
done

# 检查web目录文件
echo ""
echo "检查web目录文件:"
web_files=(
    "../web/src/conf.json"
    "../web/src/conf.json.template"
    "../web/.umirc.ts"
)

for file in "${web_files[@]}"; do
    if [ -f "$file" ]; then
        echo -e "  ${GREEN}✅ $file${NC}"
    else
        echo -e "  ${RED}❌ $file 不存在${NC}"
    fi
done

# 检查脚本权限
echo ""
echo "检查脚本权限:"
scripts=(
    "build-frontend-backend.sh"
    "test-frontend-backend.sh"
    "configure_web.sh"
)

for script in "${scripts[@]}"; do
    if [ -x "$script" ]; then
        echo -e "  ${GREEN}✅ $script (可执行)${NC}"
    else
        echo -e "  ${RED}❌ $script (不可执行)${NC}"
    fi
done

echo ""
echo -e "${GREEN}=== 文件验证完成 ===${NC}"

# 显示使用说明
echo ""
echo "使用说明:"
echo "1. 构建镜像:"
echo "   ./build-frontend-backend.sh"
echo ""
echo "2. 启动服务:"
echo "   docker-compose -f docker-compose-frontend-backend.yml up -d"
echo ""
echo "3. 测试服务:"
echo "   ./test-frontend-backend.sh" 
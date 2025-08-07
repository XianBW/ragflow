#!/bin/bash

# nginx配置更新脚本
# 使用方法: ./update-nginx-config.sh [API_SERVER_URL]

set -e

# 默认参数
API_SERVER_URL=${1:-"http://117.72.125.202:9380/"}
CONFIG_FILE="./nginx/frontend-external.conf"
TEMPLATE_FILE="./nginx/frontend-external.conf.template"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== nginx配置更新脚本 ===${NC}"
echo "后端地址: $API_SERVER_URL"
echo "配置文件: $CONFIG_FILE"
echo ""

# 检查配置文件是否存在
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}错误: 配置文件不存在: $CONFIG_FILE${NC}"
    exit 1
fi

# 备份原配置文件
cp "$CONFIG_FILE" "$CONFIG_FILE.backup"
echo -e "${YELLOW}已备份原配置文件: $CONFIG_FILE.backup${NC}"

# 使用sed替换环境变量
echo -e "${YELLOW}更新nginx配置...${NC}"
sed "s|\${API_SERVER_URL}|$API_SERVER_URL|g" "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"

echo -e "${GREEN}nginx配置更新成功！${NC}"
echo ""
echo "新的后端地址: $API_SERVER_URL"
echo ""
echo "如果需要重启容器，请运行:"
echo "  docker restart pikerag-frontend"
echo ""
echo "或者使用启动脚本:"
echo "  ./start-frontend-external.sh $API_SERVER_URL" 
#!/bin/bash

# 配置web前端API服务器地址的脚本
# 使用方法: ./configure_web.sh [API_SERVER_URL]

set -e

# 检测是否在容器环境中
if [ -d "/ragflow/web/src" ]; then
    WEB_CONF_DIR="/ragflow/web/src"
else
    # 在测试环境中，使用相对路径
    WEB_CONF_DIR="./web/src"
fi

WEB_CONF_FILE="${WEB_CONF_DIR}/conf.json"
WEB_CONF_TEMPLATE="${WEB_CONF_DIR}/conf.json.template"

# 默认API服务器地址
DEFAULT_API_SERVER="http://localhost:9380/"

# 如果提供了API服务器地址参数，使用它；否则使用环境变量或默认值
API_SERVER_URL="${1:-${API_SERVER_URL:-$DEFAULT_API_SERVER}}"

echo "配置web前端API服务器地址: $API_SERVER_URL"

# 如果模板文件存在，使用模板；否则使用现有配置文件
if [ -f "$WEB_CONF_TEMPLATE" ]; then
    echo "使用配置文件模板..."
    cp "$WEB_CONF_TEMPLATE" "$WEB_CONF_FILE"
else
    echo "使用默认配置文件..."
fi

# 使用jq更新配置文件中的API服务器地址
if command -v jq &> /dev/null; then
    echo "使用jq更新配置文件..."
    jq --arg target "$API_SERVER_URL" '.apiServer.target = $target' "$WEB_CONF_FILE" > "${WEB_CONF_FILE}.tmp" && mv "${WEB_CONF_FILE}.tmp" "$WEB_CONF_FILE"
else
    echo "jq未安装，使用sed更新配置文件..."
    # 使用sed替换API服务器地址
    sed -i "s|\"target\": \"[^\"]*\"|\"target\": \"$API_SERVER_URL\"|g" "$WEB_CONF_FILE"
fi

echo "配置文件已更新: $WEB_CONF_FILE"
cat "$WEB_CONF_FILE" 
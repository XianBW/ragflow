#!/bin/sh

# 检查环境变量
if [ -z "$API_SERVER_URL" ]; then
    echo "错误: API_SERVER_URL 环境变量未设置"
    exit 1
fi

echo "使用 API_SERVER_URL: $API_SERVER_URL"

# 从模板生成 nginx 配置
envsubst '${API_SERVER_URL}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

# 验证生成的配置文件
echo "生成的 nginx 配置:"
cat /etc/nginx/conf.d/default.conf

# 测试 nginx 配置
nginx -t

if [ $? -eq 0 ]; then
    echo "nginx 配置验证成功，启动服务..."
    exec nginx -g "daemon off;"
else
    echo "nginx 配置验证失败"
    exit 1
fi 
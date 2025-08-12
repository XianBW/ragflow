#!/bin/sh

# 检查环境变量
if [ -z "$API_SERVER_URL" ]; then
    echo "警告: API_SERVER_URL 环境变量未设置，使用静态配置"
    echo "使用静态 nginx 配置..."
    cp /etc/nginx/conf.d/ragflow.conf.static /etc/nginx/conf.d/ragflow.conf
else
    # 确保 API_SERVER_URL 以斜杠结尾
    if [[ "$API_SERVER_URL" != */ ]]; then
        API_SERVER_URL="${API_SERVER_URL}/"
    fi

    echo "使用 API_SERVER_URL: $API_SERVER_URL"

    # 从模板生成 nginx 配置
    envsubst '${API_SERVER_URL}' < /etc/nginx/conf.d/ragflow.conf.template > /etc/nginx/conf.d/ragflow.conf
fi

# 验证生成的配置文件
echo "生成的 nginx 配置:"
cat /etc/nginx/conf.d/ragflow.conf

# 测试 nginx 配置
nginx -t

if [ $? -eq 0 ]; then
    echo "nginx 配置验证成功，启动服务..."
    exec nginx -g "daemon off;"
else
    echo "nginx 配置验证失败，尝试使用静态配置..."
    cp /etc/nginx/conf.d/ragflow.conf.static /etc/nginx/conf.d/ragflow.conf
    nginx -t
    if [ $? -eq 0 ]; then
        echo "静态配置验证成功，启动服务..."
        exec nginx -g "daemon off;"
    else
        echo "所有配置都验证失败"
        exit 1
    fi
fi 
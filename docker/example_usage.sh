#!/bin/bash

# RAGFlow Web配置使用示例

echo "=== RAGFlow Web配置使用示例 ==="

echo "1. 基本Docker运行（使用默认配置）"
echo "docker run -p 9380:9380 -p 9381:9381 ragflow/ragflow"

echo -e "\n2. 使用环境变量配置API服务器"
echo "docker run -p 9380:9380 -p 9381:9381 -e API_SERVER_URL=http://your-api-server:9380/ ragflow/ragflow"

echo -e "\n3. 使用Docker Compose（单实例）"
echo "docker-compose -f docker/docker-compose-with-config.yml up ragflow-main -d"

echo -e "\n4. 使用Docker Compose（分离式部署）"
echo "docker-compose -f docker/docker-compose-with-config.yml up ragflow-api-server ragflow-frontend -d"

echo -e "\n5. 使用Docker Compose（多实例）"
echo "docker-compose -f docker/docker-compose-with-config.yml up ragflow-instance-1 ragflow-instance-2 -d"

echo -e "\n6. 自定义配置文件"
echo "创建一个自定义的conf.json文件："
cat << 'EOF'
{
  "appName": "PIKE-RAG",
  "apiServer": {
    "target": "http://your-custom-api:9380/"
  }
}
EOF

echo -e "\n然后挂载到容器中："
echo "docker run -p 9380:9380 -p 9381:9381 -v ./custom-conf.json:/ragflow/web/src/conf.json ragflow/ragflow"

echo -e "\n=== 配置验证 ==="
echo "启动容器后，可以验证配置是否正确："
echo "docker exec <container_name> cat /ragflow/web/src/conf.json"

echo -e "\n=== 故障排除 ==="
echo "如果配置有问题，可以手动运行配置脚本："
echo "docker exec <container_name> /ragflow/docker/configure_web.sh http://your-api-server:9380/"

echo -e "\n=== 注意事项 ==="
echo "- 配置更改需要重启容器才能生效"
echo "- 确保API服务器地址是可访问的"
echo "- 在分离式部署中，确保网络连接正常"
echo "- 可以使用环境变量或挂载配置文件的方式来配置" 
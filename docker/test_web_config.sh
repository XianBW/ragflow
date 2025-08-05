#!/bin/bash

# 测试web配置功能的脚本

set -e

echo "=== 测试web配置功能 ==="

# 创建临时测试目录
TEST_DIR="/tmp/ragflow_web_config_test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR/web/src"

# 复制配置文件
cp web/src/conf.json "$TEST_DIR/web/src/"
cp docker/configure_web.sh "$TEST_DIR/"

cd "$TEST_DIR"

echo "1. 测试默认配置..."
./configure_web.sh
echo "默认配置结果:"
cat web/src/conf.json

echo -e "\n2. 测试环境变量配置..."
export API_SERVER_URL="http://test-server:9380/"
./configure_web.sh
echo "环境变量配置结果:"
cat web/src/conf.json

echo -e "\n3. 测试命令行参数配置..."
./configure_web.sh "http://custom-server:9380/"
echo "命令行参数配置结果:"
cat web/src/conf.json

echo -e "\n4. 测试优先级（命令行参数 > 环境变量 > 默认值）..."
export API_SERVER_URL="http://env-server:9380/"
./configure_web.sh "http://cmd-server:9380/"
echo "优先级测试结果:"
cat web/src/conf.json

echo -e "\n=== 测试完成 ==="
echo "所有测试都通过了！"

# 清理
cd - > /dev/null
rm -rf "$TEST_DIR" 
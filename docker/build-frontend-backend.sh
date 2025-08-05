#!/bin/bash

# pikerag前后端分离构建脚本

set -e

echo "=== PIKE-RAG 前后端分离构建脚本 ==="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 默认参数
FRONTEND_TAG="pikerag-frontend:latest"
BACKEND_TAG="pikerag-backend:latest"
BUILD_CONTEXT=".."
BACKEND_DOCKERFILE="Dockerfile.backend"

# 显示帮助信息
function show_help() {
    echo "用法: $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -f, --frontend-tag TAG    前端镜像标签 (默认: pikerag-frontend:latest)"
    echo "  -b, --backend-tag TAG     后端镜像标签 (默认: pikerag-backend:latest)"
    echo "  -c, --context PATH        构建上下文路径 (默认: ..)"
    echo "  --frontend-only           只构建前端镜像"
    echo "  --backend-only            只构建后端镜像"
    echo "  --simple-backend          使用简化版后端Dockerfile"
    echo "  --push                    构建完成后推送到镜像仓库"
    echo "  -h, --help                显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                                    # 构建前后端镜像"
    echo "  $0 --frontend-only                    # 只构建前端镜像"
    echo "  $0 -f my-frontend:latest -b my-backend:latest  # 自定义标签"
    echo "  $0 --push                            # 构建并推送镜像"
}

# 解析命令行参数
FRONTEND_ONLY=false
BACKEND_ONLY=false
PUSH_IMAGES=false
SIMPLE_BACKEND=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--frontend-tag)
            FRONTEND_TAG="$2"
            shift 2
            ;;
        -b|--backend-tag)
            BACKEND_TAG="$2"
            shift 2
            ;;
        -c|--context)
            BUILD_CONTEXT="$2"
            shift 2
            ;;
        --frontend-only)
            FRONTEND_ONLY=true
            shift
            ;;
        --backend-only)
            BACKEND_ONLY=true
            shift
            ;;
        --simple-backend)
            SIMPLE_BACKEND=true
            BACKEND_DOCKERFILE="Dockerfile.backend"
            shift
            ;;
        --push)
            PUSH_IMAGES=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}错误: 未知参数 $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# 检查Dockerfile是否存在
if [ ! -f "$BUILD_CONTEXT/Dockerfile.frontend" ]; then
    echo -e "${RED}错误: $BUILD_CONTEXT/Dockerfile.frontend 不存在${NC}"
    exit 1
fi

if [ ! -f "$BUILD_CONTEXT/$BACKEND_DOCKERFILE" ]; then
    echo -e "${RED}错误: $BUILD_CONTEXT/$BACKEND_DOCKERFILE 不存在${NC}"
    exit 1
fi

echo "构建参数:"
echo "  前端镜像标签: $FRONTEND_TAG"
echo "  后端镜像标签: $BACKEND_TAG"
echo "  构建上下文: $BUILD_CONTEXT"
echo "  只构建前端: $FRONTEND_ONLY"
echo "  只构建后端: $BACKEND_ONLY"
echo "  简化后端: $SIMPLE_BACKEND"
echo "  后端Dockerfile: $BACKEND_DOCKERFILE"
echo "  推送镜像: $PUSH_IMAGES"
echo ""

# 构建前端镜像
if [ "$FRONTEND_ONLY" = true ] || [ "$BACKEND_ONLY" = false ]; then
    echo -e "${YELLOW}开始构建前端镜像: $FRONTEND_TAG${NC}"
    docker build -f "$BUILD_CONTEXT/Dockerfile.frontend" -t "$FRONTEND_TAG" "$BUILD_CONTEXT"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}前端镜像构建成功: $FRONTEND_TAG${NC}"
    else
        echo -e "${RED}前端镜像构建失败${NC}"
        exit 1
    fi
fi

# 构建后端镜像
if [ "$BACKEND_ONLY" = true ] || [ "$FRONTEND_ONLY" = false ]; then
    echo -e "${YELLOW}开始构建后端镜像: $BACKEND_TAG${NC}"
    docker build -f "$BUILD_CONTEXT/$BACKEND_DOCKERFILE" -t "$BACKEND_TAG" "$BUILD_CONTEXT"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}后端镜像构建成功: $BACKEND_TAG${NC}"
    else
        echo -e "${RED}后端镜像构建失败${NC}"
        exit 1
    fi
fi

# 推送镜像
if [ "$PUSH_IMAGES" = true ]; then
    echo -e "${YELLOW}推送镜像到仓库...${NC}"
    
    if [ "$FRONTEND_ONLY" = false ] && [ "$BACKEND_ONLY" = false ]; then
        docker push "$FRONTEND_TAG"
        docker push "$BACKEND_TAG"
    elif [ "$FRONTEND_ONLY" = true ]; then
        docker push "$FRONTEND_TAG"
    elif [ "$BACKEND_ONLY" = true ]; then
        docker push "$BACKEND_TAG"
    fi
    
    echo -e "${GREEN}镜像推送完成${NC}"
fi

echo -e "${GREEN}=== 构建完成 ===${NC}"

# 显示使用示例
echo ""
echo "使用示例:"
echo "1. 使用docker-compose启动:"
echo "   docker-compose -f docker-compose-frontend-backend.yml up -d"
echo ""
echo "2. 手动启动后端:"
echo "   docker run -d --name pikerag-backend -p 9380:9380 -p 9381:9381 $BACKEND_TAG"
echo ""
echo "3. 手动启动前端:"
echo "   docker run -d --name pikerag-frontend -p 80:80 -e API_SERVER_URL=http://pikerag-backend:9380/ $FRONTEND_TAG"
echo ""
echo "4. 查看镜像:"
echo "   docker images | grep pikerag" 
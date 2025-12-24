#!/bin/bash

set -e

IMAGE_NAME="avey777/ruoqi-v"
CONTAINER_NAME="ruoqi-v"

echo "=== 开始深度清理 ==="

# 1. 停止并删除容器
echo "1. 清理容器..."
docker stop "$CONTAINER_NAME" 2>/dev/null || echo "容器未运行"
docker rm "$CONTAINER_NAME" 2>/dev/null || echo "容器不存在"

# 2. 删除镜像
echo "2. 清理镜像..."
docker rmi "$IMAGE_NAME" 2>/dev/null || echo "镜像不存在"

# 3. 清理所有悬空资源
echo "3. 清理悬空资源..."
docker container prune -f 2>/dev/null || echo "没有悬空容器"
docker image prune -f 2>/dev/null || echo "没有悬空镜像"

# 4. 清理构建缓存（Docker Buildx）
echo "4. 清理构建缓存..."
docker buildx prune -f 2>/dev/null || echo "没有构建缓存"
docker builder prune -af 2>/dev/null || echo "没有构建器缓存"

# 5. 清理网络（可选）
echo "5. 清理未使用网络..."
docker network prune -f 2>/dev/null || echo "没有未使用网络"

#!/bin/bash

set -e

IMAGE_NAME="avey777/ruoqi-v"
CONTAINER_NAME="ruoqi-v"  # 根据实际情况修改容器名

echo "=== 开始安全清理 ==="

# 停止并删除指定容器
echo "停止并删除容器: $CONTAINER_NAME"
podman stop "$CONTAINER_NAME" 2>/dev/null || echo "容器 $CONTAINER_NAME 未运行"
podman rm "$CONTAINER_NAME" 2>/dev/null || echo "容器 $CONTAINER_NAME 不存在"

# 删除指定镜像
echo "删除镜像: $IMAGE_NAME"
podman rmi "$IMAGE_NAME" 2>/dev/null || echo "镜像 $IMAGE_NAME 不存在"

# 清理悬空资源
echo "清理悬空资源..."
podman container prune -f 2>/dev/null || echo "没有悬空容器"
podman image prune -f 2>/dev/null || echo "没有悬空镜像"
podman buildah rm -a 2>/dev/null || echo "没有Buildah资源"

# 清理容器运行时文件
rm -rf /run/user/1000/containers/* 2>/dev/null || echo "没有容器运行时文件"

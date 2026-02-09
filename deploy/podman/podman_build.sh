#!/bin/bash

set -e

IMAGE_NAME="avey777/ruoqi-v"
CONTAINER_NAME="ruoqi-v"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本所在目录
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"  # deploy 的父目录，即项目根目录

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

echo "=== 开始构建 ==="

# 切换到项目根目录进行构建
cd "$PROJECT_ROOT" || {
    echo "无法切换到项目根目录: $PROJECT_ROOT"
    exit 1
}

echo "构建上下文: $(pwd)"
echo "使用Containerfile: $SCRIPT_DIR/Containerfile"

# 构建镜像
podman build \
    --no-cache \
    --network=host \
    --rm=true \
    --tmpdir=/tmp/podman-tmp \
    -f "$SCRIPT_DIR/Containerfile" \
    -t "$IMAGE_NAME" . || {
    echo "构建失败，执行清理..."
    podman image prune -af
    exit 1
    }

echo "=== 构建成功 ==="

# 最终清理
podman image prune -f 2>/dev/null

echo "=== 脚本执行完成 ==="

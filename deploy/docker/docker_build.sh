#!/bin/bash

set -e

IMAGE_NAME="avey777/ruoqi-v"
CONTAINER_NAME="ruoqi-v"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"  # 脚本所在目录
PROJECT_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"  # deploy 的父目录，即项目根目录

# 验证关键文件存在
if [ ! -f "$SCRIPT_DIR/Dockerfile" ]; then
    echo "错误: 在 $SCRIPT_DIR 目录中未找到 Dockerfile"
    exit 1
fi

echo "=== 开始深度清理 ==="
echo "脚本目录: $SCRIPT_DIR"
echo "项目根目录: $PROJECT_ROOT"

# 1. 停止并删除容器
echo "1. 清理容器..."
docker stop "$CONTAINER_NAME" 2>/dev/null || echo "容器未运行"
docker rm "$CONTAINER_NAME" 2>/dev/null || echo "容器不存在"

# 2. 删除镜像
echo "2. 清理镜像..."
docker rmi "$IMAGE_NAME:latest" 2>/dev/null || echo "镜像不存在"

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

echo "=== 开始构建 ruoqi-v 镜像 ==="

# 切换到项目根目录进行构建
cd "$PROJECT_ROOT" || {
    echo "无法切换到项目根目录: $PROJECT_ROOT"
    exit 1
}

echo "构建上下文: $(pwd)"
echo "使用Dockerfile: $SCRIPT_DIR/Dockerfile"

# 构建镜像
# 检测本地代理是否可用
GIT_PROXY="${GIT_PROXY:-http://127.0.0.1:12334}"
PROXY_ARG=""
if curl -s --max-time 2 "$GIT_PROXY" > /dev/null 2>&1; then
    echo "检测到代理: $GIT_PROXY"
    PROXY_ARG="--build-arg GIT_PROXY=$GIT_PROXY"
else
    echo "代理不可用，直连构建"
fi

docker buildx build \
    --no-cache \
    --network=host \
    --rm=true \
    --progress=plain \
    $PROXY_ARG \
    -f "$SCRIPT_DIR/Dockerfile" \
    -t "$IMAGE_NAME:latest" . || {
    echo "构建失败！执行清理..."
    docker image prune -af
    docker buildx prune -af
    exit 1
    }

echo "=== 构建成功 ==="

# 构建后清理
echo "=== 构建后清理 ==="
docker image prune -f 2>/dev/null
docker buildx prune -f 2>/dev/null

echo "=== 镜像构建完成: $IMAGE_NAME ==="

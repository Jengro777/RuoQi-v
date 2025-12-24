#!/bin/bash
set -euo pipefail

# -----------------------------
# 参数和镜像名称
# -----------------------------
TAG="${1:-latest}"
IMAGE_NAME="avey777/ruoqi-v:$TAG"

echo "=== 准备推送镜像 ==="
echo "镜像标签: $IMAGE_NAME"

# -----------------------------
# 检查本地镜像是否存在
# -----------------------------
if ! docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo "错误: 本地镜像 $IMAGE_NAME 不存在，请先构建镜像"
    exit 1
fi

# -----------------------------
# 加载环境变量文件（如果存在）
# -----------------------------
ENV_FILE=".env"
if [[ -f "$ENV_FILE" ]]; then
    echo "加载环境变量文件: $ENV_FILE"
    set -o allexport
    source "$ENV_FILE"
    set +o allexport
fi

# -----------------------------
# 设置 Docker Hub 用户名和访问令牌
# -----------------------------
DOCKER_HUB_USERNAME="${DOCKER_HUB_USERNAME:-}"
DOCKER_HUB_ACCESS_TOKEN="${DOCKER_HUB_ACCESS_TOKEN:-}"

if [[ -z "$DOCKER_HUB_USERNAME" ]] || [[ -z "$DOCKER_HUB_ACCESS_TOKEN" ]]; then
    echo "错误: DOCKER_HUB_USERNAME 或 DOCKER_HUB_ACCESS_TOKEN 未设置"
    exit 1
fi

# -----------------------------
# 调试信息
# -----------------------------
echo "=== 环境变量检查 ==="
echo "用户名: ${DOCKER_HUB_USERNAME:-未设置}"
echo "访问令牌: ${DOCKER_HUB_ACCESS_TOKEN:+已设置（隐藏）}"

# -----------------------------
# 登录 Docker Hub
# -----------------------------
echo "=== 登录 Docker Hub ==="
echo "$DOCKER_HUB_ACCESS_TOKEN" | docker login -u "$DOCKER_HUB_USERNAME" --password-stdin || {
    echo "Docker Hub 登录失败，请检查用户名/Access Token 或网络"
    exit 1
}

# -----------------------------
# 推送镜像
# -----------------------------
echo "=== 开始推送镜像 ==="
docker push "$IMAGE_NAME" || {
    echo "推送失败: $IMAGE_NAME"
    echo "请检查 Docker Hub 用户名、Access Token 权限（需包含 Write 权限）及镜像命名空间是否匹配"
    exit 1
}

echo "=== 镜像推送成功 ==="
echo "镜像地址: docker.io/$IMAGE_NAME"

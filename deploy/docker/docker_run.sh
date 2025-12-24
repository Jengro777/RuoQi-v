#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# docker 目录的父目录是项目根目录
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "脚本目录 (docker目录): $SCRIPT_DIR"
echo "项目根目录: $PROJECT_ROOT"

# 定义 compose 文件路径
COMPOSE_FILE="$SCRIPT_DIR/docker-compose.yml"

# 检查 docker-compose.yml 是否存在
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "错误: 在 $SCRIPT_DIR 中未找到 docker-compose.yml"
    exit 1
fi

# 切换到项目根目录（通常更好，因为相对路径可以正确解析）
cd "$PROJECT_ROOT" || {
    echo "错误: 无法切换到项目根目录: $PROJECT_ROOT"
    exit 1
}

echo "停止容器..."
docker compose -f "$COMPOSE_FILE" down

echo "启动容器..."
docker compose -f "$COMPOSE_FILE" up -d

echo "完成！"

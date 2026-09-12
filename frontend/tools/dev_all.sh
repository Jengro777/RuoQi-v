#!/usr/bin/env bash
# 并行启动全部 Flutter 原型，并提供一个静态入口页。
#
# 用法（在仓库根目录）：
#   just apps
#   just apps chrome 51010 51099      # 位置参数：设备、起始端口、入口页端口
#   DEVICE=chrome HUB_PORT=51099 just apps
#
# 可用环境变量：
#   DEVICE        传给 flutter run -d 的设备，默认 web-server
#   BASE_PORT     第一个 app 的端口，默认 51000，其余依次 +1
#   HUB_PORT      静态入口页端口，默认 51090
#   HUB_HOST      入口页监听地址，默认 127.0.0.1
#   WEB_HOSTNAME  传给 flutter run --web-hostname，默认不传（即 localhost）
#   FLUTTER       flutter 可执行文件，默认 flutter
#   HUB_DIR       入口页产物目录，默认 frontend/build/dev-all-hub
#   LOG_DIR       各端日志目录，默认 frontend/build/dev-all-logs
#
# Ctrl-C 会停掉入口页并结束所有 flutter run。

set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TOOLS_DIR="$ROOT/tools"

DEVICE="${DEVICE:-web-server}"
BASE_PORT="${BASE_PORT:-51000}"
HUB_PORT="${HUB_PORT:-51090}"
HUB_HOST="${HUB_HOST:-127.0.0.1}"
WEB_HOSTNAME="${WEB_HOSTNAME:-}"
FLUTTER="${FLUTTER:-flutter}"
HUB_DIR="${HUB_DIR:-$ROOT/build/dev-all-hub}"
LOG_DIR="${LOG_DIR:-$ROOT/build/dev-all-logs}"

# 相对目录|显示名|端类型|包名；端口按顺序从 BASE_PORT 递增。
ENTRIES=(
  "apps/platform_pc|平台 PC|PC|ruoqi_platform_pc"
  "apps/platform_app|平台 App|App|ruoqi_platform_app"
  "apps/business_pc|业务 PC|PC|ruoqi_business_pc"
  "apps/business_app|业务 App|App|ruoqi_business_app"
)

PIDS=()

port_in_use() {
  (exec 3<>"/dev/tcp/127.0.0.1/$1") 2>/dev/null
}

cleanup() {
  trap - INT TERM EXIT
  echo
  echo "正在停止全部原型…"
  local pid
  for pid in "${PIDS[@]}"; do
    kill -TERM -- "-$pid" 2>/dev/null || kill -TERM "$pid" 2>/dev/null
  done
  sleep 2
  for pid in "${PIDS[@]}"; do
    if kill -0 "$pid" 2>/dev/null; then
      kill -KILL -- "-$pid" 2>/dev/null || kill -KILL "$pid" 2>/dev/null
    fi
  done
  wait 2>/dev/null
  echo "已全部停止。"
}

trap cleanup INT TERM EXIT

if ! command -v "$FLUTTER" >/dev/null 2>&1; then
  echo "找不到 flutter（当前 PATH=$PATH）" >&2
  echo "可先 export PATH=\"\$PATH:\$HOME/opt/flutter/bin\"，或用 FLUTTER=/path/to/flutter just apps" >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "找不到 python3：入口页需要它来生成 apps.json 并托管静态页面。" >&2
  exit 1
fi

conflict=0
for i in "${!ENTRIES[@]}"; do
  IFS='|' read -r _ _ _ pkg <<<"${ENTRIES[$i]}"
  port=$((BASE_PORT + i))
  if port_in_use "$port"; then
    echo "端口 $port 已被占用（$pkg，可能是上一次没退干净的 flutter run）" >&2
    conflict=1
  fi
done
if port_in_use "$HUB_PORT"; then
  echo "入口页端口 $HUB_PORT 已被占用" >&2
  conflict=1
fi
if ((conflict)); then
  echo "请先停掉占用端口的进程，或换端口：just apps web-server 51010 51099" >&2
  exit 1
fi

mkdir -p "$HUB_DIR" "$LOG_DIR"
cp "$TOOLS_DIR/dev_all_hub.html" "$HUB_DIR/index.html"

# 生成入口页数据：apps.json
for i in "${!ENTRIES[@]}"; do
  IFS='|' read -r dir label kind pkg <<<"${ENTRIES[$i]}"
  printf '%s|%s|%s|%s|%s\n' "$((BASE_PORT + i))" "$dir" "$label" "$kind" "$pkg"
done | python3 -c '
import json, sys

apps = []
for line in sys.stdin:
    line = line.strip()
    if not line:
        continue
    port, path, name, kind, package = line.split("|")
    apps.append({
        "port": int(port),
        "path": path,
        "name": name,
        "kind": kind,
        "package": package,
    })
json.dump({"apps": apps}, sys.stdout, ensure_ascii=False, indent=2)
' >"$HUB_DIR/apps.json"

export DEVICE FLUTTER WEB_HOSTNAME

echo "启动 ${#ENTRIES[@]} 个 Flutter 原型（DEVICE=$DEVICE）…"
for i in "${!ENTRIES[@]}"; do
  IFS='|' read -r dir label _ pkg <<<"${ENTRIES[$i]}"
  port=$((BASE_PORT + i))
  log="$LOG_DIR/$port-$pkg.log"
  : >"$log"
  PORT="$port" setsid bash -c '
    cd "$1" || exit 1
    extra=()
    [ -n "$WEB_HOSTNAME" ] && extra=(--web-hostname "$WEB_HOSTNAME")
    exec "$FLUTTER" run -d "$DEVICE" --web-port "$PORT" "${extra[@]}"
  ' _ "$ROOT/$dir" >"$log" 2>&1 </dev/null &
  PIDS+=("$!")
  printf '  %-9s :%s  http://localhost:%s\n' "$label" "$port" "$port"
done

echo
echo "入口页： http://localhost:$HUB_PORT"
echo "日志：   $LOG_DIR"
echo "首次编译每个端需要几十秒，入口页上的圆点变绿即为就绪；Ctrl-C 全部停止。"
echo

# 入口页放到后台，用 wait 等它：这样信号一到就能立刻触发清理，
# 而不会像前台命令那样把 trap 推迟到 http.server 自然退出。
setsid python3 -m http.server "$HUB_PORT" --bind "$HUB_HOST" --directory "$HUB_DIR" &
HUB_PID=$!
PIDS+=("$HUB_PID")
wait "$HUB_PID"

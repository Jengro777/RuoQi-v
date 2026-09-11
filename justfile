# RuoQi-v 项目命令

# ─── 开发 ───────────────────────────────────────────
dev:
    cd backend && v -d trace_orm -d veb_livereload watch run ./main -f etc/config_dev.toml

test:
    cd backend && v -d trace_orm  run ./main -f etc/config_dev.toml

uat:
    cd backend && v -d trace_orm  run ./main -f etc/config.toml

build:
    cd backend && v -o app ./main

build_prod:
    cd backend && v -prod -o app ./main

# ─── OpenAPI ────────────────────────────────────────
openapi:
    cd backend && v run openapi/openapi_generate.vsh

# ─── 前端 ──────────────────────────────────────────
frontend_get:
    cd frontend && flutter pub get

frontend_analyze:
    cd frontend && melos analyze

frontend_test:
    cd frontend && melos test

frontend_gen:
    cd frontend && melos gen

# 启动平台 Flutter 原型服务。
# 默认 web-server 模式：只起本地服务，用任意浏览器打开下方地址访问。
# 想用设备直接跑可覆盖，如：just platform_pc DEVICE=linux
platform_pc DEVICE="web-server" PORT="8080":
    cd frontend/apps/pc/platform && flutter run -d {{DEVICE}} --web-port {{PORT}}

platform_app DEVICE="web-server" PORT="8081":
    cd frontend/apps/app/platform && flutter run -d {{DEVICE}} --web-port {{PORT}}

# 商户端（租户端）原型服务
merchant_pc DEVICE="web-server" PORT="8082":
    cd frontend/apps/pc/merchant && flutter run -d {{DEVICE}} --web-port {{PORT}}

merchant_app DEVICE="web-server" PORT="8083":
    cd frontend/apps/app/merchant && flutter run -d {{DEVICE}} --web-port {{PORT}}

# ─── 工具 ──────────────────────────────────────────
kill:
    lsof -ti :9009 | xargs -r sudo kill -9

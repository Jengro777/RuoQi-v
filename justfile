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
# 想用设备直接跑可覆盖，如：just platform_pc linux
platform_pc DEVICE="web-server" PORT="51000":
    cd frontend/apps/platform_pc && flutter run -d {{DEVICE}} --web-port {{PORT}}

platform_app DEVICE="web-server" PORT="51001":
    cd frontend/apps/platform_app && flutter run -d {{DEVICE}} --web-port {{PORT}}

# 业务端原型服务（客户 / 商户 / 伙伴三个业务域共用一个应用壳）
business_pc DEVICE="web-server" PORT="51002":
    cd frontend/apps/business_pc && flutter run -d {{DEVICE}} --web-port {{PORT}}

business_app DEVICE="web-server" PORT="51003":
    cd frontend/apps/business_app && flutter run -d {{DEVICE}} --web-port {{PORT}}

# 一条命令并行拉起全部 4 个原型（51000-51003）+ 静态入口页（51090）。
# 打开 http://localhost:51090 一页点进所有端；Ctrl-C 全部停止。
# 覆盖示例：just apps chrome 51010 51099
# 也可用环境变量：DEVICE=chrome BASE_PORT=51010 HUB_PORT=51099 just apps
apps device=env_var_or_default("DEVICE", "web-server") base_port=env_var_or_default("BASE_PORT", "51000") hub_port=env_var_or_default("HUB_PORT", "51090"):
    DEVICE={{device}} BASE_PORT={{base_port}} HUB_PORT={{hub_port}} ./frontend/tools/dev_all.sh

# ─── 工具 ──────────────────────────────────────────
kill:
    lsof -ti :9009 | xargs -r sudo kill -9

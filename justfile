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
    cd frontend/apps/pc/platform && flutter run -d {{DEVICE}} --web-port {{PORT}}

platform_app DEVICE="web-server" PORT="51001":
    cd frontend/apps/app/platform && flutter run -d {{DEVICE}} --web-port {{PORT}}

# 商户端（租户端）原型服务
merchant_pc DEVICE="web-server" PORT="51002":
    cd frontend/apps/pc/merchant && flutter run -d {{DEVICE}} --web-port {{PORT}}

merchant_app DEVICE="web-server" PORT="51003":
    cd frontend/apps/app/merchant && flutter run -d {{DEVICE}} --web-port {{PORT}}

# 客户端原型服务
customer_pc DEVICE="web-server" PORT="51004":
    cd frontend/apps/pc/customer && flutter run -d {{DEVICE}} --web-port {{PORT}}

customer_app DEVICE="web-server" PORT="51005":
    cd frontend/apps/app/customer && flutter run -d {{DEVICE}} --web-port {{PORT}}

# 伙伴端原型服务
partner_pc DEVICE="web-server" PORT="51006":
    cd frontend/apps/pc/partner && flutter run -d {{DEVICE}} --web-port {{PORT}}

partner_app DEVICE="web-server" PORT="51007":
    cd frontend/apps/app/partner && flutter run -d {{DEVICE}} --web-port {{PORT}}

# 一条命令并行拉起全部 8 个原型（51000-51007）+ 静态入口页（51090）。
# 打开 http://localhost:51090 一页点进所有端；Ctrl-C 全部停止。
# 覆盖示例：just apps chrome 51010 51099
# 也可用环境变量：DEVICE=chrome BASE_PORT=51010 HUB_PORT=51099 just apps
apps device=env_var_or_default("DEVICE", "web-server") base_port=env_var_or_default("BASE_PORT", "51000") hub_port=env_var_or_default("HUB_PORT", "51090"):
    DEVICE={{device}} BASE_PORT={{base_port}} HUB_PORT={{hub_port}} ./frontend/tools/dev_all.sh

# ─── 工具 ──────────────────────────────────────────
kill:
    lsof -ti :9009 | xargs -r sudo kill -9

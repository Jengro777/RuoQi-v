module structs

import veb
import common.jwt { JwtPayload }
import adapter.dbpool
import config
import i18n

pub struct App {
	veb.Middleware[Context]
	veb.Controller
	veb.StaticHandler
pub mut:
	started chan bool // 用于通知应用程序已成功启动
}

pub struct Context {
	veb.Context
pub mut:
	dbpool      &dbpool.DatabasePool
	config      &config.GlobalConfig
	jwt_payload ?JwtPayload
	i18n        &i18n.I18nStore
	extra_i18n  map[string]string = map[string]string{}

	svc_sys  ServiceContextSys
	svc_core ServiceContextCore
}

// -----  Sys用户&&租户层上下文 ---
pub struct ServiceContextSys {
pub mut:
	user_id   string
	token_jwt string
	role_ids  []string
}

// -----  Core用户&&租户层上下文 ---
pub struct ServiceContextCore {
pub mut:
	user_id         string
	token_jwt       string
	tenant_id       string
	sub_app_id      string // 当前操作的订阅应用(考虑到一个租户可以重复订阅一个应用)
	tenant_role_ids []string
}

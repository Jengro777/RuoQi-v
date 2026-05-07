module structs

import veb
import common.jwt { JwtPayload }
import adapter.dbpool
import adapter.cache_pool
import config
import i18n

pub struct App {
	veb.Middleware[Context]
	veb.Controller
	veb.StaticHandler
pub mut:
	server          &veb.Server = unsafe { nil } // 服务器实例引用,优雅关闭服务使用
	started         chan bool // 用于通知应用程序已成功启动
	shutdown_signal chan bool // 用于触发优雅关闭
}

pub struct Context {
	veb.Context
pub mut:
	dbpool      &dbpool.DatabasePool
	cache_pool  &cache_pool.CachePool
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

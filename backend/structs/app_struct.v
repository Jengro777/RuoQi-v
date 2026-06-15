module structs

import veb
import common.jwt { AuthPayload }
import adapter.dbpool
import adapter.cache_pool
import adapter.datascope { ScopeCallContext, ScopedResult }
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
	scope_scc   ScopeCallContext
	dbpool      &dbpool.DatabasePoolable @[noinit]
	cache_pool  &cache_pool.CachePool
	config      &config.GlobalConfig
	jwt_payload ?AuthPayload
	i18n        &i18n.I18nStore
	extra_i18n  map[string]string = map[string]string{}

	svc_sys  ServiceContextSys
	svc_core ServiceContextCore
	svc_iam  ServiceContextIam
}

// acquire_scoped 将 ctx 上的 svc 上下文填充到 ScopeCallContext，委托 adapter.datascope 获取带数据范围的 DB 连接
pub fn (mut ctx Context) acquire_scoped() !ScopedResult {
	ctx.scope_scc.dbpool = ctx.dbpool
	ctx.scope_scc.svc_core_tenant_id = ctx.svc_core.tenant_id
	ctx.scope_scc.svc_core_user_id = ctx.svc_core.user_id
	ctx.scope_scc.svc_core_tenant_role_ids = ctx.svc_core.tenant_role_ids
	ctx.scope_scc.svc_iam_tenant_id = ctx.svc_iam.tenant_id
	ctx.scope_scc.svc_iam_user_id = ctx.svc_iam.user_id
	ctx.scope_scc.svc_sys_user_id = ctx.svc_sys.user_id
	ctx.scope_scc.svc_sys_role_ids = ctx.svc_sys.role_ids
	return datascope.acquire_scoped(mut ctx.scope_scc)
}

// ----- IAM 统一上下文 ---
pub struct ServiceContextIam {
pub mut:
	user_id   string
	token_jwt string
	role_ids  []string
	tenant_id string
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
	sub_app_id      string
	tenant_role_ids []string
}

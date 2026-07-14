module structs

import veb
import common.crypt { AuthPayload }
import adapter.dbpool
import adapter.cache_pool
import orm
import pool
import adapter.datascope { ScopeContext }
import config
import locale

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
	scope_sc     ScopeContext
	dbpool       &dbpool.DatabasePoolable @[noinit]
	cache_pool   &cache_pool.CachePool
	config       &config.GlobalConfig
	jwt_payload  ?AuthPayload
	locale       &locale.LocaleStore
	extra_locale map[string]string = map[string]string{}

	svc_iam ServiceContextIam
}

// ----- IAM 统一上下文 ---
pub struct ServiceContextIam {
pub mut:
	user_id        string
	token_jwt      string
	iam_role_ids   []string
	tenant_ids     []string
	subproduct_ids []string
	subportal_ids  []string
	apikey_id      string
	workspace_ids  []string
	// 当前请求的活跃数据范围（用于 datascope SQL 过滤）
	active_tenant_id     string
	active_subproduct_id string
	active_subportal_id  string
}

// acquire_scoped 将 ctx 上的 svc 上下文填充到 ScopeContext，委托 adapter.datascope 获取带数据范围的 DB 连接
pub fn (mut ctx Context) acquire_scoped() !(orm.DB, &pool.ConnectionPoolable) {
	ctx.scope_sc.dbpool = ctx.dbpool
	ctx.scope_sc.user_id = ctx.svc_iam.user_id
	// AK/SK: 将当前请求的租户/产品/门户信息传递到 datascope 层，用于 SQL WHERE 过滤
	if ctx.svc_iam.active_tenant_id != '' {
		ctx.scope_sc.tenant_id = ctx.svc_iam.active_tenant_id
	}
	if ctx.svc_iam.active_subproduct_id != '' {
		ctx.scope_sc.subproduct_id = ctx.svc_iam.active_subproduct_id
	}
	if ctx.svc_iam.active_subportal_id != '' {
		ctx.scope_sc.subportal_id = ctx.svc_iam.active_subportal_id
	}
	db, conn := datascope.acquire_scoped(mut ctx.scope_sc) or { return err }
	return db, conn
}

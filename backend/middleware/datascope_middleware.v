module middleware

import orm
import log
import pool
import veb
import structs { Context }

// =============================================================================
// DataScope 中间件 — 多租户数据隔离（参考 V ORM DataScope 模式）
//
// 功能：
//   从连接池获取连接后自动注入 DataScope 过滤器，支持以下维度：
//     - tenant_id      租户级隔离（自动从 svc_core/svc_iam 提取）
//     - workspace_id   工作区级隔离（显式传入）
//     - subproduct_id  产品订阅实例级隔离（显式传入）
//     - subportal_id   门户入住实例级隔离（显式传入）
//     - user_id        用户级/归属隔离（自动从上下文提取）
//     - 自定义字段     通过 extra 参数传入
//
//   角色级豁免：
//     - root（role_ids=['*']) → unfiltered，跳过所有过滤器
//
//   维度自动推断：
//     - svc_iam 已填充 → 默认 [.owner]（IAM 路由，按用户隔离）
//     - 其他            → 默认 [.tenant]（Core/默认，按租户隔离）
//
// 使用方式：
//   ```v
//   // 自动推断维度
//   r := middleware.acquire_scoped(mut ctx)!
//   defer { ctx.dbpool.release(r.conn) or {} }
//   rows := sql r.db { select from SomeModel }!
//
//   // 显式指定维度
//   r := middleware.acquire_scoped_with(mut ctx, ScopeConfig{
//       enabled_dims:     [.tenant, .workspace]
//       workspace_id:     ws_id
//   })!
//
//   // 特殊业务：跳过所有 scope
//   r := middleware.acquire_scoped(mut ctx)!
//   rows := sql r.db.unscope() { select from SomeNoScopeModel }!
//
//   // 临时附加自定义字段
//   r := middleware.acquire_scoped(mut ctx,
//       middleware.scope_eq('custom_field', orm.Primitive(some_val)),
//   )!
//   ```
//
// 参考：https://github.com/vlang/v/blob/master/examples/orm/orm_scope_middleware.v
// =============================================================================

// =============================================================================
// Types
// =============================================================================

// ScopedResult 携带 scope 后的 orm.DB 和原始池连接。
pub struct ScopedResult {
pub:
	db   orm.DB
	conn &pool.ConnectionPoolable
}

// DataScopeFilter 描述一个 scope 过滤器。
pub struct DataScopeFilter {
pub:
	field string
	value orm.Primitive
}

// Dim 枚举支持的 scope 维度。
pub enum Dim {
	tenant     // tenant_id
	subproduct // subproduct_id  产品订阅实例级隔离
	subportal  // subportal_id   门户入住实例级隔离
	workspace  // workspace_id
	owner      // user_id
}

// ScopeConfig 控制 acquire_scoped 的行为。
pub struct ScopeConfig {
pub mut:
	enabled_dims  []Dim = [.tenant]
	workspace_id  string
	subproduct_id string
	subportal_id  string
	user_id       string
}

// =============================================================================
// Context 值提取（私有）
// =============================================================================

fn context_tenant_id(ctx &Context) string {
	if ctx.svc_core.tenant_id != '' {
		return ctx.svc_core.tenant_id
	}
	return ctx.svc_iam.tenant_id
}

fn context_user_id(ctx &Context) string {
	if ctx.svc_core.user_id != '' {
		return ctx.svc_core.user_id
	}
	if ctx.svc_sys.user_id != '' {
		return ctx.svc_sys.user_id
	}
	return ctx.svc_iam.user_id
}

fn is_root_user(ctx &Context) bool {
	return ctx.svc_sys.role_ids.contains('*') || ctx.svc_core.tenant_role_ids.contains('*')
}

fn dim_field(d Dim) string {
	return match d {
		.tenant { 'tenant_id' }
		.subproduct { 'subproduct_id' }
		.subportal { 'subportal_id' }
		.workspace { 'workspace_id' }
		.owner { 'user_id' }
	}
}

// default_dims 根据上下文自动推断默认维度：
//   svc_iam 已填充 → [.owner]（IAM 路由，按用户隔离）
//   其他            → [.tenant]（Core/默认，按租户隔离）
fn default_dims(ctx &Context) []Dim {
	if ctx.svc_iam.user_id != '' {
		return [.owner]
	}
	return [.tenant]
}

// =============================================================================
// acquire_scoped — 核心函数（自动推断维度，向后兼容）
// =============================================================================
pub fn acquire_scoped(mut ctx Context, extra ...DataScopeFilter) !ScopedResult {
	mut cfg := ScopeConfig{
		enabled_dims: default_dims(ctx)
	}
	return acquire_scoped_with(mut ctx, cfg, ...extra)
}

// acquire_scoped_with 带 ScopeConfig，精细控制 scope 维度。
pub fn acquire_scoped_with(mut ctx Context, cfg ScopeConfig, extra ...DataScopeFilter) !ScopedResult {
	raw_conn, pool_conn := ctx.dbpool.acquire() or {
		return error('Failed to acquire DB conn: ${err}')
	}

	// root 用户 → 全部跳过
	if is_root_user(ctx) {
		mut scoped_db := orm.new_db(raw_conn, orm.DataScope{
			filters: []
		})
		scoped_db = scoped_db.unscoped()
		log.debug('datascope: root user — all scopes removed')
		return ScopedResult{
			db:   scoped_db
			conn: pool_conn
		}
	}

	mut filters := []orm.QueryFilter{}

	for dim in cfg.enabled_dims {
		// skip dimensions with empty value
		skip := match dim {
			.tenant {
				false
			}
			.subproduct {
				cfg.subproduct_id == ''
			}
			.subportal {
				cfg.subportal_id == ''
			}
			.workspace {
				cfg.workspace_id == ''
			}
			.owner {
				uid := if cfg.user_id != '' { cfg.user_id } else { context_user_id(ctx) }
				uid == ''
			}
		}

		if skip {
			continue
		}

		mut val := match dim {
			.tenant {
				orm.Primitive(context_tenant_id(ctx))
			}
			.subproduct {
				orm.Primitive(cfg.subproduct_id)
			}
			.subportal {
				orm.Primitive(cfg.subportal_id)
			}
			.workspace {
				orm.Primitive(cfg.workspace_id)
			}
			.owner {
				uid := if cfg.user_id != '' { cfg.user_id } else { context_user_id(ctx) }
				orm.Primitive(uid)
			}
		}

		filters << orm.QueryFilter{
			field: dim_field(dim)
			value: val
			mode:  .dynamic
		}
	}

	// extra 过滤器
	for ef in extra {
		filters << orm.QueryFilter{
			field: ef.field
			value: ef.value
			mode:  .dynamic
		}
	}

	scoped_db := orm.new_db(raw_conn, orm.DataScope{
		filters: filters
	})

	log.debug('datascope: ${filters.len} filter(s) applied')

	return ScopedResult{
		db:   scoped_db
		conn: pool_conn
	}
}

// =============================================================================
// acquire_scoped_tx — 事务版
// =============================================================================
pub fn acquire_scoped_tx(mut ctx Context, extra ...DataScopeFilter) !ScopedResult {
	mut cfg := ScopeConfig{
		enabled_dims: default_dims(ctx)
	}
	return acquire_scoped_tx_with(mut ctx, cfg, ...extra)
}

pub fn acquire_scoped_tx_with(mut ctx Context, cfg ScopeConfig, extra ...DataScopeFilter) !ScopedResult {
	r := acquire_scoped_with(mut ctx, cfg, ...extra)!
	r.db.orm_begin() or {
		ctx.dbpool.release(r.conn) or {}
		return error('Failed to begin transaction: ${err}')
	}
	return r
}

// =============================================================================
// Scope 过滤器快捷构造
// =============================================================================

// scope_eq 构造任意等值过滤器。
pub fn scope_eq(field string, value orm.Primitive) DataScopeFilter {
	return DataScopeFilter{field, value}
}

// scope_field 自定义字段过滤（值自动转为 Primitive）。
pub fn scope_field(field string, value string) DataScopeFilter {
	return DataScopeFilter{field, orm.Primitive(value)}
}

// =============================================================================
// Veb 中间件 — 为路由启用 datascope
// =============================================================================

// datascope_middleware 标记路由已启用 datascope。dims 仅用于日志，
// 实际维度由 acquire_scoped() 根据 ctx 自动推断。
pub fn datascope_middleware(dims []string) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [dims] (mut ctx Context) bool {
			log.debug('datascope: dims=${dims}')
			return true
		}
		after:   false
	}
}

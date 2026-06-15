module datascope

import orm
import log
import pool
import adapter.dbpool

// =============================================================================
// Data Scope 类型定义
// =============================================================================

pub enum ScopeDim {
	tenant_id
	subproduct_id
	subportal_id
	workspace_id
	user_id
}

pub struct ScopeConfig {
pub:
	enabled_dims []ScopeDim = [.tenant_id]
pub mut:
	workspace_id  string
	subproduct_id string
	subportal_id  string
	user_id       string
}

pub struct ScopedResult {
pub:
	db   orm.DB
	conn &pool.ConnectionPoolable
}

// =============================================================================
// acquire_scoped 调用上下文（config + svc 上下文合一）
// =============================================================================

pub struct ScopeCallContext {
pub mut:
	// DB pool
	dbpool &dbpool.DatabasePoolable = unsafe { nil }
	// Scope config（从 ScopeConfig 合并）
	enabled_dims  []ScopeDim = [.tenant_id]
	workspace_id  string
	subproduct_id string
	subportal_id  string
	user_id       string
	// Svc 上下文
	svc_core_tenant_id       string
	svc_core_user_id         string
	svc_core_tenant_role_ids []string
	svc_iam_tenant_id        string
	svc_iam_user_id          string
	svc_sys_user_id          string
	svc_sys_role_ids         []string
}

// from_scope_config 从 ScopeConfig 构建 ScopeCallContext（config 部分）
pub fn from_scope_config(cfg ScopeConfig) ScopeCallContext {
	return ScopeCallContext{
		enabled_dims:  cfg.enabled_dims
		workspace_id:  cfg.workspace_id
		subproduct_id: cfg.subproduct_id
		subportal_id:  cfg.subportal_id
		user_id:       cfg.user_id
	}
}

// =============================================================================
// 内部辅助
// =============================================================================

fn context_tenant_id(scc &ScopeCallContext) string {
	if scc.svc_core_tenant_id != '' {
		return scc.svc_core_tenant_id
	}
	return scc.svc_iam_tenant_id
}

fn context_user_id(scc &ScopeCallContext) string {
	if scc.svc_core_user_id != '' {
		return scc.svc_core_user_id
	}
	if scc.svc_sys_user_id != '' {
		return scc.svc_sys_user_id
	}
	return scc.svc_iam_user_id
}

fn is_root_user(scc &ScopeCallContext) bool {
	return scc.svc_sys_role_ids.contains('*') || scc.svc_core_tenant_role_ids.contains('*')
}

// =============================================================================
// 带数据范围的 DB 连接获取
// =============================================================================

// acquire_scoped 根据 ScopeCallContext 获取带数据范围的 DB 连接
pub fn acquire_scoped(mut scc ScopeCallContext) !ScopedResult {
	raw_conn, pool_conn := scc.dbpool.acquire() or {
		return error('Failed to acquire DB conn: ${err}')
	}

	if is_root_user(&scc) {
		return ScopedResult{
			db:   orm.new_db(raw_conn, orm.DataScope{ filters: [] }).unscoped()
			conn: pool_conn
		}
	}

	mut filters := []orm.QueryFilter{}

	for dim in scc.enabled_dims {
		skip := match dim {
			.tenant_id {
				false
			}
			.subproduct_id {
				scc.subproduct_id == ''
			}
			.subportal_id {
				scc.subportal_id == ''
			}
			.workspace_id {
				scc.workspace_id == ''
			}
			.user_id {
				if scc.user_id != '' {
					scc.user_id == ''
				} else {
					context_user_id(&scc) == ''
				}
			}
		}

		if skip { continue
		 }

		val := match dim {
			.tenant_id {
				orm.Primitive(context_tenant_id(&scc))
			}
			.subproduct_id {
				orm.Primitive(scc.subproduct_id)
			}
			.subportal_id {
				orm.Primitive(scc.subportal_id)
			}
			.workspace_id {
				orm.Primitive(scc.workspace_id)
			}
			.user_id {
				if scc.user_id != '' {
					orm.Primitive(scc.user_id)
				} else {
					orm.Primitive(context_user_id(&scc))
				}
			}
		}

		filters << orm.QueryFilter{
			field: '${dim}'
			value: val
			mode:  .dynamic
		}
	}

	scoped_db := orm.new_db(raw_conn, orm.DataScope{ filters: filters })
	log.debug('datascope: ${filters.len} filter(s) applied')

	return ScopedResult{
		db:   scoped_db
		conn: pool_conn
	}
}

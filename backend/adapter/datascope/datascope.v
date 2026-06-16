module datascope

import orm
import log
import pool
import adapter.dbpool

// =============================================================================
// Data Scope 类型定义
// =============================================================================

pub enum ScopeField {
	tenant_id
	subproduct_id
	subportal_id
	workspace_id
	user_id
}

pub struct ScopeConfig {
pub:
	enabled_fields []ScopeField = [.tenant_id]
pub mut:
	user_id       string
	tenant_id     string
	workspace_id  string
	subproduct_id string
	subportal_id  string
}

// =============================================================================
// acquire_scoped 调用上下文（config + svc 上下文合一）
// =============================================================================

pub struct ScopeContext {
pub mut:
	// DB pool
	dbpool &dbpool.DatabasePoolable = unsafe { nil }
	// Scope config（从 ScopeConfig 合并）
	tenant_id      string
	enabled_fields []ScopeField
	workspace_id   string
	subproduct_id  string
	subportal_id   string
	user_id        string
	// Svc 上下文
	svc_sys_user_id  string
	svc_sys_role_ids []string
}

// from_scope_config 从 ScopeConfig 构建 ScopeContext（config 部分）
pub fn from_scope_config(cfg ScopeConfig) ScopeContext {
	return ScopeContext{
		enabled_fields: cfg.enabled_fields
		workspace_id:   cfg.workspace_id
		subproduct_id:  cfg.subproduct_id
		subportal_id:   cfg.subportal_id
		user_id:        cfg.user_id
		tenant_id:      cfg.tenant_id
	}
}

// =============================================================================
// 内部辅助
// =============================================================================

fn is_root_user(sc &ScopeContext) bool {
	return sc.svc_sys_role_ids.contains('*')
}

// =============================================================================
// 带数据范围的 DB 连接获取
// =============================================================================

// acquire_scoped 根据 ScopeContext 获取带数据范围的 DB 连接
pub fn acquire_scoped(mut sc ScopeContext) !(orm.DB, &pool.ConnectionPoolable) {
	raw_conn, pool_conn := sc.dbpool.acquire() or {
		return error('Failed to acquire DB conn: ${err}')
	}

	if is_root_user(&sc) {
		return orm.new_db(raw_conn, orm.DataScope{ filters: [] }).unscoped(), pool_conn
	}

	mut filters := []orm.QueryFilter{}
	for field in sc.enabled_fields {
		skip := match field {
			.tenant_id {
				false
			}
			.subproduct_id {
				sc.subproduct_id == ''
			}
			.subportal_id {
				sc.subportal_id == ''
			}
			.workspace_id {
				sc.workspace_id == ''
			}
			.user_id {
				sc.user_id == ''
			}
		}

		if skip { continue
		 }
		val := match field {
			.tenant_id {
				orm.Primitive(sc.tenant_id)
			}
			.subproduct_id {
				orm.Primitive(sc.subproduct_id)
			}
			.subportal_id {
				orm.Primitive(sc.subportal_id)
			}
			.workspace_id {
				orm.Primitive(sc.workspace_id)
			}
			.user_id {
				orm.Primitive(sc.user_id)
			}
		}

		filters << orm.QueryFilter{
			field: '${field}'
			value: val
			mode:  .dynamic
		}
	}

	scoped_db := orm.new_db(raw_conn, orm.DataScope{ filters: filters })
	log.debug('datascope: ${filters.len} filter(s) applied')

	return scoped_db, pool_conn
}

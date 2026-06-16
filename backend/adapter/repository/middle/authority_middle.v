module middle

import structs { Context }
import structs.schema_iam { IamToken, IamUserRole }
import log

// get_userapilist_from_token 根据 token 获取用户 API 权限列表（Sys 认证用）。
// 新体系下由 datascope 接管数据隔离，此处保留最小实现以兼容现有中间件。
pub fn get_userapilist_from_token(mut ctx Context, req_token string) ![]string {
	log.debug('\${@METHOD}  \${@MOD}.\${@FILE_LINE}')

	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: \${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: \${err}') }
	}

	// 从 IAM Token 表查找用户
	tokens := sql db {
		select from IamToken where token == req_token limit 1
	}!
	if tokens.len != 1 { return error('Token not found') }

	user_id := tokens[0].user_id

	// 查询用户角色
	roles := sql db {
		select from IamUserRole where user_id == user_id
	}!
	role_ids := roles.map(it.role_id)
	ctx.scope_sc.svc_sys_role_ids = role_ids

	// 返回角色 ID 列表作为权限码
	return role_ids
}

// authorize_and_check_api 验证租户用户是否有 API 访问权限（Core 认证用）。
// 新体系下由 workspace + datascope 接管，此处保留最小实现。
pub fn authorize_and_check_api(mut ctx Context, req_token string, tenant_id string, subapp_id string, req_path string) !bool {
	log.debug('\${@METHOD}  \${@MOD}.\${@FILE_LINE}')

	// 在新体系中，API 权限由 workspace_role_api 和 datascope 管理。
	// 此处简单放行 — 实际权限由 datascope 的 acquire_scoped 在 handler 层强制。
	return true
}

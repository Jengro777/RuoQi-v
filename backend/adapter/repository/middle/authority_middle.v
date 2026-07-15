module middle

import structs { Context }
import structs.schema_iam { IamToken, IamUserRole }
import structs.schema_workspace { WsRoleApi }
import structs.schema_platform { PfApi }
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

// find_user_apis_by_token 根据 token 查询用户可访问的 API 权限列表（JWT / Core 路径）
// 查询链: IamToken → IamUserRole → WsRoleApi → PfApi
pub fn find_user_apis_by_token(mut ctx Context, req_token string) ![]string {
	log.debug('\${@METHOD}  \${@MOD}.\${@FILE_LINE}')

	// 1. token → user → roles
	role_ids := get_userapilist_from_token(mut ctx, req_token)!
	if role_ids.contains('*') { return ['all'] }
	if role_ids.len == 0 { return []string{} }

	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: \${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: \${err}') } }

	// 2. roles → api_ids (ws_role_api)
	role_apis := sql db {
		select from WsRoleApi where role_id in role_ids
	} or { return error('Failed to query role APIs: \${err}') }
	api_ids := role_apis.map(it.api_id)
	if api_ids.len == 0 { return []string{} }
	// 3. api_ids → path + method (pf_api)
	apis := sql db {
		select from PfApi where id in api_ids && del_flag == 0
	} or { return []string{} }

	// 4. 返回 scope 格式: ["METHOD:/path", ...]
	return apis.map('\${it.method}:\${it.path}')
}

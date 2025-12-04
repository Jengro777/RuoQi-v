module middleware

import veb
import common.jwt
import log
import structs { Context }
import structs.schema_core
import time

/* =========================================================
Core认证中间件 authority_jwt_verify_core
=========================================================
功能：
1. 校验 Header 中的 tenant_id / subapp_id / token 信息
2. 验证 JWT Token 有效性（签名是否正确）
3. 通过数据库验证 token 对应用户是否属于该租户
4. 检查该用户在当前租户与子应用下是否拥有访问该 API 的权限

设计思想：
- 支持多租户（tenant_id）和多子应用（subapp_id）场景
- 采用数据库动态授权模式，不依赖缓存层
- 支持租户 Owner 拥有全权限，角色可细粒度绑定 API

返回：
- true：通过认证与权限校验
- false：认证或授权失败（自动返回错误信息）
=========================================================
*/
fn authority_jwt_verify_core(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// ---------- 读取 Header 基本参数 ----------
	secret := ctx.get_custom_header('secret') or { '' }
	log.debug(secret)

	tenant_id := ctx.get_custom_header('tenant_id') or { '' }
	log.debug(tenant_id)
	if tenant_id == '' {
		ctx.request_error('Missing or invalid tenant_id')
		return false
	}

	subapp_id := ctx.get_custom_header('subapp_id') or { '' }
	log.debug(subapp_id)

	auth_header := ctx.get_header(.authorization) or { '' }
	log.debug(auth_header)

	// ---------- 检查 Authorization Token ----------
	if auth_header.len == 0 || !auth_header.starts_with('Bearer ') {
		ctx.res.status_code = 401
		ctx.request_error('Missing or invalid authentication token')
		return false
	}

	// 提取 JWT 内容（去掉 Bearer 前缀）
	req_token := auth_header.all_after('Bearer').trim_space()
	log.debug(req_token)

	// ---------- 验证 JWT 签名 ----------
	verify := jwt.jwt_verify(secret, req_token)
	if verify == false {
		ctx.res.status_code = 401
		ctx.request_error('Authorization error')
		log.warn('Authorization error')
		return false
	}

	// ---------- 解码 JWT Payload  全局使用----------
	ctx.jwt_payload = jwt.jwt_decode(req_token) or {
		ctx.res.status_code = 401
		ctx.request_error('Failed to parse token')
		return false
	}

	// ---------- 验证数据库中用户权限 ----------
	is_allowed := authorize_and_check_api(mut ctx, req_token, tenant_id, subapp_id, ctx.req.url) or {
		// 捕获函数内部返回的 error
		ctx.res.status_code = 403
		ctx.request_error('Authorization failed: ${err}')
		return false
	}

	// 若未通过权限检查
	if !is_allowed {
		ctx.res.status_code = 403
		ctx.request_error("You don't have permission to perform this action")
		return false
	}

	// 权限验证通过 ✅
	return true
}

/* =========================================================
授权验证函数 authorize_and_check_api
=========================================================
功能：通过数据库验证该 token 所属用户是否有访问指定 API 的权限

参数：
- ctx       : 上下文对象（包含 dbpool、请求信息等）
- req_token : 请求携带的 JWT Token（数据库中 CoreToken.token）
- tenant_id : 当前租户 ID
- subapp_id : 当前订阅应用 ID，可为空
- req_path  : 当前请求路径（API 路由）

返回：
- true  -> 用户有访问权限
- false -> 用户无访问权限
- error -> 查询或验证异常

数据库表关系：
- CoreToken：存储用户登录 token 与 user_id 绑定关系
- CoreTenantMember：记录租户与成员关系，含 is_owner 字段
- CoreRoleTenantMember：成员在租户下的角色分配表
- CoreRoleApi：角色与 API 授权关系（区分 tenant/app 级）
- CoreApi：系统 API 注册表（包含 path 与 id）
=========================================================
*/
fn authorize_and_check_api(mut ctx Context, req_token string, tenant_id string, subapp_id string, req_path string) !bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	log.debug('tenant_id: ${tenant_id}, subapp_id: ${subapp_id}, req_path: ${req_path}')

	// ---------- 获取数据库连接 ----------
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	// ---------- Step1: 验证 token 有效性 ----------
	// 根据 token 查询 CoreToken 表，确认 token 是否存在及对应用户
	core_token := sql db {
		select from schema_core.CoreToken where token == req_token limit 1
	}!
	if core_token.len != 1 {
		return error('Token not found')
	}
	if core_token[0].expired_at < time.now() {
		return error('Token expired')
	}

	user_id := core_token[0].user_id
	log.debug('user_id: ${user_id}')

	// ---------- Step2: 验证用户是否属于当前租户 ----------
	core_member := sql db {
		select from schema_core.CoreTenantMember where tenant_id == tenant_id && member_id == user_id limit 1
	}!
	if core_member.len < 1 {
		return error('Tenant Member not found')
	}

	// 若该成员为租户 Owner，则自动放行所有操作
	if core_member[0].is_owner == 1 {
		log.debug('User is tenant owner -> allow all ✅')
		return true
	}

	// ---------- Step3: 查询用户在该租户下的角色 ----------
	core_roles := sql db {
		select from schema_core.CoreRoleTenantMember where tenant_id == tenant_id
		&& member_id == user_id
	}!
	if core_roles.len < 1 {
		return error('No roles found for user')
	}
	role_ids := core_roles.map(it.role_id)
	log.debug('role_ids: ${role_ids}')

	// ---------- Step4: 确认当前请求路径在 API 注册表中存在 ----------
	core_api := sql db {
		select from schema_core.CoreApi where path == req_path limit 1
	}!
	if core_api.len == 0 {
		return error('API path not found in registry')
	}
	api_id := core_api[0].id

	// ---------- Step5: 检查租户级权限 ----------
	// 若角色在租户级(source_type='tenant')中被授予该 API，则放行
	tenant_api := sql db {
		select from schema_core.CoreRoleApi where role_id in role_ids && source_type == 'tenant'
		&& api_id == api_id
	}!
	if tenant_api.len > 0 {
		log.debug('Tenant-level API matched ✅')
		return true
	}

	// ---------- Step6: 检查订阅应用级权限 ----------
	// 若请求包含 subapp_id，则检查 subapp 级授权
	if subapp_id != '' {
		app_api := sql db {
			select from schema_core.CoreRoleApi where role_id in role_ids && source_type == 'app'
			&& source_id == subapp_id && api_id == api_id
		}!
		if app_api.len > 0 {
			log.debug('Subapp-level API matched ✅')
			return true
		}
	}

	log.debug('Access denied for user ${tenant_id}:${user_id} on ${req_path}')
	return false
}

/* =========================================================
authority_middleware_core
=========================================================
中间件注册函数
- 在 veb 框架中注册为请求前执行的中间件
- 绑定 handler: authority_jwt_verify_core
=========================================================
*/
pub fn authority_middleware_core() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: authority_jwt_verify_core // 指定中间件主处理函数
		after:   false                     // 请求前执行
	}
}

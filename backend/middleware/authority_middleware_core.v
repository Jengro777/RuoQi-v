module middleware

import veb
import common.jwt
import log
import structs { Context }
import adapter.repository.middle

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

	// ---------- 读取 JWT 签名密钥 ----------
	secret := ctx.config.jwt.secret
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
	is_allowed := middle.authorize_and_check_api(mut ctx, req_token, tenant_id, subapp_id,
		ctx.req.url) or {
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

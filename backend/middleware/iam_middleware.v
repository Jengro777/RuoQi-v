module middleware

import veb
import structs { Context }
import common.jwt
import log

// =============================================================================
// IAM 统一认证中间件
//
// 验证 JWT → 提取 realm/user_id/role_ids → 注入 ctx.iam
// 中台和外部共用同一个中间件，realm 来自 JWT payload
// TODO: 安全增强 —— sys 和 external 应使用不同的 JWT secret
// =============================================================================

fn iam_jwt_verify(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	secret := ctx.config.jwt.secret

	auth_header := ctx.get_header(.authorization) or { '' }
	if auth_header.len == 0 || !auth_header.starts_with('Bearer ') {
		ctx.res.status_code = 401
		ctx.request_error('Missing or invalid authentication token')
		return false
	}

	req_token := auth_header.all_after('Bearer').trim_space()

	// 验证 JWT 签名
	verify := jwt.auth_verify(secret, req_token)
	if !verify {
		ctx.res.status_code = 401
		ctx.request_error('Authorization error')
		return false
	}

	// 解码 JWT payload，提取 IAM 上下文
	payload := jwt.jwt_decode(req_token) or {
		ctx.res.status_code = 401
		ctx.request_error('Failed to parse token')
		return false
	}

	// 注入 IAM 上下文
	ctx.svc_iam.user_id = payload.sub
	ctx.svc_iam.token_jwt = req_token
	ctx.svc_iam.role_ids = payload.role_ids

	// TODO: 后续根据 realm + role_ids 校验当前请求 URL 的访问权限
	// user_api_list := middle.get_userapilist_from_iam(mut ctx, req_token, payload.realm) or { return false }
	// if ctx.req.url !in user_api_list { ... return false }

	return true
}

pub fn iam_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: iam_jwt_verify
		after:   false
	}
}

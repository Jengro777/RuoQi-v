module middleware

import veb
import structs { Context }
import common.jwt
import log
import adapter.repository.middle

/* =============================================
JWT 权限认证中间件
=============================================
功能：
1. 从请求头中读取并验证 JWT Token
2. 验证 Token 是否在数据库中存在
3. 根据 Token 获取用户信息与角色
4. 校验该用户是否有访问当前 API 的权限
=============================================
*/
fn authority_jwt_verify(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// ---------- 读取 JWT 签名密钥 ----------
	secret := ctx.config.jwt.secret
	// 从标准 Header 中获取 Authorization: Bearer <token>
	auth_header := ctx.get_header(.authorization) or { '' }
	// log.debug('auth_header:${auth_header}')

	// 检查 Authorization 格式是否正确
	if auth_header.len == 0 || !auth_header.starts_with('Bearer ') {
		ctx.res.status_code = 401
		ctx.request_error('Missing or invalid authentication token')
		return false
	}

	// 去掉前缀 "Bearer" 并去除多余空格，得到 token 内容
	req_token := auth_header.all_after('Bearer').trim_space()
	log.debug('req_token: ${req_token}')

	// 使用 common.jwt 模块验证 token 签名有效性
	verify := jwt.jwt_verify(secret, req_token)
	if verify == false {
		ctx.res.status_code = 401
		ctx.request_error('Authorization request error ')
		log.warn('Authorization error')
		return false
	}

	// token放入全局
	ctx.svc_sys.token_jwt = req_token

	// >>>>> 权限验证阶段 >>>>>
	// 根据 token 获取用户所拥有的 API 路径列表
	user_api_list := middle.get_userapilist_from_token(mut ctx, req_token) or { return false }
	log.debug('user_api_list: ${user_api_list}')
	// 如果不是超级管理员（'*' 表示拥有所有权限）
	// 则校验当前请求 URL 是否在授权的接口列表中
	if ctx.req.url !in user_api_list {
		ctx.res.status_code = 403
		ctx.request_error("You don't have permission to perform this action")
		return false
	}
	// <<<<< 权限验证结束 <<<<<

	return true
}

/* =============================================
初始化中间件配置
=============================================
在 veb 框架中，MiddlewareOptions 用于注册中间件
handler：中间件处理函数
after：是否在路由处理后执行（false 表示在请求前执行）
=============================================
*/
pub fn authority_middleware_sys() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: authority_jwt_verify // 指定认证函数
		after:   false                // 在请求处理前执行
	}
}

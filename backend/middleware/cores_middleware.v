module middleware

import log
import os
import veb
import model { Context }

// cors_origins — 允许跨域请求的域名列表
//
// debug 模式：直接返回 ['*']，本地开发零配置
// 生产模式：从 CORS_ORIGINS 环境变量读取逗号分隔的白名单
//   CORS_ORIGINS: "https://app.example.com,https://admin.example.com"
//
// 为何生产未配置环境变量时也兜底 ['*'] 而非返回空：
//   1. CORS 是浏览器端约束，不影响服务端安全（curl / Postman / 后端服务调用不受限制）
//   2. 服务端安全由认证（Auth）+ 鉴权（Authorization）+ 限流（Rate Limit）保障，而非 CORS
//   3. allow_credentials 设为 false，与 '*' 兼容，浏览器不会拒绝
//
// 若启用 allow_credentials，则禁止使用 '*'，生产必须显式配置 CORS_ORIGINS。
fn cors_origins() []string {
	$if debug {
		return ['*']
	} $else {
		env_origins := os.getenv('CORS_ORIGINS')
		if env_origins != '' {
			return env_origins.split(',')
		}
		// 生产未配置 CORS_ORIGINS 时兜底放通，而非阻断
		return ['*']
	}
}

// 跨域中间件
pub fn cores_middleware(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	origins := cors_origins()

	// 使用cors中间件行跨域处理 ｜ use veb's cors middleware to handle CORS requests
	veb.cors[Context](veb.CorsOptions{
		origins: origins
		// 允许跨域请求的方法 ｜ allow CORS requests from methods:
		allowed_methods: [.get, .head, .patch, .put, .post, .delete, .options]
		allowed_headers: ['Authorization', 'Content-Type', 'WWW-Authorization']
		allow_credentials: false
		max_age: 3600
		expose_headers: [
			'Content-Length',
			'Authorization',
			'Content-Type',
			'X-Total-Count',
			'X-Page-Count',
			'X-Current-Page',
		]
	})
	return true
}

// 初始化中间件并设置 handler ,并返回中间件选项
pub fn cores_middleware_generic() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: cores_middleware // 显式初始化 handler 字段
		after: false // 请求处理前执行
	}
}

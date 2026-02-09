module middleware

import log
import veb
import structs { Context }

const cors_origin = ['*', 'xx.com']

// 跨域中间件
pub fn cores_middleware(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 使用cors中间件行跨域处理 ｜ use veb's cors middleware to handle CORS requests
	veb.cors[Context](veb.CorsOptions{
		// 允许跨域请求的域名 ｜ allow CORS requests from every domain
		origins: cors_origin // origins: ['*', 'xx.com']
		// 允许跨域请求的方法 ｜ allow CORS requests from methods:
		allowed_methods:   [.get, .head, .patch, .put, .post, .delete, .options]
		allowed_headers:   ['Authorization', 'Content-Type', 'WWW-Authorization']
		allow_credentials: false
		max_age:           3600
		expose_headers:    [
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
		after:   false            // 请求处理前执行
	}
}

// //备份跨域中间件使用方式,泛型方式。 只能单独使用
// pub fn cores_middleware_generic2() veb.MiddlewareOptions[Context] {
// 	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

// 	// 使用cors中间件行跨域处理 ｜ use veb's cors middleware to handle CORS requests
// 	mut cors_middleware_context := veb.cors[Context](veb.CorsOptions{
// 		// 允许跨域请求的域名 ｜ allow CORS requests from every domain
// 		origins: cors_origin // origins: ['*', 'xx.com']
// 		// 允许跨域请求的方法 ｜ allow CORS requests from methods:
// 		allowed_methods: [.get, .head, .patch, .put, .post, .delete, .options]
// 		allowed_headers: ['Authorization', 'Content-Type', 'WWW-Authorization']
// 	})
// 	log.debug('${cors_middleware_context}')

// 	return cors_middleware_context
// }

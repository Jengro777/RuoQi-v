module middleware

import log
import veb
import structs { Context }

//日志中间件
pub fn logger_middleware(mut ctx Context) bool {
	//请求信息
	log.info('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
	log.info('req.host: ${ctx.req.host}')
	log.info('req.url: ${ctx.req.url}')
	log.info('req.method: ${ctx.req.method}')
	log.info('req.version: ${ctx.req.version}')
	log.info('req.proxy: ${ctx.req.proxy}')
	log.info('req.user_agent: ${ctx.req.user_agent}')
	log.info('req.read_timeout: ${ctx.req.read_timeout}')
	log.info('req.write_timeout: ${ctx.req.write_timeout}')
	log.info('req.validate: ${ctx.req.validate}')
	log.info('req.verify: ${ctx.req.verify}')
	log.info('req.cert: ${ctx.req.cert}')
	log.info('req.cert_key: ${ctx.req.cert_key}')
	log.info('req.allow_redirect: ${ctx.req.allow_redirect}')
	log.info('req.max_retries: ${ctx.req.max_retries}')
	log.info('req.on_redirect: ${ctx.req.on_redirect}')
	log.info('req.on_progress: ${ctx.req.on_progress}')
	log.info('req.on_progress_body: ${ctx.req.on_progress_body}')
	log.info('req.on_finish: ${ctx.req.on_finish}')
	log.info('req.stop_copying_limit: ${ctx.req.stop_copying_limit}')
	log.info('req.stop_receiving_limit: ${ctx.req.stop_receiving_limit}')
	log.info('req.header: ${ctx.req.header}')
	log.info('req.data: ${ctx.req.data}')

	//响应信息,需要设置 after: true
	log.info('res.http_version: ${ctx.res.http_version}')
	log.info('res.header: ${ctx.res.header}')
	log.info('res.status_code: ${ctx.res.status_code}')
	log.info('res.status_msg: ${ctx.res.status_msg}')
	log.info('res.body: ${ctx.res.body}')

	return true
}

// 初始化中间件并设置 handler ,并返回中间件选项
pub fn logger_middleware_generic() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: logger_middleware // 显式初始化 handler 字段
		after:   true              // 请求处理后执行
	}
}

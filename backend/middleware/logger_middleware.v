module middleware

import log
import veb
import model { Context }

// 日志中间件 — 记录请求/响应元数据
// 注意：含敏感信息的 debug 日志已注释，需要排查问题时临时取消注释
pub fn logger_middleware(mut ctx Context) bool {
	// 请求信息
	log.info('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>')
	log.info('req.host: ${ctx.req.host}')
	log.info('req.url: ${ctx.req.url}')
	log.info('req.method: ${ctx.req.method}')
	log.debug('req.version: ${ctx.req.version}')
	log.debug('req.proxy: ${ctx.req.proxy}')
	log.debug('req.user_agent: ${ctx.req.user_agent}')
	log.debug('req.read_timeout: ${ctx.req.read_timeout}')
	log.debug('req.write_timeout: ${ctx.req.write_timeout}')
	log.debug('req.validate: ${ctx.req.validate}')
	log.debug('req.verify: ${ctx.req.verify}')
	log.debug('req.cert: ${ctx.req.cert}')
	log.debug('req.cert_key: ${ctx.req.cert_key}')
	log.debug('req.allow_redirect: ${ctx.req.allow_redirect}')
	log.debug('req.max_retries: ${ctx.req.max_retries}')
	log.debug('req.on_redirect: ${ctx.req.on_redirect}')
	log.debug('req.on_progress: ${ctx.req.on_progress}')
	log.debug('req.on_progress_body: ${ctx.req.on_progress_body}')
	log.debug('req.on_finish: ${ctx.req.on_finish}')
	log.debug('req.stop_copying_limit: ${ctx.req.stop_copying_limit}')
	log.debug('req.stop_receiving_limit: ${ctx.req.stop_receiving_limit}')

	// 以下包含敏感信息（JWT Token、AK/SK、密码、PII），默认关闭
	// 排查 Auth/参数问题时临时取消注释，排查完毕后恢复注释
	// log.debug('req.header: ${ctx.req.header}')
	// log.debug('req.data: ${ctx.req.data}')

	// 响应信息
	log.debug('res.http_version: ${ctx.res.http_version}')
	// 响应头可能包含 Set-Cookie 等敏感信息，默认关闭
	// log.info('res.header: ${ctx.res.header}')
	log.info('res.status_code: ${ctx.res.status_code}')
	log.info('res.status_msg: ${ctx.res.status_msg}')

	// 响应体可能包含用户数据，默认关闭
	// log.debug('res.body: ${ctx.res.body}')

	return true
}

// 初始化中间件并设置 handler ,并返回中间件选项
pub fn logger_middleware_generic() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: logger_middleware // 显式初始化 handler 字段
		after: true // 请求处理后执行
	}
}

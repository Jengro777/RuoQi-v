module route

import log
import structs { Context }
import middleware
import service.db_api { Base }

fn (mut app AliasApp) routes_db(mut ctx Context) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	// 方式一: 直接使用中间件，适合对单个控制器单独使用中间件
	mut base_app := &Base{}
	base_app.use(handler: middleware.cores_middleware)
	base_app.use(handler: middleware.logger_middleware)
	base_app.use(middleware.config_middle(ctx.config))
	base_app.use(middleware.db_middleware(ctx.dbpool))
	app.register_controller[Base, Context]('/base', mut base_app) or { log.error('${err}') }
}

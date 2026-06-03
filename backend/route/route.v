module route

import log
import veb
import structs { Context }
import middleware

// 通用中间件设置函数 - 减少代码重复
pub fn (mut app AliasApp) common_middleware[T, U](mut ctrl T, mut ctx Context) {
	ctrl.use(middleware.cores_middleware_generic())
	ctrl.use(middleware.logger_middleware_generic())
	ctrl.use(middleware.config_middle(ctx.config))
	ctrl.use(middleware.db_middleware(ctx.dbpool))
	ctrl.use(middleware.i18n_middleware(ctx.i18n))
}

fn (mut app AliasApp) register_routes_no_auth[T, U](mut ctrl T, url_path string, mut ctx Context) {
	app.common_middleware[T, U](mut ctrl, mut ctx)
	app.register_controller[T, U](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

fn (mut app AliasApp) register_routes_sys[T, U](mut ctrl T, url_path string, mut ctx Context) {
	app.common_middleware[T, U](mut ctrl, mut ctx)
	ctrl.use(middleware.authority_middleware_sys())
	app.register_controller[T, U](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

fn (mut app AliasApp) register_routes_core[T, U](mut ctrl T, url_path string, mut ctx Context) {
	app.common_middleware[T, U](mut ctrl, mut ctx)
	ctrl.use(middleware.authority_middleware_core())
	app.register_controller[T, U](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

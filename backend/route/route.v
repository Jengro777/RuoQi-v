module route

import log
import veb
import structs { Context }
import adapter.datascope { ScopeConfig, ScopeField }
import middleware

// 通用中间件设置函数 - 减少代码重复
pub fn (mut app AliasApp) common_middleware[T, U](mut ctrl T, mut ctx Context) {
	ctrl.use(middleware.cores_middleware_generic())
	ctrl.use(middleware.logger_middleware_generic())
	ctrl.use(middleware.config_middle(ctx.config))
	ctrl.use(middleware.db_middleware(ctx.dbpool))
	ctrl.use(middleware.locale_middleware(ctx.locale))
}

fn (mut app AliasApp) register_routes_no_auth[T, U](mut ctrl T, url_path string, mut ctx Context) {
	app.common_middleware[T, U](mut ctrl, mut ctx)
	app.register_controller[T, U](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

fn (mut app AliasApp) register_routes_pay[T, U](mut ctrl T, url_path string, mut ctx Context) {
	app.common_middleware[T, U](mut ctrl, mut ctx)
	ctrl.use(middleware.iam_middleware())
	app.register_controller[T, U](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

fn (mut app AliasApp) register_routes_platform[T, U](mut ctrl T, url_path string, mut ctx Context) {
	ctrl.use(middleware.iam_middleware())
	app.common_middleware[T, U](mut ctrl, mut ctx)
	ctrl.use(middleware.datascope_middleware(ScopeConfig{ enabled_fields: []ScopeField{} }))
	app.register_controller[T, U](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

fn (mut app AliasApp) register_routes_workspace[T, U](mut ctrl T, url_path string, mut ctx Context) {
	app.common_middleware[T, U](mut ctrl, mut ctx)
	ctrl.use(middleware.iam_middleware())
	ctrl.use(middleware.datascope_middleware(ScopeConfig{
		enabled_fields: [
			ScopeField.tenant_id,
			ScopeField.workspace_id,
		]
	}))
	app.register_controller[T, U](url_path, mut ctrl) or { log.error('${err}') }
	ctrl.route_use('${url_path}/*', veb.encode_auto[Context]())
}

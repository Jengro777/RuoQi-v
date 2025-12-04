module main

import veb
import log
import structs { Context }
import middleware
import config
import i18n
import route { AliasApp }

pub fn new_app() {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	//*******init_config_loader********/
	log.debug('init_config_loader()')
	mut loader := config.new_config_loader()
	doc := loader.get_config() or { panic('Failed to load config: ${err}') }
	log.debug('${doc}')
	//********init_config_loader*******/

	i18n_app := i18n.new_i18n('./etc/locales', 'zh') or { return }

	//*******init_db_pool********/
	log.debug('init_db_pool()')
	mut conn := middleware.init_db_pool(doc) or {
		log.warn('db_pool 初始化失败: ${err}')
		return
	}
	defer {
		conn.close()
	}
	//*******init_db_pool********/

	mut app := &AliasApp{
		started: chan bool{cap: 1} // 关键：正确初始化通道
	} // 实例化 App 结构体 并返回指针

	// 全局 Context
	mut ctx := &Context{
		dbpool: conn
		config: doc
		i18n:   i18n_app
	}

	// 路由控制器,仅作用于非子路由(必须,不然会报错)
	app.use(middleware.cores_middleware_generic())
	app.use(middleware.logger_middleware_generic())
	app.use(middleware.config_middle(ctx.config))
	app.use(middleware.db_middleware(ctx.dbpool))
	app.use(middleware.i18n_middleware(ctx.i18n))
	app.use(veb.encode_gzip[Context]())

	// 子路由控制器
	app.setup_conditional_routes(mut ctx)

	veb.run_at[AliasApp, Context](mut app,
		host:               ''
		port:               doc.web.port
		family:             .ip6
		timeout_in_seconds: doc.web.timeout
	) or { return }
}

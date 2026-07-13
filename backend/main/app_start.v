module main

import os
import veb
import log
import time
import structs { Context }
import middleware
import config
import locale
import route { AliasApp }

fn serve_http(mut app AliasApp, port int, request_timeout int) {
	veb.run_at[AliasApp, Context](mut app,
		host:               ''
		port:               port
		family:             .ip6
		timeout_in_seconds: request_timeout
	) or { panic(err) }
}

fn serve_until_shutdown(mut app AliasApp, web config.WebConf) {
	server_thread := spawn serve_http(mut app, web.port, web.request_timeout)

	// 等待 Ctrl+C 或 SIGTERM，再执行 veb 的优雅关闭。
	_ := <-app.shutdown_signal

	log.info('shutting down web server gracefully...')
	shutdown_veb_server(app, web.shutdown_timeout) or { log.error('${err}') }
	server_thread.wait()
	log.info('graceful shutdown complete')
}

fn setup_app_middleware(mut app AliasApp, ctx &Context) {
	app.use(middleware.cores_middleware_generic()) // 跨域中间件
	app.use(middleware.logger_middleware_generic())
	app.use(middleware.config_middle(ctx.config))
	// app.use(middleware.db_middleware(ctx.cache_pool))
	app.use(middleware.db_middleware(ctx.dbpool))
	app.use(middleware.locale_middleware(ctx.locale))
	app.use(veb.encode_auto[Context]())
}

fn shutdown_veb_server(app &AliasApp, timeout_seconds int) ! {
	server := app.server
	if server == unsafe { nil } {
		return error('veb server was not initialized')
	}
	server.shutdown(timeout: timeout_seconds * time.second)!
}

pub fn new_app() {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 1. 加载配置，后续依赖都从同一份配置对象读取。
	log.debug('init_config_loader()')
	mut loader := config.new_config_loader()
	doc := loader.get_config() or { panic('Failed to load config: ${err}') }

	// 2. 初始化国际化资源。
	locale_app := locale.new_locale('./etc/locales', 'zh') or { return }

	// 3. 初始化数据库连接池；函数退出时关闭连接池。
	log.debug('init_db_pool()')
	mut conn_db := middleware.init_db_pool(doc) or {
		log.warn('db_pool 初始化失败: ${err}')
		return
	}
	defer {
		conn_db.close()
	}

	// 4. 初始化缓存连接池。
	log.debug('init_cache_pool()')
	mut conn_cache := middleware.init_cache_pool(doc) or {
		log.warn('cache_pool 初始化失败: ${err}')
		return
	}

	// 5. 创建 veb 应用实例，并注册系统关闭信号。
	mut app := &AliasApp{
		started:         chan bool{cap: 1}
		shutdown_signal: chan bool{cap: 1}
	}
	os.signal_opt(.int, fn [app] (_ os.Signal) {
		app.request_shutdown()
	}) or { panic(err) }
	os.signal_opt(.term, fn [app] (_ os.Signal) {
		app.request_shutdown()
	}) or { panic(err) }

	// 6. 构造全局请求上下文，供中间件和路由共享基础依赖。
	mut ctx := &Context{
		cache_pool: conn_cache
		dbpool:     conn_db
		config:     doc
		locale:     locale_app
	}

	// 7. 注册全局中间件，仅作用于非子路由。
	setup_app_middleware(mut app, ctx)

	// 8. 注册按条件启用的子路由控制器。
	app.setup_conditional_routes(mut ctx)

	// 9. 启动 HTTP 服务，并阻塞等待 Ctrl+C 或 SIGTERM 后优雅关闭。
	serve_until_shutdown(mut app, doc.web)
}

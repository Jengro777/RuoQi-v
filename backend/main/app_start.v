module main

import os
import veb
import log
import time
import structs { Context }
import middleware
import config
import i18n
import route { AliasApp }

fn start_veb_server(mut app AliasApp, port int, timeout int) {
	veb.run_at[AliasApp, Context](mut app,
		host:               ''
		port:               port
		family:             .ip6
		timeout_in_seconds: timeout
	) or { panic(err) }
}

fn wait_for_veb_server(app &AliasApp, timeout_seconds int) ! {
	retry_period_ms := 100
	max_retries := timeout_seconds * 10
	for _ in 0 .. max_retries {
		server := app.server
		if server != unsafe { nil } {
			server.wait_till_running(max_retries: max_retries, retry_period_ms: retry_period_ms)!
			return
		}
		time.sleep(retry_period_ms * time.millisecond)
	}
	return error('veb server did not start within ${timeout_seconds} seconds')
}

fn shutdown_veb_server(app &AliasApp, timeout_seconds int) ! {
	server := app.server
	if server == unsafe { nil } {
		return error('veb server was not initialized')
	}
	server.shutdown(timeout: timeout_seconds * time.second)!
}

fn setup_app_middleware(mut app AliasApp, ctx &Context) {
	app.use(middleware.cores_middleware_generic()) // 跨域中间件
	app.use(middleware.logger_middleware_generic())
	app.use(middleware.config_middle(ctx.config))
	// app.use(middleware.db_middleware(ctx.cache_pool))
	app.use(middleware.db_middleware(ctx.dbpool))
	app.use(middleware.i18n_middleware(ctx.i18n))
	app.use(veb.encode_auto[Context]())
}

fn run_app_lifecycle(mut app AliasApp, web config.WebConf) {
	server_thread := spawn start_veb_server(mut app, web.port, web.request_timeout)
	wait_for_veb_server(app, web.startup_timeout) or {
		log.error('${err}')
		return
	}

	//阻塞等待关闭信号，信号来源包括 Ctrl+C、SIGTERM 和 /shutdown 路由
	_ := <-app.shutdown_signal

	log.info('shutting down web server gracefully...')
	shutdown_veb_server(app, web.shutdown_timeout) or { log.error('${err}') }
	server_thread.wait()
	log.info('graceful shutdown complete')
}

pub fn new_app() {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	//*******init_config_loader********/
	log.debug('init_config_loader()')
	mut loader := config.new_config_loader()
	doc := loader.get_config() or { panic('Failed to load config: ${err}') }
	// log.debug('${doc}')
	//********init_config_loader*******/

	i18n_app := i18n.new_i18n('./etc/locales', 'zh') or { return }

	//*******init_db_pool********/
	log.debug('init_db_pool()')
	mut conn_db := middleware.init_db_pool(doc) or {
		log.warn('db_pool 初始化失败: ${err}')
		return
	}
	defer {
		conn_db.close()
	}
	//*******init_db_pool********/

	//*******init_cache_pool********/
	log.debug('init_cache_pool()')
	mut conn_cache := middleware.init_cache_pool(doc) or {
		log.warn('cache_pool 初始化失败: ${err}')
		return
	}
	//*******init_cache_pool********/

	mut app := &AliasApp{
		started:         chan bool{cap: 1} // 关键：正确初始化通道
		shutdown_signal: chan bool{cap: 1}
	}
	os.signal_opt(.int, fn [app] (_ os.Signal) {
		app.request_shutdown()
	}) or { panic(err) }
	os.signal_opt(.term, fn [app] (_ os.Signal) {
		app.request_shutdown()
	}) or { panic(err) }

	// 全局 Context
	mut ctx := &Context{
		cache_pool: conn_cache
		dbpool:     conn_db
		config:     doc
		i18n:       i18n_app
	}

	// 路由控制器,仅作用于非子路由(必须,不然会报错)
	setup_app_middleware(mut app, ctx)

	// 子路由控制器
	app.setup_conditional_routes(mut ctx)

	run_app_lifecycle(mut app, doc.web)
}

module main

import os
import veb
import structs { App, Context }
import middleware
import service

pub struct AliasApp {
	App
}

// 模拟业务接口
@['/user'; get]
fn (app &AliasApp) users(mut ctx Context) veb.Result {
	mut q := service.new_query('users')
	service.apply_data_scope(mut q, ctx, 'users')
	users := q.all()
	return ctx.json(users)
}

@['/test'; get]
fn (app &AliasApp) test(mut ctx Context) veb.Result {
	return ctx.json({
		'msg': 'test endpoint, no data filter applied'
	})
}

fn main() {
	port := 9008
	mut app := &AliasApp{}

	if os.getenv('ENABLE_DATA_PERM') == 'true' {
		app.use(middleware.data_perm_middleware())
		println('✅ Data permission middleware enabled (Header mode)')
	} else {
		println('🚫 Data permission middleware disabled')
	}

	veb.run[AliasApp, Context](mut app, port)
}

// 尚未完成,暂不能移植

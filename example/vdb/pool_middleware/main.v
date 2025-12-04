module main

import veb
import api { Context }
import middleware

struct App {
	veb.Middleware[Context]
	veb.Controller
	veb.StaticHandler
}

fn main() {
	mut conn := middleware.init_db_pool() or {
		eprintln('init error: ${err}')
		return
	}
	defer {
		conn.close()
	}

	mut app := &App{}
	app.use(middleware.db_middleware(conn))
	app.handler_base(conn)

	veb.run[App, Context](mut app, 9008)
}

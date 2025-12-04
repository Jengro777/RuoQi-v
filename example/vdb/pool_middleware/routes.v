module main

import log
import api { Context }
import base { Base }
import middleware
import dbpool

fn (mut app App) handler_base(conn &dbpool.DatabasePool) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	mut base_app := &Base{}
	base_app.use(middleware.db_middleware(conn)) // Not enabled here, accessing/base/index will result in memory exceptions.
	app.register_controller[Base, Context]('/base', mut base_app) or { log.error('${err}') }
}

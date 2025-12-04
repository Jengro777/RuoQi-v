module base

import veb
import log
import api { Context }

pub struct Base {
	veb.Middleware[Context]
}

@['/index']
fn (mut app Base) index(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	mut db, conn := ctx.dbpool.acquire() or { return ctx.text('acquire: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('release: ${err}') }
	}
	mut rows := sql db {
		select from api.SysUser
	} or { return ctx.text('${@LOCATION}: ${err}') }
	dump(rows)
	return ctx.text(rows.str())
}

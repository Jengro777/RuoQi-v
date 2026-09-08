module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_pay
import adapter.dbpool

fn (app &Database) init_pay_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_pay.PayRefund
		create table schema_pay.PayOrderExtension
		create table schema_pay.PayOrder
		create table schema_pay.PayDemoOrder
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_pay init success')

	return
}

@['/init/init_pay'; get]
pub fn (app &Database) init_pay(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_pay_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_pay failed: ${err}'))
	}
	return ctx.json(api.json_success(data: 'Pay database init Successfull'))
}

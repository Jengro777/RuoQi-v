module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_pay

@['/init/init_pay'; get]
pub fn (app &Base) init_pay(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	db, conn := ctx.dbpool.acquire() or {
		return ctx.json(api.json_error_500('Failed to acquire connection: ${err}'))
	}
	defer {
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	sql db {
		create table schema_pay.PayRefund
		create table schema_pay.PayOrderExtension
		create table schema_pay.PayOrder
		create table schema_pay.PayDemoOrder
	} or { return ctx.text('error creating table:  ${err}') }
	log.debug('Database init_pay success')

	return ctx.json(api.json_success_200('Pay database init Successfull'))
}

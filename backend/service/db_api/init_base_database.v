module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_base
import adapter.dbpool

fn (app &Database) init_base_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_base.BaseRegion
		create table schema_base.BaseRegionAdmDiv
		create table schema_base.BaseCurrency
		create table schema_base.BaseLanguage
		create table schema_base.BaseUtc
		create table schema_base.BaseTimeZone
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_base init success')

	return
}

@['/init/init_base'; get]
pub fn (app &Database) init_base(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_base_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_base failed: ${err}'))
	}
	return ctx.json(api.json_success(data: 'base database init Successfull'))
}

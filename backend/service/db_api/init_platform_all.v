module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_platform
import adapter.dbpool

fn (app &Database) init_platform_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_platform.PfMenu
		create table schema_platform.PfApi
		create table schema_platform.PfConfig
		create table schema_platform.PfDictionary
		create table schema_platform.PfDictionaryDetail
		create table schema_platform.PfProduct
		create table schema_platform.PfPortal
		create table schema_platform.PfPlan
		create table schema_platform.PfPlanPrice
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_platform init success')
	platform_upsert(db) or { return error('Failed to upsert seed data: ${err}') }
	log.info('schema_platform seed data success')

	return
}

@['/init/init_platform'; get]
pub fn (app &Database) init_platform(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_platform_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'init_platform failed: ${err}'
		))
	}
	return ctx.json(api.json_success(data: 'Platform database init Successfull'))
}

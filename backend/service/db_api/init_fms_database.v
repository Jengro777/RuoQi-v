module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_fms
import adapter.dbpool

fn (app &Database) init_fms_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_fms.FmsStorageProvider
		create table schema_fms.FmsFileJoinTag
		create table schema_fms.FmsFile
		create table schema_fms.FmsFileTag
		create table schema_fms.FmsCloudFileCloudFileTag
		create table schema_fms.FmsCloudFile
		create table schema_fms.FmsCloudFileTag
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_fms init success')

	return
}

@['/init/init_fms'; get]
pub fn (app &Database) init_fms(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_fms_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_fms failed: ${err}'))
	}
	return ctx.json(api.json_success(data: 'FMF database init Successfull'))
}

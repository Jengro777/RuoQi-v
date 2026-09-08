module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_iam
import adapter.dbpool

fn (app &Database) init_iam_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_iam.IamUser
		create table schema_iam.IamToken
		create table schema_iam.IamApiKey
		create table schema_iam.IamConfiguration
		create table schema_iam.IamConnector
		create table schema_iam.IamUserConnector
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_iam init success')
	iam_upsert(db) or { return error('Failed to upsert seed data: ${err}') }
	log.info('schema_iam seed data success')

	return
}

@['/init/init_iam'; get]
pub fn (app &Database) init_iam(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_iam_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_iam failed: ${err}'))
	}
	return ctx.json(api.json_success(data: 'IAM database init Successful'))
}

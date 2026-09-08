module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_msg
import adapter.dbpool

fn (app &Database) init_mcms_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_msg.MsgSmsProvider
		create table schema_msg.MsgSmsLog
		create table schema_msg.MsgSiteNotification
		create table schema_msg.MsgSiteInnerMsg
		create table schema_msg.MsgSiteInnerCategory
		create table schema_msg.MsgEmailProvider
		create table schema_msg.MsgEmailLog
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_msg init success')

	return
}

@['/init/init_mcms'; get]
pub fn (app &Database) init_mcms(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_mcms_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_mcms failed: ${err}'))
	}
	return ctx.json(api.json_success(data: 'mcms database init Successfull'))
}

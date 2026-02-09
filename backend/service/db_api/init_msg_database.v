module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_msg

@['/init/init_mcms'; get]
pub fn (app &Base) init_mcms(mut ctx Context) veb.Result {
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
		create table schema_msg.MsgSmsProvider
		create table schema_msg.MsgSmsLog
		create table schema_msg.MsgSiteNotification
		create table schema_msg.MsgSiteInnerMsg
		create table schema_msg.MsgSiteInnerCategory
		create table schema_msg.MsgEmailProvider
		create table schema_msg.MsgEmailLog
	} or { return ctx.text('error creating table:  ${err}') }
	log.debug('Database init_mcms success')

	return ctx.json(api.json_success_200('mcms database init Successfull'))
}

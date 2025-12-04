module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_base

@['/init/init_base'; get]
pub fn (app &Base) init_base(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	db, conn := ctx.dbpool.acquire() or {
		return ctx.json(api.json_error_500('获取的连接无效: ${err}'))
	}
	defer {
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	sql db {
		create table schema_base.BaseRegion
		create table schema_base.BaseAdministrativeDivision
	} or { return ctx.text('error creating table:  ${err}') }
	log.info('schema_core init_core success')

	return ctx.json(api.json_success_200('core database init Successfull'))
}

module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_platform

@['/init/init_platform'; get]
pub fn (app &Base) init_platform(mut ctx Context) veb.Result {
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
		create table schema_platform.PfMenu
		create table schema_platform.PfApi
		create table schema_platform.PfConfiguration
		create table schema_platform.PfDictionary
		create table schema_platform.PfDictionaryDetail
		create table schema_platform.PfProduct
		create table schema_platform.PfPlan
		create table schema_platform.PfPlanPrice
	} or { return ctx.text('error creating table:  ${err}') }
	log.info('schema_platform init success')

	return ctx.json(api.json_success_200('Platform database init Successfull'))
}

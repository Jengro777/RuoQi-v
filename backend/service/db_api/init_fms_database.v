module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_fms

@['/init/init_fms'; get]
pub fn (app &Base) init_fms(mut ctx Context) veb.Result {
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
		create table schema_fms.FmsStorageProvider
		create table schema_fms.FmsFileJoinTag
		create table schema_fms.FmsFile
		create table schema_fms.FmsFileTag
		create table schema_fms.FmsCloudFileCloudFileTag
		create table schema_fms.FmsCloudFile
		create table schema_fms.FmsCloudFileTag
	} or { return ctx.text('error creating table:  ${err}') }
	log.debug('Database init_fms success')

	return ctx.json(api.json_success_200('FMF database init Successfull'))
}

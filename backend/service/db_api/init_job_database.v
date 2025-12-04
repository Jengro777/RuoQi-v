module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_job

@['/init/init_job'; get]
pub fn (app &Base) init_job(mut ctx Context) veb.Result {
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
		create table schema_job.JobTask
		create table schema_job.JobTaskLog
	} or { return ctx.text('error creating table:  ${err}') }
	log.debug('Database init_job success')

	return ctx.json(api.json_success_200('job database init Successfull'))
}

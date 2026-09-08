module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_job
import adapter.dbpool

fn (app &Database) init_job_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_job.JobTask
		create table schema_job.JobTaskLog
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_job init success')

	return
}

@['/init/init_job'; get]
pub fn (app &Database) init_job(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_job_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: 'init_job failed: ${err}'))
	}
	return ctx.json(api.json_success(data: 'job database init Successfull'))
}

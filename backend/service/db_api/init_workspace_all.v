module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_workspace
import adapter.dbpool

fn (app &Database) init_workspace_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_workspace.WsWorkspace
		create table schema_workspace.WsRole
		create table schema_workspace.WsMember
		create table schema_workspace.WsMemberRole
		create table schema_workspace.WsRoleApi
		create table schema_workspace.WsRoleMenu
		create table schema_workspace.WsDepartment
		create table schema_workspace.WsPosition
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_workspace init success')
	workspace_upsert(db) or { return error('Failed to upsert seed data: ${err}') }
	log.info('schema_workspace seed data success')

	return
}

@['/init/init_workspace'; get]
pub fn (app &Database) init_workspace(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_workspace_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'init_workspace failed: ${err}'
		))
	}
	return ctx.json(api.json_success(data: 'Workspace database init Successfull'))
}

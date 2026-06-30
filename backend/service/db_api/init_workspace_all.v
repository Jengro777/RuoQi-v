module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_workspace

@['/init/init_workspace'; get]
pub fn (app &Base) init_workspace(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := ctx.dbpool.acquire() or {
		return ctx.json(api.json_error_500('获取的连接无效: ${err}'))
	}
	defer {
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	sql db {
		create table schema_workspace.WsWorkspace
		create table schema_workspace.WsMember
		create table schema_workspace.WsRoleApi
		create table schema_workspace.WsRoleMenu
		create table schema_workspace.WsDepartment
		create table schema_workspace.WsPosition
	} or { return ctx.text('error creating table:  ${err}') }
	log.info('schema_workspace init success')

	log.info('insert sys data')
	sql_commands := [ws_workspace, ws_member, ws_department, ws_position]
	for cmd in sql_commands {
		db.execute(cmd) or {
			return ctx.json(api.json_error_500('执行 ${cmd} SQL失败: ${err}'))
		}
		log.info('${cmd} init_sys_data success')
	}

	return ctx.json(api.json_success_200('Workspace database init Successfull'))
}

module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_sys

@['/init/init_sys'; get]
pub fn (app &Base) init_sys(mut ctx Context) veb.Result {
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
		create table schema_sys.SysUser
		create table schema_sys.SysUserRole
		create table schema_sys.SysUserDepartment
		create table schema_sys.SysUserPosition
		create table schema_sys.SysToken
		create table schema_sys.SysRole
		create table schema_sys.SysRoleApi
		create table schema_sys.SysRoleMenu
		create table schema_sys.SysPosition
		create table schema_sys.SysConnector
		create table schema_sys.SysMenu
		create table schema_sys.SysDictionaryDetail
		create table schema_sys.SysDictionary
		create table schema_sys.SysDepartment
		create table schema_sys.SysConfiguration
		create table schema_sys.SysCasbinRule
		create table schema_sys.SysApi
	} or { return ctx.text('error creating table:  ${err}') }
	log.info('schema_sys init_sys success')

	log.info('insert sys data')
	sql_commands := [sys_user, sys_token, sys_department, sys_position, sys_role, sys_api, sys_menu,
		sys_user_department, sys_user_position, sys_user_role, sys_role_api, sys_role_menu]
	for cmd in sql_commands {
		db.exec(cmd) or { return ctx.json(api.json_error_500('执行 ${cmd} SQL失败: ${err}')) }
		log.info('${cmd} init_sys_data success')
	}

	return ctx.json(api.json_success_200('sys database init Successfull'))
}

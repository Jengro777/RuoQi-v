module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_core

@['/init/init_core'; get]
pub fn (app &Base) init_core(mut ctx Context) veb.Result {
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
		create table schema_core.CoreApi
		create table schema_core.CoreApp
		create table schema_core.CoreAppClient
		create table schema_core.CoreConnector
		create table schema_core.CoreMenu
		create table schema_core.CoreProject
		create table schema_core.CoreRole
		create table schema_core.CoreRoleApi
		create table schema_core.CoreRoleMenu
		create table schema_core.CoreRoleTenantMember
		create table schema_core.CoreTenant
		create table schema_core.CoreTenantMember
		create table schema_core.CoreTenantSubApp
		create table schema_core.CoreToken
		create table schema_core.CoreUser
		create table schema_core.CoreUserConnector
	} or { return ctx.text('error creating table:  ${err}') }
	log.info('schema_core init_core success')

	log.info('insert core data')
	sql_commands := [core_api, core_app, core_app_client, core_connector, core_menu, core_project,
		core_role, core_role_api, core_role_menu, core_role_tenant_member, core_tenant,
		core_tenant_member, core_tenant_subapp, core_token, core_user, core_user_connector]
	for cmd in sql_commands {
		db.exec(cmd) or { return ctx.json(api.json_error_500('执行 ${cmd} SQL失败: ${err}')) }
		log.info('${cmd} init_core_data success')
	}

	return ctx.json(api.json_success_200('core database init Successfull'))
}

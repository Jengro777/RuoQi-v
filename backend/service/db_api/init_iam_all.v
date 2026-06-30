module db_api

import veb
import log
import common.api
import structs { Context }
import structs.schema_iam

@['/init/init_iam'; get]
pub fn (app &Base) init_iam(mut ctx Context) veb.Result {
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
		create table schema_iam.IamUser
		create table schema_iam.IamRole
		create table schema_iam.IamUserRole
		create table schema_iam.IamToken
		create table schema_iam.IamConfiguration
		create table schema_iam.IamConnector
		create table schema_iam.IamUserConnector
	} or { return ctx.text('error creating table:  ${err}') }
	log.info('schema_iam init success')

	sql_commands := [iam_user, iam_role, iam_user_role]
	for cmd in sql_commands {
		db.execute(cmd) or {
			return ctx.json(api.json_error_500('执行 ${cmd} SQL失败: ${err}'))
		}
		log.info('${cmd} init_sys_data success')
	}

	return ctx.json(api.json_success_200('IAM database init Successfull'))
}

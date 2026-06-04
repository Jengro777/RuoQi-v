/*
 * @Author: RuoQi
 * @Date: 2025-11-28
 * @Description:  login 用户角色列表
 */

module user

import veb
import log
import structs.schema_sys { SysUserRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/perm'; get; post]
pub fn (app &User) find_user_perm_code_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := find_user_perm_code_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn find_user_perm_code_usecase(mut ctx Context) ![]string {
	// Domain 校验
	find_user_perm_code_domain()!

	// Repository 获取数据
	return find_user_perm_code(mut ctx, ctx.svc_sys.user_id)
}

// ----------------- Domain 层 -----------------
fn find_user_perm_code_domain() ! {
	//
}

// ----------------- DTO 层 -----------------
pub struct PermByIdReq {
	//
}

pub struct PermByIdResp {
	// role_ids []string @[json: 'roleIds']
}

// ----------------- Repository 层 -----------------
fn find_user_perm_code(mut ctx Context, user_id string) ![]string {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	result := sql db {
		select from SysUserRole where user_id == user_id
	} or { return error('Failed to query user role') }

	log.debug(result.str())
	if result.len == 0 {
		return error('Role Permission not found')
	}

	role_ids := result[0].role_id.split(',')
	return role_ids
}

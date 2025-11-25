// perm
module user

import veb
import log
import structs.schema_sys { SysUserRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/perm'; get; post]
pub fn (app &User) perm_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := perm_by_id_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn perm_by_id_usecase(mut ctx Context) ![]string {
	// Domain 校验
	perm_by_id_domain()!

	// Repository 获取数据
	return perm_by_id(mut ctx)
}

// ----------------- Domain 层 -----------------
fn perm_by_id_domain() ! {
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
fn perm_by_id(mut ctx Context) ![]string {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	// 从标准 Header 中获取 Authorization: Bearer <token>
	auth_header := ctx.get_header(.authorization) or { '' }
	log.debug(auth_header)

	// 去掉前缀 "Bearer" 并去除多余空格，得到 token 内容
	req_token := auth_header.all_after('Bearer').trim_space()
	log.debug(req_token)

	// step1: 根据 token 查找 SysToken 表，验证 token 是否存在
	sys_token := sql db {
		select from schema_sys.SysToken where token == req_token limit 1
	}!
	if sys_token.len != 1 {
		return error('Token not found')
	}
	log.debug('user_id: ${sys_token[0].user_id}')

	log.debug(ctx.user_id)
	result := sql db {
		select from SysUserRole where user_id == sys_token[0].user_id
	} or { return error('Failed to query user role') }

	log.debug(result.str())
	if result.len == 0 {
		return error('Role Permission not found')
	}

	role_ids := result[0].role_id.split(',')
	return role_ids
}

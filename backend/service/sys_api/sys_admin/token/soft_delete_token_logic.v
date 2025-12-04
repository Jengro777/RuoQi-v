module token

import veb
import log
import x.json2 as json
import structs.schema_sys { SysToken }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/delete'; post]
pub fn (app &Token) soft_delete_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := delete_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_token_usecase(mut ctx Context, req DeleteTokenReq) !DeleteTokenResp {
	// Domain 校验
	delete_token_domain(req)!

	// Repository 执行删除
	return mark_delete_token(mut ctx, req.id)
}

// ----------------- Domain 层 -----------------
fn delete_token_domain(req DeleteTokenReq) ! {
	if req.id == '' {
		return error('token id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteTokenReq {
	id string @[json: 'id']
}

pub struct DeleteTokenResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn mark_delete_token(mut ctx Context, id string) !DeleteTokenResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update SysToken set del_flag = 1 where id == id
	} or { return error('Failed to delete token: ${err}') }

	return DeleteTokenResp{
		msg: 'Token deleted successfully'
	}
}

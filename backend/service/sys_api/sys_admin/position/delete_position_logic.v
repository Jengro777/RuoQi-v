module position

import veb
import log
import x.json2 as json
import structs.schema_sys { SysPosition }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/delete'; post]
pub fn (app &Position) position_delete_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeletePositionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := delete_position_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_position_usecase(mut ctx Context, req DeletePositionReq) !DeletePositionResp {
	// Domain 校验
	delete_position_domain(req)!

	// Repository 执行删除
	return delete_position(mut ctx, req.ids)
}

// ----------------- Domain 层 -----------------
fn delete_position_domain(req DeletePositionReq) ! {
	if req.ids == [] {
		return error('position id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeletePositionReq {
	ids []string @[json: 'ids']
}

pub struct DeletePositionResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_position(mut ctx Context, ids []string) !DeletePositionResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from SysPosition where id in ids
	} or { return error('Failed to delete position: ${err}') }

	return DeletePositionResp{
		msg: 'Position deleted successfully'
	}
}

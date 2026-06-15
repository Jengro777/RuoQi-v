module utc

import veb
import log
import x.json2 as json
import structs.schema_base { BaseUtc }
import common.api
import structs { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &Utc) delete_utc_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteUtcReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := delete_utc_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_utc_usecase(mut ctx Context, req DeleteUtcReq) !DeleteUtcResp {
	// Domain 校验
	delete_utc_domain(req)!

	// Repository 执行删除
	return delete_utc_repo(mut ctx, req.utc_ids)
}

// ═══ Domain ═══
fn delete_utc_domain(req DeleteUtcReq) ! {
	if req.utc_ids.len == 0 {
		return error('No Currency ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteUtcReq {
	utc_ids []string @[json: 'ids']
}

pub struct DeleteUtcResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_utc_repo(mut ctx Context, utc_ids []string) !DeleteUtcResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from BaseUtc where id in utc_ids
	} or { return error('Failed to delete currency: ${err}') }

	return DeleteUtcResp{
		msg: '${utc_ids} token(s) deleted successfully'
	}
}

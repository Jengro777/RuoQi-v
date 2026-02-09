module dictionarydetail

import veb
import log
import x.json2 as json
import structs.schema_sys { SysDictionaryDetail }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/delete'; post]
pub fn (app &DictionaryDetail) dictionarydetail_delete_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteDictionaryDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_dictionarydetail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_dictionarydetail_usecase(mut ctx Context, req DeleteDictionaryDetailReq) !DeleteDictionaryDetailResp {
	// Domain 校验层
	delete_dictionarydetail_domain(req)!

	// Repository 层操作
	return delete_dictionarydetail_repo(mut ctx, req.ids)
}

// ----------------- Domain 层 -----------------
fn delete_dictionarydetail_domain(req DeleteDictionaryDetailReq) ! {
	if req.ids.len == 0 {
		return error('dictionarydetail id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteDictionaryDetailReq {
	ids []string @[json: 'ids']
}

pub struct DeleteDictionaryDetailResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_dictionarydetail_repo(mut ctx Context, ids []string) !DeleteDictionaryDetailResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		delete from SysDictionaryDetail where id in ids
	}!

	return DeleteDictionaryDetailResp{
		msg: 'DictionaryDetail deleted successfully'
	}
}

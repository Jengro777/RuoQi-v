module dictionarydetail

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysDictionaryDetail }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/dictionarydetail/delete'; post]
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
	return delete_dictionarydetail_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_dictionarydetail_domain(req DeleteDictionaryDetailReq) ! {
	if req.id == '' {
		return error('dictionarydetail id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteDictionaryDetailReq {
	id string @[json: 'id']
}

pub struct DeleteDictionaryDetailResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_dictionarydetail_repo(mut ctx Context, req DeleteDictionaryDetailReq) !DeleteDictionaryDetailResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[SysDictionaryDetail](db)
	q.delete()!.where('id = ?', req.id)!.update()!
	// 如果需要逻辑删除：
	// q.set('del_flag = ?', 1)!.where('id = ?', req.id)!.update()!

	return DeleteDictionaryDetailResp{
		msg: 'DictionaryDetail deleted successfully'
	}
}

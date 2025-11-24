module dictionary

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysDictionary }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/dictionary/delete'; post]
pub fn(app &Dictionary)delete_dictionary_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteDictionaryReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_dictionary_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_dictionary_usecase(mut ctx Context, req DeleteDictionaryReq) !DeleteDictionaryResp {
	// Domain 校验
	delete_dictionary_domain(req)!

	// Repository 执行删除
	return delete_dictionary_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_dictionary_domain(req DeleteDictionaryReq) ! {
	if req.id == '' {
		return error('dictionary id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteDictionaryReq {
	id string @[json: 'id']
}

pub struct DeleteDictionaryResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_dictionary_repo(mut ctx Context, req DeleteDictionaryReq) !DeleteDictionaryResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysDictionary](db)
	q.delete()!.where('id = ?', req.id)!.update()!

	return DeleteDictionaryResp{
		msg: 'Dictionary deleted successfully'
	}
}

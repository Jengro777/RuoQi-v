module dictionary

import veb
import log
import x.json2 as json
import structs.schema_sys { SysDictionary }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/delete'; post]
pub fn (app &Dictionary) delete_dictionary_handler(mut ctx Context) veb.Result {
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
	return delete_dictionary_repo(mut ctx, req.dictionary_ids)
}

// ----------------- Domain 层 -----------------
fn delete_dictionary_domain(req DeleteDictionaryReq) ! {
	if req.dictionary_ids.len == 0 {
		return error('dictionary id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteDictionaryReq {
	dictionary_ids []string @[json: 'ids']
}

pub struct DeleteDictionaryResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_dictionary_repo(mut ctx Context, dictionary_ids []string) !DeleteDictionaryResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}
	sql db {
		delete from SysDictionary where id in dictionary_ids
	} or { return error('Failed to delete tokens: ${err}') }

	return DeleteDictionaryResp{
		msg: 'Dictionary deleted successfully'
	}
}

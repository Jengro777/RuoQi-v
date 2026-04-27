module dictionary

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysDictionary }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &Dictionary) dictionary_update_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateDictionaryReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_dictionary_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_dictionary_usecase(mut ctx Context, req UpdateDictionaryReq) !UpdateDictionaryResp {
	// Domain 校验
	update_dictionary_domain(req)!

	// Repository 执行更新
	return update_dictionary_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_dictionary_domain(req UpdateDictionaryReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateDictionaryReq {
	id         string     @[json: 'id']
	name       ?string    @[json: 'name']
	title      ?string    @[json: 'title']
	desc       ?string    @[json: 'desc']
	status     ?u8        @[json: 'status']
	updated_at ?time.Time @[json: 'updatedAt']
}

pub struct UpdateDictionaryResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_dictionary_repo(mut ctx Context, req UpdateDictionaryReq) !UpdateDictionaryResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	up_expr := {
		if name := req.name { name == name },
		if title := req.title { title == title },
		if desc := req.desc { desc == desc },
		if status := req.status { status == status },
		updated_at == time.now()
	}

	sql db {
		dynamic update SysDictionary set up_expr where id == req.id
	}!

	return UpdateDictionaryResp{
		msg: 'Dictionary updated successfully'
	}
}

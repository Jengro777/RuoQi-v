module dictionarydetail

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysDictionaryDetail }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &DictionaryDetail) update_dictionary_detail_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateDictionaryDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_dictionary_detail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_dictionary_detail_usecase(mut ctx Context, req UpdateDictionaryDetailReq) !UpdateDictionaryDetailResp {
	// Domain 校验
	update_dictionary_detail_domain(req)!

	// Repository 执行更新
	return update_dictionary_detail_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_dictionary_detail_domain(req UpdateDictionaryDetailReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateDictionaryDetailReq {
	id            string     @[json: 'id']
	title         ?string    @[json: 'title']
	key           ?string    @[json: 'key']
	value         ?string    @[json: 'value']
	dictionary_id ?string    @[json: 'dictionaryId']
	sort          ?u32       @[json: 'sort']
	status        ?u8        @[json: 'status']
	updated_at    ?time.Time @[json: 'updatedAt']
}

pub struct UpdateDictionaryDetailResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_dictionary_detail_repo(mut ctx Context, req UpdateDictionaryDetailReq) !UpdateDictionaryDetailResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	up_expr := {
		if title := req.title { title == title },
		if key := req.key { key == key },
		if value := req.value { value == value },
		if sort := req.sort { sort == sort },
		if status := req.status { status == status },
		if dictionary_id := req.dictionary_id { dictionary_id == dictionary_id },
		updated_at == time.now()
	}

	sql db {
		dynamic update SysDictionaryDetail set up_expr where id == req.id
	}!

	return UpdateDictionaryDetailResp{
		msg: 'Dictionary detail updated successfully'
	}
}

module dictionarydetail

import veb
import log
import orm
import time
import x.json2 as json
import structs.schema_sys { SysDictionaryDetail }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &DictionaryDetail) dictionarydetail_update_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateDictionaryDetailReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_dictionarydetail_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn update_dictionarydetail_usecase(mut ctx Context, req UpdateDictionaryDetailReq) !UpdateDictionaryDetailResp {
	// Domain 校验
	update_dictionarydetail_domain(req)!

	// Repository 执行更新
	return update_dictionarydetail_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_dictionarydetail_domain(req UpdateDictionaryDetailReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateDictionaryDetailReq {
	id            string     @[json: 'id']
	name          ?string    @[json: 'name']
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
fn update_dictionarydetail_repo(mut ctx Context, req UpdateDictionaryDetailReq) !UpdateDictionaryDetailResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[SysDictionaryDetail](db)

	if title := req.title {
		q.set('title = ?', title)!
	}

	if name := req.name {
		q.set('name = ?', name)!
	}
	if key := req.key {
		q.set('key = ?', key)!
	}
	if value := req.value {
		q.set('value = ?', value)!
	}
	if sort := req.sort {
		q.set('sort = ?', sort)!
	}
	if status := req.status {
		q.set('status = ?', status)!
	}
	if dictionary_id := req.dictionary_id {
		q.set('dictionary_id = ?', dictionary_id)!
	}

	q.where('id = ?', req.id)!
		.update()!

	return UpdateDictionaryDetailResp{
		msg: 'Dictionary detail updated successfully'
	}
}

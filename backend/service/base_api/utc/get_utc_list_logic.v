module utc

import veb
import log
// import time
import structs.schema_base { BaseUtc }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/list'; get]
pub fn (app &Utc) get_utc_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := get_utc_list_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_utc_list_usecase(mut ctx Context) !UtcListResp {
	get_utc_list_domain()
	return get_utc_list(mut ctx)
}

// ----------------- Domain 层 -----------------
fn get_utc_list_domain() {
}

// ----------------- DTO 层 -----------------
pub struct UtcListReq {
}

pub struct UtcData {
	id              string @[json: 'id']
	sort            ?int   @[json: 'sort']
	name            string @[json: 'name']
	lng_range_start f64    @[json: 'lngRangeStart']
	lng_range_end   f64    @[json: 'lngRangeEnd']
	lng_mid         f64    @[json: 'lngMid']
}

pub struct UtcListResp {
	total int
	data  []UtcData
}

// ----------------- Repository 层 -----------------
fn get_utc_list(mut ctx Context) !UtcListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut result := sql db {
		select from BaseUtc order by sort
	} or { return error('Failed to execute SQL query: ${err}') }

	// 构造返回数据
	mut datalist := []UtcData{}
	for row in result {
		datalist << UtcData{
			id:              row.id
			sort:            row.sort
			name:            row.name
			lng_range_start: row.lng_range_start
			lng_range_end:   row.lng_range_end
			lng_mid:         row.lng_mid
		}
	}

	return UtcListResp{
		data: datalist
	}
}

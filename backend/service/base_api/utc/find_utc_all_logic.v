module utc

import veb
import log
// import time
import structs.schema_base { BaseUtc }
import common.api
import structs { Context }

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Utc) find_utc_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := find_utc_all_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_utc_all_usecase(mut ctx Context) !UtcListResp {
	find_utc_all_domain()
	return find_utc_all_repo(mut ctx)
}

// ═══ Domain ═══
fn find_utc_all_domain() {
}

// ═══ DTO ═══
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

// ═══ Repository ═══
fn find_utc_all_repo(mut ctx Context) !UtcListResp {
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

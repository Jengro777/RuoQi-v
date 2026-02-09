module utc

import veb
import log
// import time
import rand
import x.json2 as json
import structs.schema_base { BaseUtc }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Utc) create_utc_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateUtcReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_utc_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_utc_usecase(mut ctx Context, req CreateUtcReq) !CreateUtcResp {
	create_utc_domain(req)!
	return create_utc(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_utc_domain(req CreateUtcReq) ! {
	// if req.path == '' {
	// 	return error('path is required')
	// }
	// if req.method == '' {
	// 	return error('method is required')
	// }
	// if req.service_name == '' {
	// 	return error('service_name is required')
	// }
}

// ----------------- DTO 层 -----------------
pub struct CreateUtcReq {
	id              string @[json: 'id']
	sort            ?int   @[json: 'sort']
	name            string @[json: 'name']
	lng_range_start f64    @[json: 'lngRangeStart']
	lng_range_end   f64    @[json: 'lngRangeEnd']
	lng_mid         f64    @[json: 'lngMid']
}

pub struct CreateUtcResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_utc(mut ctx Context, req CreateUtcReq) !CreateUtcResp {
	// time_now := time.now()
	base_utc := BaseUtc{
		id:              rand.uuid_v7()
		sort:            req.sort
		name:            req.name
		lng_range_start: req.lng_range_start
		lng_range_end:   req.lng_range_end
		lng_mid:         req.lng_mid
		// created_at:      time_now
		// updated_at:      time_now
	}

	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_utc into BaseUtc
	} or { return error('Failed to create Currency: ${err}') }

	return CreateUtcResp{
		msg: 'Utc created successfully'
	}
}

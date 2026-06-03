// TEMPLATE: Create logic file — copy to service/xxx_api/module_name/create_xxx_logic.v
// Replace XXX, xxx, Xxx with actual module names throughout.

module xxx

import veb
import log
import time
import x.json2 as json
import rand
import structs.schema_xxx { Xxx } // schema struct
import common.api
import structs { Context }

// ----------------- Handler -----------------
@['/xxx/create'; post]
pub fn (app &XxxApp) xxx_create_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateXxxReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_xxx_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase -----------------
pub fn create_xxx_usecase(mut ctx Context, req CreateXxxReq) !CreateXxxResp {
	create_xxx_domain(req)!
	return create_xxx_repo(mut ctx, req)
}

// ----------------- Domain -----------------
fn create_xxx_domain(req CreateXxxReq) ! {
	if req.name == '' {
		return error('name is required')
	}
}

// ----------------- DTO -----------------
pub struct CreateXxxReq {
	id         string  @[json: 'id']
	name       string  @[json: 'name']
	status     u8      @[json: 'status']
	creator_id ?string @[json: 'creator_id']
}

pub struct CreateXxxResp {
	msg string @[json: 'msg']
}

// ----------------- Repository -----------------
fn create_xxx_repo(mut ctx Context, req CreateXxxReq) !CreateXxxResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	time_now := time.now()

	xxx := Xxx{
		id:         rand.uuid_v7()
		name:       req.name
		status:     req.status
		creator_id: req.creator_id
		created_at: time_now
	}

	sql db {
		upsert xxx into Xxx
	} or { return error('Failed to execute SQL query: ${err}') }

	return CreateXxxResp{
		msg: 'Xxx created successfully'
	}
}

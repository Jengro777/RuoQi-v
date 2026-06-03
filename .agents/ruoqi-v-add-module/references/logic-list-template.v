// TEMPLATE: List/query logic file — copy to service/xxx_api/module_name/get_xxx_list_logic.v
// Replace XXX, xxx, Xxx with actual module names throughout.

module xxx

import veb
import log
import x.json2 as json
import structs.schema_xxx { Xxx }
import common.api
import structs { Context }

// ----------------- Handler -----------------
@['/xxx/list'; post]
pub fn (app &XxxApp) xxx_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetXxxListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_xxx_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase -----------------
pub fn get_xxx_list_usecase(mut ctx Context, req GetXxxListReq) !GetXxxListResp {
	return get_xxx_list_repo(mut ctx, req)
}

// ----------------- DTO -----------------
pub struct GetXxxListReq {
	page      int     @[json: 'page']
	page_size int     @[json: 'page_size']
	name      ?string @[json: 'name']
	status    ?u8     @[json: 'status']
}

pub struct XxxItem {
	id         string    @[json: 'id']
	name       string    @[json: 'name']
	status     u8        @[json: 'status']
	created_at time.Time @[json: 'created_at']
}

pub struct GetXxxListResp {
	list      []XxxItem @[json: 'list']
	total     i64       @[json: 'total']
	page      int       @[json: 'page']
	page_size int       @[json: 'page_size']
}

// ----------------- Repository -----------------
fn get_xxx_list_repo(mut ctx Context, req GetXxxListReq) !GetXxxListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// Count total
	total := sql db {
		select count from Xxx where del_flag == 0
	} or { return error('Failed to count: ${err}') }

	// Paginate
	offset := (req.page - 1) * req.page_size
	rows := sql db {
		select from Xxx where del_flag == 0 order by created_at desc limit req.page_size offset offset
	} or { return error('Failed to query: ${err}') }

	mut list := []XxxItem{cap: rows.len}
	for row in rows {
		list << XxxItem{
			id:         row.id
			name:       row.name
			status:     row.status
			created_at: row.created_at
		}
	}

	return GetXxxListResp{
		list:      list
		total:     total
		page:      req.page
		page_size: req.page_size
	}
}

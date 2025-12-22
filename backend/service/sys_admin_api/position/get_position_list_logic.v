module position

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysPosition }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/list'; post]
pub fn (app &Position) position_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetPositionListPageReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_position_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_position_list_usecase(mut ctx Context, req GetPositionListPageReq) !GetPositionListPageResp {
	get_position_list_domain(req)!
	return find_position_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_position_list_domain(req GetPositionListPageReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetPositionListPageReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'pageSize']
	name      string @[json: 'name']
}

pub struct GetPositionListPageResp {
	total int
	data  []GetPositionList
}

pub struct GetPositionList {
	id         string @[json: 'id']
	status     int    @[json: 'status']
	name       string @[json: 'name']
	trans      string @[json: 'trans']
	code       string @[json: 'code']
	remark     string @[json: 'remark']
	sort       int    @[json: 'sort']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

// ----------------- Repository 层 -----------------
fn find_position_list(mut ctx Context, req GetPositionListPageReq) !GetPositionListPageResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	mut q := orm.new_query[SysPosition](db)

	offset_num := (req.page - 1) * req.page_size

	mut query := q.select()!
	if req.name != '' {
		query = query.where('name = ?', req.name)!
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []GetPositionList{}
	for row in result {
		datalist << GetPositionList{
			id:         row.id
			status:     int(row.status)
			name:       row.name
			trans:      ctx.i18n.t(row.name)
			code:       row.code
			remark:     row.remark or { '' }
			sort:       int(row.sort)
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: row.deleted_at or { time.Time{} }.format_ss()
		}
	}

	return GetPositionListPageResp{
		total: result.len
		data:  datalist
	}
}

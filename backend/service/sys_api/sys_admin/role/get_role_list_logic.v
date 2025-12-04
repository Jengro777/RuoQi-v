module role

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysRole }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/list'; post]
pub fn (app &Role) get_role_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetRoleListPageReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_role_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_role_list_usecase(mut ctx Context, req GetRoleListPageReq) !GetRoleListPageResp {
	// Domain 校验
	get_role_list_domain(req)!

	// Repository 查询
	return get_role_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_role_list_domain(req GetRoleListPageReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetRoleListPageReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'pageSize']
	name      string @[json: 'name']
}

pub struct GetRoleListPageResp {
	total int       @[json: 'total']
	data  []GetRole @[json: 'data']
}

pub struct GetRole {
	id              string @[json: 'id']
	status          int    @[json: 'status']
	name            string @[json: 'name']
	code            string @[json: 'code']
	default_router  string @[json: 'defaultRouter']
	remark          string @[json: 'remark']
	sort            int    @[json: 'sort']
	data_scope      int    @[json: 'dataScope']
	custom_dept_ids string @[json: 'customDeptIds']
	created_at      string @[json: 'createdAt']
	updated_at      string @[json: 'updatedAt']
	deleted_at      string @[json: 'deletedAt']
}

// ----------------- Repository 层 -----------------
fn get_role_list(mut ctx Context, req GetRoleListPageReq) !GetRoleListPageResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	mut q_role := orm.new_query[SysRole](db)

	// 条件查询
	mut query := q_role.select()!
	if req.name != '' {
		query = query.where('name = ?', req.name)!
	}

	offset_num := (req.page - 1) * req.page_size
	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []GetRole{}
	for row in result {
		datalist << GetRole{
			id:              row.id
			status:          int(row.status)
			name:            row.name
			code:            row.code
			default_router:  row.default_router
			remark:          row.remark or { '' }
			sort:            int(row.sort)
			data_scope:      int(row.data_scope)
			custom_dept_ids: row.custom_dept_ids or { '' }
			created_at:      row.created_at.format_ss()
			updated_at:      row.updated_at.format_ss()
			deleted_at:      row.deleted_at or { time.Time{} }.format_ss()
		}
	}

	return GetRoleListPageResp{
		total: result.len
		data:  datalist
	}
}

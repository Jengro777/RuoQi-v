module department

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/department/list'; post]
pub fn(app &Department)department_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetDepartmentListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_department_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_department_list_usecase(mut ctx Context, req GetDepartmentListReq) !GetDepartmentListResp {
	// Domain 校验
	get_department_list_domain(req)!

	// Repository 查询
	return find_department_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_department_list_domain(req GetDepartmentListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetDepartmentListReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'page_size']
	name      string @[json: 'name']
	leader    string @[json: 'leader']
	status    u8     @[json: 'status']
}

pub struct DepartmentItem {
	id         string @[json: 'id']
	parent_id  string @[json: 'parent_id']
	status     int    @[json: 'status']
	name       string @[json: 'name']
	leader     string @[json: 'leader']
	remark     string @[json: 'remark']
	sort       int    @[json: 'sort']
	phone      string @[json: 'phone']
	email      string @[json: 'email']
	created_at string @[json: 'created_at']
	updated_at string @[json: 'updated_at']
	deleted_at string @[json: 'deleted_at']
}

pub struct GetDepartmentListResp {
	total int
	data  []DepartmentItem
}

// ----------------- Repository 层 -----------------
fn find_department_list(mut ctx Context, req GetDepartmentListReq) !GetDepartmentListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysDepartment](db)

	offset_num := (req.page - 1) * req.page_size

	// 总数统计
	mut count := sql db {
		select count from SysDepartment
	}!

	// 条件查询
	mut query := q.select()!
	if req.name != '' {
		query = query.where('name = ?', req.name)!
	}
	if req.leader != '' {
		query = query.where('leader = ?', req.leader)!
	}
	if req.status in [0, 1] {
		query = query.where('status = ?', req.status)!
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []DepartmentItem{}
	for row in result {
		datalist << DepartmentItem{
			id:         row.id
			parent_id:  row.parent_id
			status:     int(row.status)
			name:       row.name
			leader:     row.leader or { '' }
			remark:     row.remark or { '' }
			sort:       int(row.sort)
			phone:      row.phone or { '' }
			email:      row.email or { '' }
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: row.deleted_at or { time.Time{} }.format_ss()
		}
	}

	return GetDepartmentListResp{
		total: count
		data:  datalist
	}
}

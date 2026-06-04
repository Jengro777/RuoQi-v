module department

import veb
import log
import time
import x.json2 as json
import structs.schema_sys { SysDepartment }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/all'; post]
pub fn (app &Department) find_department_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetDepartmentListPageReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_department_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn find_department_all_usecase(mut ctx Context, req GetDepartmentListPageReq) !GetDepartmentListPageResp {
	find_department_all_domain(req) or { return error('Domain validation failed') }

	return find_department_all(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn find_department_all_domain(req GetDepartmentListPageReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetDepartmentListPageReq {
	page      int     @[json: 'page']
	page_size int     @[json: 'pageSize']
	name      ?string @[json: 'name']
	leader    ?string @[json: 'leader']
}

pub struct DepartmentItem {
	id         string @[json: 'id']
	parent_id  string @[json: 'parentId']
	status     u8     @[json: 'status']
	name       string @[json: 'name']
	trans      string @[json: 'trans']
	leader     string @[json: 'leader']
	remark     string @[json: 'remark']
	sort       int    @[json: 'sort']
	phone      string @[json: 'phone']
	email      string @[json: 'email']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

pub struct GetDepartmentListPageResp {
	total int
	data  []DepartmentItem
}

// ----------------- Repository 层 -----------------
fn find_department_all(mut ctx Context, req GetDepartmentListPageReq) !GetDepartmentListPageResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	offset_num := (req.page - 1) * req.page_size

	// 条件查询
	expr := {
		if name := req.name { name == name },
		if leader := req.leader { leader == leader }
	}

	mut result := sql db {
		dynamic select from SysDepartment where expr limit req.page_size offset offset_num
	}!

	mut datalist := []DepartmentItem{}
	for row in result {
		datalist << DepartmentItem{
			id:         row.id
			parent_id:  row.parent_id
			status:     u8(row.status)
			name:       row.name
			trans:      ctx.i18n.t(row.name)
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

	return GetDepartmentListPageResp{
		total: result.len
		data:  datalist
	}
}

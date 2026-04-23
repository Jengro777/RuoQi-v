module project

import veb
import log
import time
import x.json2 as json
import structs.schema_core { CoreProject }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/project/list'; post]
pub fn (app &Project) project_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetCoreProjectByListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := project_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn project_list_usecase(mut ctx Context, req GetCoreProjectByListReq) !GetCoreProjectByListResp {
	// 参数校验
	project_list_domain(req)!

	// 调用 Repository 层
	return project_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn project_list_domain(req GetCoreProjectByListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetCoreProjectByListReq {
	page         int    @[json: 'page']
	page_size    int    @[json: 'page_size']
	name         string @[json: 'name']
	display_name string @[json: 'display_name']
}

pub struct GetCoreProjectByListResp {
	total int
	data  []GetCoreProjectByList
}

pub struct GetCoreProjectByList {
	id           string     @[json: 'id']
	name         string     @[json: 'name']
	display_name ?string    @[json: 'display_name']
	logo         string     @[json: 'logo']
	description  ?string    @[json: 'description']
	created_at   ?time.Time @[json: 'created_at']
	updated_at   ?time.Time @[json: 'updated_at']
	deleted_at   ?time.Time @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn project_list_repo(mut ctx Context, req GetCoreProjectByListReq) !GetCoreProjectByListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from CoreProject
	}!

	offset_num := (req.page - 1) * req.page_size

	// vfmt off
  where_expr := {
      if req.name != '' { name == req.name },
      if req.display_name != '' { display_name == req.display_name }
  }
	// vfmt on
	result := sql db {
		dynamic select from CoreProject where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	// 组装返回数据
	mut datalist := []GetCoreProjectByList{}
	for row in result {
		datalist << GetCoreProjectByList{
			id:           row.id
			name:         row.name
			display_name: row.display_name
			logo:         row.logo
			description:  row.description
			created_at:   row.created_at
			updated_at:   row.updated_at
			deleted_at:   row.deleted_at
		}
	}

	return GetCoreProjectByListResp{
		total: count
		data:  datalist
	}
}

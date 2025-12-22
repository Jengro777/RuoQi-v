module configuration

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysConfiguration }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/list'; post]
pub fn (app &Configuration) configuration_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetConfigurationListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := get_configuration_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_configuration_list_usecase(mut ctx Context, req GetConfigurationListReq) !GetConfigurationListResp {
	// Domain 校验
	get_configuration_list_domain(req)!

	// Repository 查询
	return get_configuration_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_configuration_list_domain(req GetConfigurationListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetConfigurationListReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'pageSize']
	name      string @[json: 'name']
	key       string @[json: 'key']
	category  u8     @[json: 'category']
}

pub struct ConfigurationData {
	id         string @[json: 'id']
	status     int    @[json: 'status']
	name       string @[json: 'name']
	key        string @[json: 'key']
	value      string @[json: 'value']
	category   string @[json: 'category']
	remark     string @[json: 'remark']
	sort       int    @[json: 'sort']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

pub struct GetConfigurationListResp {
	total int
	data  []ConfigurationData
}

// ----------------- Repository 层 -----------------
fn get_configuration_list_repo(mut ctx Context, req GetConfigurationListReq) !GetConfigurationListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[SysConfiguration](db)

	// 条件查询
	if req.name != '' {
		q = q.select()!.where('name = ?', req.name)!
	} else {
		q = q.select()!
	}

	if req.key != '' {
		q = q.where('key = ?', req.key)!
	}

	if req.category in [0, 1] {
		q = q.where('category = ?', req.category)!
	}

	// 总数统计
	mut count := sql db {
		select count from SysConfiguration
	}!

	// 分页
	offset_num := (req.page - 1) * req.page_size
	result := q.limit(req.page_size)!.offset(offset_num)!.query()!

	// 数据封装
	mut datalist := []ConfigurationData{}
	for row in result {
		datalist << ConfigurationData{
			id:         row.id
			status:     int(row.status)
			name:       row.name
			key:        row.key
			value:      row.value
			category:   row.category
			remark:     row.remark or { '' }
			sort:       int(row.sort)
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: row.deleted_at or { time.Time{} }.format_ss()
		}
	}

	return GetConfigurationListResp{
		total: count
		data:  datalist
	}
}

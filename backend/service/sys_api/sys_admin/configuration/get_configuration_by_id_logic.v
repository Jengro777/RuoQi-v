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
@['/configuration/get_by_id'; post]
pub fn (app &Configuration) configuration_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetConfigurationByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_configuration_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_configuration_by_id_usecase(mut ctx Context, req GetConfigurationByIdReq) !GetConfigurationByIdResp {
	get_configuration_by_id_domain(req)!
	return get_configuration_by_id_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_configuration_by_id_domain(req GetConfigurationByIdReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetConfigurationByIdReq {
	id string @[json: 'id']
}

pub struct GetConfigurationByIdResp {
	id         string @[json: 'id']
	status     int    @[json: 'status']
	name       string @[json: 'name']
	key        string @[json: 'key']
	value      string @[json: 'value']
	category   string @[json: 'category']
	remark     string @[json: 'remark']
	sort       int    @[json: 'sort']
	created_at string @[json: 'created_at']
	updated_at string @[json: 'updated_at']
	deleted_at string @[json: 'deleted_at']
}

// ----------------- Repository 层 -----------------
fn get_configuration_by_id_repo(mut ctx Context, req GetConfigurationByIdReq) !GetConfigurationByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut q := orm.new_query[SysConfiguration](db)
	mut query := q.select()!.where('id = ?', req.id)!
	result := query.query()!

	if result.len == 0 {
		return error('Configuration not found')
	}

	row := result[0]
	return GetConfigurationByIdResp{
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

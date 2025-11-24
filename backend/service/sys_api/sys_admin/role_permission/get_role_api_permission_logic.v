module role_permission

import veb
import log
import x.json2 as json
import structs.schema_sys { SysApi, SysRoleApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/role/api_list'; post]
pub fn(app &RolePermission)role_api_permission_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetRoleApiListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request: ${err.msg()}'))
	}

	result := get_role_api_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Failed to get role api list: ${err.msg()}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_role_api_list_usecase(mut ctx Context, req GetRoleApiListReq) !map[string][]GetRoleApiListResp {
	// 参数校验
	validate_role_api_list_domain(req)!

	// 查询数据
	return get_role_api_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn validate_role_api_list_domain(req GetRoleApiListReq) ! {
	if req.role_id.trim_space() == '' {
		return error('role_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetRoleApiListReq {
	role_id string @[json: 'role_id']
}

pub struct GetRoleApiListResp {
	id             string  @[json: 'id']
	path           string  @[json: 'path']
	description    ?string @[json: 'description']
	api_group      string  @[json: 'api_group']
	service_name   string  @[json: 'service_name']
	method         string  @[json: 'method']
	is_required    u8      @[json: 'is_required']
	has_permission bool    @[json: 'has_permission']
}

// ----------------- Repository 层 -----------------
fn get_role_api_list(mut ctx Context, req GetRoleApiListReq) !map[string][]GetRoleApiListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	// 1. 查询角色已有的 API
	mut role_apis := sql db {
		select from SysRoleApi where role_id == req.role_id
	} or { return error('Failed to query role APIs: ${err}') }

	owned_api_ids := role_apis.map(it.api_id)

	// 2. 查询所有 API
	mut all_apis_db := sql db {
		select from SysApi
	} or { return error('Failed to query all APIs: ${err}') }

	// 3. 构造 API 列表
	mut all_apis := []GetRoleApiListResp{}
	for row in all_apis_db {
		all_apis << GetRoleApiListResp{
			id:             row.id
			path:           row.path
			description:    row.description
			api_group:      row.api_group
			service_name:   row.service_name
			method:         row.method
			is_required:    row.is_required
			has_permission: row.is_required == 1 || row.id in owned_api_ids
		}
	}

	// 4. 按 api_group 分组
	mut grouped := map[string][]GetRoleApiListResp{}
	for api in all_apis {
		group := if api.api_group.trim_space() == '' { 'Other' } else { api.api_group }
		grouped[group] << api
	}

	return grouped
}

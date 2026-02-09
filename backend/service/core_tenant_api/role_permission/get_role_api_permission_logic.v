// 根据租户ID和应用订阅ID,获取租户角色的api权限

module role_permission

import veb
import log
import x.json2 as json
import structs.schema_core { CoreApi, CoreRoleApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/tenant_role_permission/apt_list'; post]
pub fn role_api_permission_handler(app &RolePermission, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetRoleApiListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request: ${err.msg()}'))
	}

	result := get_role_api_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Failed to get role API list: ${err.msg()}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn get_role_api_list_usecase(mut ctx Context, req GetRoleApiListReq) !map[string][]GetRoleApiListResp {
	// Domain 校验
	get_role_api_list_domain(req)!

	// Repository 查询
	return get_role_api_list_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_role_api_list_domain(req GetRoleApiListReq) ! {
	if req.role_id.trim_space() == '' {
		return error('role_id is required')
	}
	if req.source_id.trim_space() == '' {
		return error('source_id is required')
	}
	if req.source_type.trim_space() == '' {
		return error('source_type is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetRoleApiListReq {
	source_type string @[json: 'source_type']
	source_id   string @[json: 'source_id']
	tenant_id   string @[json: 'tenant_id']
	role_id     string @[json: 'role_id']
}

pub struct GetRoleApiListResp {
	id             string  @[json: 'id']
	path           string  @[json: 'path']
	description    ?string @[json: 'description']
	api_group      string  @[json: 'api_group']
	service_name   string  @[json: 'service_name']
	method         string  @[json: 'method']
	is_required    u8      @[json: 'is_required']
	source_type    string  @[json: 'source_type']
	source_id      string  @[json: 'source_id']
	has_permission bool    @[json: 'has_permission']
}

// ----------------- Repository 层 -----------------
fn get_role_api_list_repo(mut ctx Context, req GetRoleApiListReq) !map[string][]GetRoleApiListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 查询角色已拥有的 API
	mut role_apis := sql db {
		select from CoreRoleApi where role_id == req.role_id && source_type == req.source_type
		&& source_id == req.source_id
	} or { return error('Failed to query role APIs: ${err}') }

	owned_api_ids := role_apis.map(it.api_id)

	// 查询所有 API
	mut all_apis := sql db {
		select from CoreApi where source_type == req.source_type && source_id == req.source_id
	} or { return error('Failed to query all APIs: ${err}') }

	// 构造 API 响应列表
	mut api_list := []GetRoleApiListResp{}
	for row in all_apis {
		api_list << GetRoleApiListResp{
			id:             row.id
			path:           row.path
			description:    row.description
			api_group:      row.api_group
			service_name:   row.service_name
			method:         row.method
			is_required:    row.is_required
			source_type:    row.source_type
			source_id:      row.source_id
			has_permission: row.is_required == 1 || row.id in owned_api_ids
		}
	}

	// 按 api_group 分组
	mut grouped := map[string][]GetRoleApiListResp{}
	for api in api_list {
		group := if api.api_group.trim_space() == '' { 'Other' } else { api.api_group }
		grouped[group] << api
	}

	return grouped
}

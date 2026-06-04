/*
获取角色api权限列表
*/
module role_permission

import veb
import log
import x.json2 as json
import structs.schema_sys { SysApi, SysRoleApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/role'; post]
pub fn (app &RolePermission) find_role_api_permission_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[GetRoleApiListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400('Invalid request: ${err.msg()}'))
	}

	result := find_role_api_permission_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Failed to get role api list: ${err.msg()}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn find_role_api_permission_usecase(mut ctx Context, req GetRoleApiListReq) !map[string][]GetRoleApiListResp {
	// 参数校验
	validate_role_api_list_domain(req)!

	// 查询数据
	return find_role_api_permission(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn validate_role_api_list_domain(req GetRoleApiListReq) ! {
	if req.role_id.trim_space() == '' {
		return error('role_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct GetRoleApiListReq {
	role_id string @[json: 'id']
}

pub struct GetRoleApiListResp {
	id             string  @[json: 'id']
	method         string  @[json: 'method']
	path           string  @[json: 'path']
	description    ?string @[json: 'description']
	api_group      string  @[json: 'apiGroup']
	service_name   string  @[json: 'serviceName']
	is_required    u8      @[json: 'isRequired']
	has_permission bool    @[json: 'hasPermission']
}

// ----------------- Repository 层 -----------------
fn find_role_api_permission(mut ctx Context, req GetRoleApiListReq) !map[string][]GetRoleApiListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// 1. 查询角色已有的 API（通过 SysRoleApi 表）
	mut role_apis := sql db {
		select from SysRoleApi where role_id == req.role_id
	} or { return error('Failed to query role APIs: ${err}') }

	// 获取角色拥有的 API ID 列表
	mut owned_api_ids := []string{}
	for role_api in role_apis {
		owned_api_ids << role_api.api_id
	}

	// 2. 查询所有系统 API
	all_apis_db := sql db {
		select from SysApi
	} or { return error('Failed to query all APIs: ${err}') }

	// 3. 筛选出角色实际拥有的 API（包括必需的 API）
	mut role_owned_apis := []GetRoleApiListResp{}
	for row in all_apis_db {
		// 判断角色是否拥有该 API：必需的 API 或 在角色权限列表中
		has_permission := row.is_required == 1 || row.id in owned_api_ids

		// 如果角色没有该权限，跳过（不返回）
		if !has_permission {
			continue
		}

		role_owned_apis << GetRoleApiListResp{
			id:             row.id
			method:         row.method
			path:           row.path
			description:    row.description
			api_group:      row.api_group
			service_name:   row.service_name
			is_required:    row.is_required
			has_permission: true // 这里总是 true，因为只有拥有的才会被包含
		}
	}

	// 4. 按 api_group 分组
	mut grouped := map[string][]GetRoleApiListResp{}
	for api in role_owned_apis {
		group := if api.api_group.trim_space() == '' { 'Other' } else { api.api_group }
		grouped[group] << api
	}

	return grouped
}

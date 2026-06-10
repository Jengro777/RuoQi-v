module permission

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_workspace { WsRoleApi, WsRoleMenu }
import common.api

@['/bind_role_api'; post]
pub fn (app &Permission) bind_role_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[BindRoleApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := bind_role_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

@['/bind_role_menu'; post]
pub fn (app &Permission) bind_role_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[BindRoleMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := bind_role_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

@['/find_role_api'; post]
pub fn (app &Permission) find_role_api_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindRolePermReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_role_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

@['/find_role_menu'; post]
pub fn (app &Permission) find_role_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindRolePermReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_role_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

pub struct BindRoleApiReq {
	workspace_id string   @[json: 'workspaceId']
	role_id      string   @[json: "roleId"]
	source_type  string   @[json: "sourceType"]
	source_id    string   @[json: "sourceId"]
	api_ids      []string @[json: 'apiIds']
}

pub struct BindRoleMenuReq {
	workspace_id string   @[json: 'workspaceId']
	role_id      string   @[json: "roleId"]
	source_type  string   @[json: "sourceType"]
	source_id    string   @[json: "sourceId"]
	menu_ids     []string @[json: 'menuIds']
}

pub struct FindRolePermReq {
	workspace_id string @[json: 'workspaceId']
	role_id      string @[json: 'roleId']
}

pub struct PermResp {
	msg string @[json: 'msg']
}

pub fn bind_role_api_usecase(mut ctx Context, req BindRoleApiReq) !PermResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	sql db {
		delete from WsRoleApi where workspace_id == req.workspace_id && role_id == req.role_id
	} or {}
	for api_id in req.api_ids {
		ra := WsRoleApi{
			workspace_id: req.workspace_id
			role_id:      req.role_id
			api_id:       api_id
			source_type:  ''
			source_id:    ''
		}
		sql db {
			insert ra into WsRoleApi
		}!
	}
	return PermResp{
		msg: 'Role-API binding saved'
	}
}

pub fn bind_role_menu_usecase(mut ctx Context, req BindRoleMenuReq) !PermResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	sql db {
		delete from WsRoleMenu where workspace_id == req.workspace_id && role_id == req.role_id
	} or {}
	for menu_id in req.menu_ids {
		rm := WsRoleMenu{
			workspace_id: req.workspace_id
			role_id:      req.role_id
			menu_id:      menu_id
			source_type:  ''
			source_id:    ''
		}
		sql db {
			insert rm into WsRoleMenu
		}!
	}
	return PermResp{
		msg: 'Role-Menu binding saved'
	}
}

pub fn find_role_api_usecase(mut ctx Context, req FindRolePermReq) ![]WsRoleApi {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	result := sql db {
		select from WsRoleApi where workspace_id == req.workspace_id && role_id == req.role_id
	} or { return error('Failed: ${err}') }
	return result
}

pub fn find_role_menu_usecase(mut ctx Context, req FindRolePermReq) ![]WsRoleMenu {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	result := sql db {
		select from WsRoleMenu where workspace_id == req.workspace_id && role_id == req.role_id
	} or { return error('Failed: ${err}') }
	return result
}

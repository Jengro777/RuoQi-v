module role

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamRole }
import common.api

@['/create_role'; post]
pub fn (app &Role) create_role_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

@['/find_role_all'; post]
pub fn (app &Role) find_role_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_role_all_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

@['/find_role_by_id'; post]
pub fn (app &Role) find_role_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_role_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

@['/update_role'; post]
pub fn (app &Role) update_role_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

@['/delete_role'; post]
pub fn (app &Role) delete_role_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteRoleReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_role_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

pub struct CreateRoleReq {
	name   string @[json: 'name']
	code   string @[json: 'code']
	remark string @[json: 'remark']
	sort   u32    @[json: 'sort']
	status u8     @[json: 'status']
}

pub struct UpdateRoleReq {
	id     string @[json: 'id']
	name   string @[json: 'name']
	code   string @[json: 'code']
	remark string @[json: 'remark']
	sort   u32    @[json: 'sort']
	status u8     @[json: 'status']
}

pub struct DeleteRoleReq {
	id string @[json: 'id']
}

pub struct FindByIdReq {
	id string @[json: 'id']
}

pub struct RoleResp {
	msg string @[json: 'msg']
}

pub fn create_role_usecase(mut ctx Context, req CreateRoleReq) !RoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	r := IamRole{
		id:         rand.uuid_v7()
		name:       req.name
		code:       req.code
		remark:     req.remark
		sort:       req.sort
		status:     req.status
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert r into IamRole
	}!
	return RoleResp{
		msg: 'Role created'
	}
}

pub fn find_role_all_usecase(mut ctx Context) ![]IamRole {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	roles := sql db {
		select from IamRole
	} or { return error('Failed: ${err}') }
	return roles
}

pub fn find_role_by_id_usecase(mut ctx Context, req FindByIdReq) !IamRole {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	roles := sql db {
		select from IamRole where id == req.id limit 1
	} or { return error('Failed: ${err}') }
	if roles.len == 0 { return error('role not found') }
	return roles[0]
}

pub fn update_role_usecase(mut ctx Context, req UpdateRoleReq) !RoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	sql db {
		update IamRole set name = req.name, code = req.code, remark = req.remark, sort = req.sort,
		status = req.status, updated_at = time.now() where id == req.id
	}!
	return RoleResp{
		msg: 'Role updated'
	}
}

pub fn delete_role_usecase(mut ctx Context, req DeleteRoleReq) !RoleResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or {} }
	sql db {
		delete from IamRole where id == req.id
	}!
	return RoleResp{
		msg: 'Role deleted'
	}
}

module workspace_core

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_workspace { WsMember, WsMemberRole }
import common.api

// ═══ Handler ═══
@['/add_member'; post]
pub fn (app &WorkspaceCore) add_member_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[AddMemberReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := add_member_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn add_member_usecase(mut ctx Context, req AddMemberReq) !AddMemberResp {
	add_member_domain(req)!
	return add_member_repo(mut ctx, req)
}

// ═══ Domain ═══
fn add_member_domain(req AddMemberReq) ! {
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
	if req.user_id == '' {
		return error('user_id is required')
	}
	if req.role_id == '' {
		return error('role_id is required')
	}
}

// ═══ DTO ═══
pub struct AddMemberReq {
	workspace_id string @[json: 'workspaceId']
	user_id      string @[json: 'userId']
	role_id      string @[json: 'roleId']
}

pub struct AddMemberResp {
	user_id string @[json: 'userId']
	msg     string @[json: 'msg']
}

// ═══ Repository ═══
fn add_member_repo(mut ctx Context, req AddMemberReq) !AddMemberResp {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// 事务保证成员实体与角色分配的一致性
	db.execute('BEGIN') or { return error('Failed to begin transaction: ${err}') }

	// 1. 维护成员实体记录（一行一个成员）
	m := WsMember{
		workspace_id: req.workspace_id
		user_id: req.user_id
		joined_at: time.now()
		status: 1
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		upsert m into WsMember
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to upsert member: ${err}')
	}

	// 2. 分配角色（一行一个角色分配）
	mr := WsMemberRole{
		workspace_id: req.workspace_id
		user_id: req.user_id
		role_id: req.role_id
	}
	sql db {
		upsert mr into WsMemberRole
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to upsert member role: ${err}')
	}

	db.execute('COMMIT') or { return error('Failed to commit transaction: ${err}') }
	return AddMemberResp{
		user_id: req.user_id
		msg: 'Member added'
	}
}

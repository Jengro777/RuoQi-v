module workspace_core

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_workspace { WsMember, WsMemberRole }
import common.api

// ═══ Handler ═══
@['/remove_member'; post]
pub fn (app &WorkspaceCore) remove_member_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[RemoveMemberReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := remove_member_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn remove_member_usecase(mut ctx Context, req RemoveMemberReq) !RemoveMemberResp {
	remove_member_domain(req)!
	return remove_member_repo(mut ctx, req)
}

// ═══ Domain ═══
fn remove_member_domain(req RemoveMemberReq) ! {
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ═══ DTO ═══
pub struct RemoveMemberReq {
	workspace_id string @[json: 'workspaceId']
	user_id      string @[json: 'userId']
	role_id      ?string @[json: 'roleId']
}

pub struct RemoveMemberResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn remove_member_repo(mut ctx Context, req RemoveMemberReq) !RemoveMemberResp {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	if role_id := req.role_id {
		// 仅移除指定角色 — 单条语句，无需事务
		sql db {
			delete from WsMemberRole where workspace_id == req.workspace_id && user_id == req.user_id
			&& role_id == role_id
		}!
		return RemoveMemberResp{
			msg: 'Role removed from member'
		}
	}

	// 移除成员所有角色 + 软删除成员实体 — 事务保证原子性
	db.execute('BEGIN') or { return error('Failed to begin transaction: ${err}') }
	sql db {
		delete from WsMemberRole where workspace_id == req.workspace_id && user_id == req.user_id
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to delete member roles: ${err}')
	}
	sql db {
		update WsMember set del_flag = -1, deleted_at = time.now() where
		workspace_id == req.workspace_id && user_id == req.user_id
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to remove member: ${err}')
	}
	db.execute('COMMIT') or { return error('Failed to commit transaction: ${err}') }
	return RemoveMemberResp{
		msg: 'Member removed'
	}
}

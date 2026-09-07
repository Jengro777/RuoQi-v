module workspace_core

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_workspace { WsMember, WsMemberRole }
import common.api

// ═══ Handler ═══
@['/find_members'; post]
pub fn (app &WorkspaceCore) find_members_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindMembersReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_members_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_members_usecase(mut ctx Context, req FindMembersReq) !FindMembersResp {
	find_members_domain(req)!
	return find_members_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_members_domain(req FindMembersReq) ! {
	if req.workspace_id == '' {
		return error('workspace_id is required')
	}
}

// ═══ DTO ═══
pub struct FindMembersReq {
	workspace_id string @[json: 'workspaceId']
}

pub struct MemberInfo {
	user_id   string @[json: 'userId']
	joined_at time.Time @[json: 'joinedAt']
	status    u8 @[json: 'status']
	role_ids  []string @[json: 'roleIds']
}

pub struct FindMembersResp {
	members []MemberInfo @[json: 'members']
}

// ═══ Repository ═══
fn find_members_repo(mut ctx Context, req FindMembersReq) !FindMembersResp {
	ctx.scope_sc.workspace_id = req.workspace_id
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }

	// 1. 查询所有成员实体
	members := sql db {
		select from WsMember where workspace_id == req.workspace_id && del_flag == 0
	} or { return error('Failed to query members: ${err}') }

	// 2. 查询所有角色分配
	all_roles := sql db {
		select from WsMemberRole where workspace_id == req.workspace_id
	} or { return error('Failed to query member roles: ${err}') }

	// 3. 构建 user_id → role_ids 映射（O(n+m)）
	mut role_map := map[string][]string{}
	for mr in all_roles {
		role_map[mr.user_id] << mr.role_id
	}

	// 4. 组装：成员 + 角色列表
	mut result := []MemberInfo{cap: members.len}
	for m in members {
		result << MemberInfo{
			user_id: m.user_id
			joined_at: m.joined_at
			status: m.status
			role_ids: role_map[m.user_id]
		}
	}

	return FindMembersResp{
		members: result
	}
}

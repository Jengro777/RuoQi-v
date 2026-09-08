module tenant_member

import veb
import log
import time
import json2 as json
import model { Context }
import model.schema_tenant { TnMember }
import common.api as capi
import service.iam_service.iam_api.tenant

// ═══ Handler ═══
@['/invite_member'; post]
pub fn (app &TenantMember) invite_member_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[InviteMemberReq](ctx.req.data) or {
		return ctx.json(capi.json_error(code: capi.err_common_param_invalid, msg: err.msg()))
	}
	result := invite_member_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error(
			code: capi.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn invite_member_usecase(mut ctx Context, req InviteMemberReq) !InviteMemberResp {
	invite_member_domain(mut ctx, req)!
	return invite_member_repo(mut ctx, req)
}

// ═══ Domain ═══
fn invite_member_domain(mut ctx Context, req InviteMemberReq) ! {
	if req.user_id == '' {
		return error('userId is required')
	}
	tenant_id := ctx.svc_iam.active_tenant_id
	product_id := ctx.svc_iam.active_subproduct_id
	portal_id := ctx.svc_iam.active_subportal_id

	// 复用 IAM 侧校验：门户类型 + 租户已订阅该门户
	tenant.validate_tn_member_subportal_exists(mut ctx, tenant_id, product_id, portal_id)!
}

// ═══ DTO ═══
pub struct InviteMemberReq {
	user_id string @[json: 'userId']
}

pub struct InviteMemberResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn invite_member_repo(mut ctx Context, req InviteMemberReq) !InviteMemberResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	tenant_id := ctx.svc_iam.active_tenant_id
	product_id := ctx.svc_iam.active_subproduct_id
	portal_id := ctx.svc_iam.active_subportal_id

	// Check if user is already a member
	existing := sql db {
		select from TnMember where tenant_id == tenant_id && product_id == product_id
		&& portal_id == portal_id && user_id == req.user_id && del_flag == 0 limit 1
	} or { return error('Failed to check existing member: ${err}') }
	if existing.len > 0 {
		return error('用户已是成员')
	}

	member := TnMember{
		tenant_id: tenant_id
		product_id: product_id
		portal_id: portal_id
		user_id: req.user_id
		status: 1
		joined_at: time.now()
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time.now()
		updated_at: time.now()
	}
	sql db {
		insert member into TnMember
	} or { return error('Failed to invite member: ${err}') }
	return InviteMemberResp{
		msg: '成员邀请成功'
	}
}

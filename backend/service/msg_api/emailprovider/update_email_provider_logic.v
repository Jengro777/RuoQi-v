module emailprovider

import veb
import log
import time
import json2 as json
import model.schema_msg { MsgEmailProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &EmailProvider) update_email_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateEmailProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_email_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_email_provider_usecase(mut ctx Context, req UpdateEmailProviderReq) !UpdateEmailProviderResp {
	update_email_provider_domain(req)!
	return update_email_provider_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_email_provider_domain(req UpdateEmailProviderReq) ! {
	if req.id == '' {
		return error('email provider id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateEmailProviderReq {
	id         string @[json: 'id']
	name       ?string @[json: 'name']
	auth_type  ?u8 @[json: 'authType']
	email_addr ?string @[json: 'emailAddr']
	password   ?string @[json: 'password']
	host_name  ?string @[json: 'hostName']
	identify   ?string @[json: 'identify']
	secret     ?string @[json: 'secret']
	port       ?u32 @[json: 'port']
	tls        ?u8 @[json: 'tls']
	is_default ?u8 @[json: 'isDefault']
}

pub struct UpdateEmailProviderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_email_provider_repo(mut ctx Context, req UpdateEmailProviderReq) !UpdateEmailProviderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	// vfmt off
	up_expr := {
		if v := req.name {
			name == v
		},
		if v := req.auth_type {
			auth_type == v
		},
		if v := req.email_addr {
			email_addr == v
		},
		if v := req.password {
			password == v
		},
		if v := req.host_name {
			host_name == v
		},
		if v := req.identify {
			identify == v
		},
		if v := req.secret {
			secret == v
		},
		if v := req.port {
			port == v
		},
		if v := req.tls {
			tls == v
		},
		if v := req.is_default {
			is_default == v
		},
		updater_id == ctx.svc_iam.user_id,
		updated_at == time.now()
	}
	// vfmt on

	sql db {
		dynamic update MsgEmailProvider set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateEmailProviderResp{
		msg: 'EmailProvider updated successfully'
	}
}

module emailprovider

import veb
import log
import time
import rand
import json2 as json
import model.schema_msg { MsgEmailProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &EmailProvider) create_email_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateEmailProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_email_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_email_provider_usecase(mut ctx Context, req CreateEmailProviderReq) !CreateEmailProviderResp {
	create_email_provider_domain(req)!
	return create_email_provider_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_email_provider_domain(req CreateEmailProviderReq) ! {
	if req.name == '' {
		return error('provider name is required')
	}
	if req.email_addr == '' {
		return error('email address is required')
	}
	if req.host_name == '' {
		return error('host name is required')
	}
}

// ═══ DTO ═══
pub struct CreateEmailProviderReq {
	name       string @[json: 'name']
	auth_type  u8 @[json: 'authType']
	email_addr string @[json: 'emailAddr']
	password   ?string @[json: 'password']
	host_name  string @[json: 'hostName']
	identify   ?string @[json: 'identify']
	secret     ?string @[json: 'secret']
	port       ?u32 @[json: 'port']
	tls        u8 @[json: 'tls']
	is_default u8 @[json: 'isDefault']
}

pub struct CreateEmailProviderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_email_provider_repo(mut ctx Context, req CreateEmailProviderReq) !CreateEmailProviderResp {
	time_now := time.now()
	provider := MsgEmailProvider{
		id: rand.uuid_v7()
		name: req.name
		auth_type: req.auth_type
		email_addr: req.email_addr
		password: req.password
		host_name: req.host_name
		identify: req.identify
		secret: req.secret
		port: req.port
		tls: req.tls
		is_default: req.is_default
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert provider into MsgEmailProvider
	} or { return error('Failed to create EmailProvider: ${err}') }

	return CreateEmailProviderResp{
		msg: 'EmailProvider created successfully'
	}
}

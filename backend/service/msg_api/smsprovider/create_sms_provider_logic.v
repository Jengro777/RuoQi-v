module smsprovider

import veb
import log
import time
import rand
import json2 as json
import model.schema_msg { MsgSmsProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &SmsProvider) create_sms_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateSmsProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_sms_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_sms_provider_usecase(mut ctx Context, req CreateSmsProviderReq) !CreateSmsProviderResp {
	create_sms_provider_domain(req)!
	return create_sms_provider_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_sms_provider_domain(req CreateSmsProviderReq) ! {
	if req.name == '' {
		return error('provider name is required')
	}
	if req.secret_id == '' {
		return error('secret id is required')
	}
	if req.region == '' {
		return error('region is required')
	}
}

// ═══ DTO ═══
pub struct CreateSmsProviderReq {
	name       string @[json: 'name']
	secret_id  string @[json: 'secretId']
	secret_key string @[json: 'secretKey']
	region     string @[json: 'region']
	is_default u8 @[json: 'isDefault']
}

pub struct CreateSmsProviderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_sms_provider_repo(mut ctx Context, req CreateSmsProviderReq) !CreateSmsProviderResp {
	time_now := time.now()
	provider := MsgSmsProvider{
		id: rand.uuid_v7()
		name: req.name
		secret_id: req.secret_id
		secret_key: req.secret_key
		region: req.region
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
		insert provider into MsgSmsProvider
	} or { return error('Failed to create SmsProvider: ${err}') }

	return CreateSmsProviderResp{
		msg: 'SmsProvider created successfully'
	}
}

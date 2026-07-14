module apikey

import veb
import log
import json2 as json
import structs { Context }
import common.api
import structs.schema_iam { IamApiKey }

pub struct ToggleApiKeyReq {
	id     string @[json: 'id']
	action string @[json: 'action']
}

@['/iam/apikey/toggle'; post]
pub fn (app &ApiKey) toggle_apikey_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[ToggleApiKeyReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := toggle_apikey_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

fn toggle_apikey_usecase(mut ctx Context, req ToggleApiKeyReq) !map[string]string {
	if req.id.len == 0 { return error('id is required') }
	if req.action.len == 0 { return error('action is required') }

	ts := match req.action {
		'enable' { 0 }
		'disable' { 1 }
		'revoke' { 2 }
		else { return error("action must be 'enable', 'disable', or 'revoke'") }
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamApiKey set status = ts where id == req.id && user_id == ctx.svc_iam.user_id
	}!

	msg := match req.action {
		'enable' { 'API Key enabled' }
		'disable' { 'API Key disabled' }
		'revoke' { 'API Key revoked' }
		else { 'status changed' }
	}

	return {
		'msg':    msg
		'id':     req.id
		'status': ts.str()
	}
}

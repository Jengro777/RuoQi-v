module smsprovider

import veb
import log
import json2 as json
import model.schema_msg { MsgSmsProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/find_sms_provider_by_id'; post]
pub fn (app &SmsProvider) find_sms_provider_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[SmsProviderByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_sms_provider_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_sms_provider_by_id_usecase(mut ctx Context, req SmsProviderByIdReq) !MsgSmsProvider {
	find_sms_provider_by_id_domain(req)!
	return find_sms_provider_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_sms_provider_by_id_domain(req SmsProviderByIdReq) ! {
	if req.id == '' {
		return error('sms provider id is required')
	}
}

// ═══ DTO ═══
pub struct SmsProviderByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_sms_provider_by_id_repo(mut ctx Context, req SmsProviderByIdReq) !MsgSmsProvider {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	providers := sql db {
		select from MsgSmsProvider where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if providers.len == 0 {
		return error('SmsProvider not found')
	}

	return providers[0]
}

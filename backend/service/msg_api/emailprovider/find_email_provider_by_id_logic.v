module emailprovider

import veb
import log
import json2 as json
import model.schema_msg { MsgEmailProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/find_email_provider_by_id'; post]
pub fn (app &EmailProvider) find_email_provider_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[EmailProviderByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_email_provider_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_email_provider_by_id_usecase(mut ctx Context, req EmailProviderByIdReq) !MsgEmailProvider {
	find_email_provider_by_id_domain(req)!
	return find_email_provider_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_email_provider_by_id_domain(req EmailProviderByIdReq) ! {
	if req.id == '' {
		return error('email provider id is required')
	}
}

// ═══ DTO ═══
pub struct EmailProviderByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_email_provider_by_id_repo(mut ctx Context, req EmailProviderByIdReq) !MsgEmailProvider {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	providers := sql db {
		select from MsgEmailProvider where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if providers.len == 0 {
		return error('EmailProvider not found')
	}

	return providers[0]
}

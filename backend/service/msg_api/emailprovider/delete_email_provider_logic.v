module emailprovider

import time
import veb
import log
import json2 as json
import model.schema_msg { MsgEmailProvider }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &EmailProvider) delete_email_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteEmailProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_email_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_email_provider_usecase(mut ctx Context, req DeleteEmailProviderReq) !DeleteEmailProviderResp {
	delete_email_provider_domain(req)!
	return delete_email_provider_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_email_provider_domain(req DeleteEmailProviderReq) ! {
	if req.ids.len == 0 {
		return error('No EmailProvider ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteEmailProviderReq {
	ids []string @[json: 'ids']
}

pub struct DeleteEmailProviderResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_email_provider_repo(mut ctx Context, ids []string) !DeleteEmailProviderResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update MsgEmailProvider set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in ids && del_flag == 0
	} or { return error('Failed to soft-delete email provider: ${err}') }

	return DeleteEmailProviderResp{
		msg: '${ids.len} EmailProvider(s) deleted successfully'
	}
}

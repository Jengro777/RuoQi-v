module currency

import time
import veb
import log
import json2 as json
import model.schema_base { BaseCurrency }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &Currency) delete_currency_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteCurrencyReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	// Usecase 执行
	result := delete_currency_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_currency_usecase(mut ctx Context, req DeleteCurrencyReq) !DeleteCurrencyResp {
	// Domain 校验
	delete_currency_domain(req)!

	// Repository 执行删除
	return delete_currency_repo(mut ctx, req.currency_ids)
}

// ═══ Domain ═══
fn delete_currency_domain(req DeleteCurrencyReq) ! {
	if req.currency_ids.len == 0 {
		return error('No Currency ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteCurrencyReq {
	currency_ids []string @[json: 'ids']
}

pub struct DeleteCurrencyResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_currency_repo(mut ctx Context, currency_ids []string) !DeleteCurrencyResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update BaseCurrency set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in currency_ids && del_flag == 0
	} or { return error('Failed to soft-delete currency: ${err}') }

	return DeleteCurrencyResp{
		msg: '${currency_ids} token(s) deleted successfully'
	}
}

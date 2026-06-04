module currency

import veb
import log
import x.json2 as json
import structs.schema_base { BaseCurrency }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/delete'; post]
pub fn (app &Currency) delete_currency_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteCurrencyReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := delete_currency_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_currency_usecase(mut ctx Context, req DeleteCurrencyReq) !DeleteCurrencyResp {
	// Domain 校验
	delete_currency_domain(req)!

	// Repository 执行删除
	return delete_currency_repo(mut ctx, req.currency_ids)
}

// ----------------- Domain 层 -----------------
fn delete_currency_domain(req DeleteCurrencyReq) ! {
	if req.currency_ids.len == 0 {
		return error('No Currency ids provided')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteCurrencyReq {
	currency_ids []string @[json: 'ids']
}

pub struct DeleteCurrencyResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_currency_repo(mut ctx Context, currency_ids []string) !DeleteCurrencyResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from BaseCurrency where id in currency_ids
	} or { return error('Failed to delete currency: ${err}') }

	return DeleteCurrencyResp{
		msg: '${currency_ids} token(s) deleted successfully'
	}
}

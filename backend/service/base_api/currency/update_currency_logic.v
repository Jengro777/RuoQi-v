module currency

import veb
import log
import time
import json2 as json
import model.schema_base { BaseCurrency }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Currency) update_currency_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateCurrencyReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_currency_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_currency_usecase(mut ctx Context, req UpdateCurrencyReq) !UpdateCurrencyResp {
	// Domain 校验
	update_currency_domain(req)!

	// Repository 更新
	return update_currency_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_currency_domain(req UpdateCurrencyReq) ! {
	if req.id == '' {
		return error('currency id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateCurrencyReq {
	id                        string @[json: 'id']
	english_name              ?string @[json: 'englishName']
	simplified_name           ?string @[json: 'simplifiedName']
	currency_code             ?string @[json: 'currencyCode']
	currency_symbol           ?string @[json: 'currencySymbol']
	decimal_place             ?u8 @[json: 'decimalPlace']
	exchange_rate             ?f64 @[json: 'exchangeRate']
	exchange_rate_fluctuation ?f64 @[json: 'exchangeRateFluctuation']
	exchange_rate_used        ?f64 @[json: 'exchangeRateUsed']
	sort                      ?int @[json: 'sort']
	status                    ?u8 @[json: 'status']
}

pub struct UpdateCurrencyResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_currency_repo(mut ctx Context, req UpdateCurrencyReq) !UpdateCurrencyResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr :=
		sql {
		}

	sql db {
		dynamic update BaseCurrency set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateCurrencyResp{
		msg: 'Currency updated successfully'
	}
}

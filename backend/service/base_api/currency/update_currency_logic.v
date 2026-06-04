module currency

import veb
import log
import time
import x.json2 as json
import structs.schema_base { BaseCurrency }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &Currency) update_currency_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateCurrencyReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_currency_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_currency_usecase(mut ctx Context, req UpdateCurrencyReq) !UpdateCurrencyResp {
	// Domain 校验
	update_currency_domain(req)!

	// Repository 更新
	return update_currency_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_currency_domain(req UpdateCurrencyReq) ! {
	if req.id == '' {
		return error('currency id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateCurrencyReq {
	id                        string  @[json: 'id']
	english_name              ?string @[json: 'englishName']
	simplified_name           ?string @[json: 'simplifiedName']
	currency_code             ?string @[json: 'currencyCode']
	currency_symbol           ?string @[json: 'currencySymbol']
	decimal_place             ?u8     @[json: 'decimalPlace']
	exchange_rate             ?f64    @[json: 'exchangeRate']
	exchange_rate_fluctuation ?f64    @[json: 'exchangeRateFluctuation']
	exchange_rate_used        ?f64    @[json: 'exchangeRateUsed']
	sort                      ?int    @[json: 'sort']
	status                    ?u8     @[json: 'status']
}

pub struct UpdateCurrencyResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_currency_repo(mut ctx Context, req UpdateCurrencyReq) !UpdateCurrencyResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if english_name := req.english_name { english_name == english_name },
		if simplified_name := req.simplified_name { simplified_name == simplified_name },
		if currency_code := req.currency_code { currency_code == currency_code },
		if currency_symbol := req.currency_symbol { currency_symbol == currency_symbol },
		if decimal_place := req.decimal_place { decimal_place == decimal_place },
		if exchange_rate := req.exchange_rate { exchange_rate == exchange_rate },
		if exchange_rate_fluctuation := req.exchange_rate_fluctuation {
			exchange_rate_fluctuation == exchange_rate_fluctuation
		},
		if exchange_rate_used := req.exchange_rate_used { exchange_rate_used == exchange_rate_used },
		if sort := req.sort { sort == sort },
		if status := req.status { status == status },
		updated_at == time.now()
	}

	sql db {
		dynamic update BaseCurrency set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateCurrencyResp{
		msg: 'Currency updated successfully'
	}
}

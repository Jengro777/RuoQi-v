module currency

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_base { BaseCurrency }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Currency) create_currency_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateCurrencyReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_currency_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_currency_usecase(mut ctx Context, req CreateCurrencyReq) !CreateCurrencyResp {
	// create_currency_domain(req)!
	return create_currency(mut ctx, req)
}

// ----------------- Domain 层 -----------------
// fn create_currency_domain(req CreateCurrencyReq) ! {
// if req.path == '' {
// 	return error('path is required')
// }
// if req.method == '' {
// 	return error('method is required')
// }
// if req.service_name == '' {
// 	return error('service_name is required')
// }
// }

// ----------------- DTO 层 -----------------
pub struct CreateCurrencyReq {
	english_name              string @[json: 'englishName']
	simplified_name           string @[json: 'simplifiedName']
	currency_code             string @[json: 'currencyCode']
	currency_symbol           string @[json: 'currencySymbol']
	decimal_place             u8     @[json: 'decimalPlace']
	exchange_rate             f64    @[json: 'exchangeRate']
	exchange_rate_fluctuation f64    @[json: 'exchangeRateFluctuation']
	exchange_rate_used        f64    @[json: 'exchangeRateUsed']
	sort                      ?int   @[json: 'sort']
	status                    u8     @[json: 'status']
}

pub struct CreateCurrencyResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_currency(mut ctx Context, req CreateCurrencyReq) !CreateCurrencyResp {
	time_now := time.now()
	base_currency := BaseCurrency{
		id:                        rand.uuid_v7()
		english_name:              req.english_name
		simplified_name:           req.simplified_name
		currency_code:             req.currency_code
		currency_symbol:           req.currency_symbol
		decimal_place:             req.decimal_place
		exchange_rate:             req.exchange_rate
		exchange_rate_fluctuation: req.exchange_rate_fluctuation
		exchange_rate_used:        req.exchange_rate_used
		sort:                      req.sort
		status:                    req.status
		created_at:                time_now
		updated_at:                time_now
	}

	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_currency into BaseCurrency
	} or { return error('Failed to create Currency: ${err}') }

	return CreateCurrencyResp{
		msg: 'Currency created successfully'
	}
}

module currency

import veb
import log
import time
import structs.schema_base { BaseCurrency }
import common.api
import structs { Context }
import x.json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Currency) find_currency_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CurrencyListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_currency_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_currency_all_usecase(mut ctx Context, req CurrencyListReq) !CurrencyListResp {
	find_currency_all_domain()
	return find_currency_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_currency_all_domain() {
}

// ═══ DTO ═══
pub struct CurrencyListReq {
	page          int    @[json: 'page']
	page_size     int    @[json: 'pageSize']
	english_name  string @[json: 'englishName']
	currency_code string @[json: 'currencyCode']
	status        []u8   @[json: 'status']
}

pub struct CurrencyData {
	id                        string  @[json: 'id']
	english_name              string  @[json: 'englishName']
	simplified_name           string  @[json: 'simplifiedName']
	currency_code             string  @[json: 'currencyCode']
	currency_symbol           string  @[json: 'currencySymbol']
	decimal_place             u8      @[json: 'decimalPlace']
	exchange_rate             f64     @[json: 'exchangeRate']
	exchange_rate_fluctuation f64     @[json: 'exchangeRateFluctuation']
	exchange_rate_used        f64     @[json: 'exchangeRateUsed']
	sort                      ?int    @[json: 'sort']
	status                    u8      @[json: 'status']
	updater_id                ?string @[json: 'updaterId']
	creator_id                ?string @[json: 'creatorId']
	created_at                string  @[json: 'createdAt']
	updated_at                string  @[json: 'updatedAt']
	deleted_at                string  @[json: 'deletedAt']
}

pub struct CurrencyListResp {
	total int
	data  []CurrencyData
}

// ═══ Repository ═══
fn find_currency_all_repo(mut ctx Context, req CurrencyListReq) !CurrencyListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from BaseCurrency
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
			if req.english_name != '' {english_name == req.english_name},
			if req.currency_code != '' {currency_code == req.currency_code},
			if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from BaseCurrency where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	// 构造返回数据
	mut datalist := []CurrencyData{}
	for row in result {
		datalist << CurrencyData{
			id:                        row.id
			english_name:              row.english_name
			simplified_name:           row.simplified_name
			currency_code:             row.currency_code
			currency_symbol:           row.currency_symbol
			decimal_place:             row.decimal_place
			exchange_rate:             row.exchange_rate
			exchange_rate_fluctuation: row.exchange_rate_fluctuation
			exchange_rate_used:        row.exchange_rate_used
			sort:                      row.sort
			status:                    row.status
			creator_id:                row.creator_id
			updater_id:                row.updater_id
			created_at:                row.created_at.format_ss()
			updated_at:                row.updated_at.format_ss()
			deleted_at:                (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return CurrencyListResp{
		total: count
		data:  datalist
	}
}

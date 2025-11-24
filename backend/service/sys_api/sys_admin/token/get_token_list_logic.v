module token

import veb
import log
import time
import orm
import x.json2 as json
import structs.schema_sys { SysToken }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/token/list'; post]
pub fn(app &Token)token_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[TokenListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := token_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn token_list_usecase(mut ctx Context, req TokenListReq) !TokenListResp {
	// Domain 校验
	token_list_domain(req)!

	// Repository 查询
	return token_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn token_list_domain(req TokenListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct TokenListReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'page_size']
	username  string @[json: 'username']
}

pub struct TokenListItem {
	id         string @[json: 'id']
	username   string @[json: 'username']
	token      string @[json: 'token']
	source     string @[json: 'source']
	expired_at string @[json: 'expired_at']
	status     int    @[json: 'status']
	created_at string @[json: 'created_at']
	updated_at string @[json: 'updated_at']
	deleted_at string @[json: 'deleted_at']
}

pub struct TokenListResp {
	total int
	data  []TokenListItem
}

// ----------------- Repository 层 -----------------
fn token_list(mut ctx Context, req TokenListReq) !TokenListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysToken](db)

	// 总数统计
	mut count := sql db {
		select count from SysToken
	}!

	offset_num := (req.page - 1) * req.page_size

	mut query := q.select()!
	if req.username != '' {
		query = query.where('username = ?', req.username)!
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []TokenListItem{}
	for row in result {
		datalist << TokenListItem{
			id:         row.id
			username:   row.username
			token:      row.token
			source:     row.source
			expired_at: row.expired_at.format_ss()
			status:     int(row.status)
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: row.deleted_at or { time.Time{} }.format_ss()
		}
	}

	return TokenListResp{
		total: count
		data:  datalist
	}
}

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
@['/list'; post]
pub fn (app &Token) get_token_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[TokenListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_token_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn get_token_list_usecase(mut ctx Context, req TokenListReq) !TokenListResp {
	// Domain 校验
	get_token_list_domain(req)!

	// Repository 查询
	return get_token_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_token_list_domain(req TokenListReq) ! {
	if req.page <= 0 || req.page_size <= 0 {
		return error('page and page_size must be positive integers')
	}
}

// ----------------- DTO 层 -----------------
pub struct TokenListReq {
	page      int    @[json: 'page']
	page_size int    @[json: 'pageSize']
	username  string @[json: 'username']
	email     string @[json: 'email']
	nickname  string @[json: 'nickname']
	user_id   string @[json: 'uuid']
}

pub struct TokenListItem {
	token_id   string  @[json: 'id']
	user_id    string  @[json: 'uuid']
	username   string  @[json: 'username']
	token      string  @[json: 'token']
	source     string  @[json: 'source']
	expired_at string  @[json: 'expiredAt']
	status     int     @[json: 'status']
	created_at string  @[json: 'createdAt']
	updated_at string  @[json: 'updatedAt']
	deleted_at ?string @[json: 'deletedAt']
}

pub struct TokenListResp {
	total int
	data  []TokenListItem
}

// ----------------- Repository 层 -----------------
fn get_token_list(mut ctx Context, req TokenListReq) !TokenListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	mut q := orm.new_query[SysToken](db)

	offset_num := (req.page - 1) * req.page_size

	mut query := q.select()!
	if req.username != '' {
		query = query.where('username = ?', req.username)!
	}
	if req.email != '' {
		query = query.where('email = ?', req.email)!
	}
	if req.nickname != '' {
		query = query.where('nickname = ?', req.nickname)!
	}
	if req.user_id != '' {
		query = query.where('user_id = ?', req.user_id)!
	}

	result := query.limit(req.page_size)!.offset(offset_num)!.query()!

	mut datalist := []TokenListItem{}
	for row in result {
		datalist << TokenListItem{
			user_id:    row.user_id
			token_id:   row.id
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
		total: result.len
		data:  datalist
	}
}

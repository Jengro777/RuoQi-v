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
@['/'; post]
pub fn (app &Token) find_token_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[TokenByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_token_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn find_token_by_id_usecase(mut ctx Context, req TokenByIdReq) !TokenByIdResp {
	// Domain 校验
	find_token_by_id_domain(req)!

	// Repository 查询
	return find_token_by_id(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn find_token_by_id_domain(req TokenByIdReq) ! {
	if req.token_id == '' {
		return error('token id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct TokenByIdReq {
	token_id string @[json: 'id']
}

pub struct TokenByIdResp {
	id         string @[json: 'id']
	user_id    string @[json: 'uuid']
	username   string @[json: 'username']
	token      string @[json: 'token']
	source     string @[json: 'source']
	expired_at string @[json: 'expiredAt']
	status     int    @[json: 'status']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

// ----------------- Repository 层 -----------------
fn find_token_by_id(mut ctx Context, req TokenByIdReq) !TokenByIdResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	mut q := orm.new_query[SysToken](db)
	query := q.select()!.where('id = ?', req.token_id)!
	result := query.query()!

	if result.len == 0 {
		return error('Token not found')
	}

	row := result[0]
	return TokenByIdResp{
		id:         row.id
		user_id:    row.user_id
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

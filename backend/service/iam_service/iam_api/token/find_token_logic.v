module token

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamToken }
import common.api

@['/find_token_all'; post]
pub fn (app &Token) find_token_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_token_all_usecase(mut ctx) or { return ctx.json(api.json_error_500(err.msg())) }
	return ctx.json(api.json_success_200(result))
}

@['/delete_token'; post]
pub fn (app &Token) delete_token_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteTokenReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_token_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

@['/delete_token_by_user'; post]
pub fn (app &Token) delete_token_by_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := delete_token_by_user_usecase(mut ctx) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn find_token_all_usecase(mut ctx Context) ![]IamToken {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	tokens := sql db {
		select from IamToken
	} or { return error('Failed: ${err}') }
	return tokens
}

pub fn delete_token_usecase(mut ctx Context, req DeleteTokenReq) !map[string]string {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	sql db {
		delete from IamToken where id == req.id
	}!
	return {
		'msg': 'Token deleted successfully'
	}
}

pub fn delete_token_by_user_usecase(mut ctx Context) !map[string]string {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn') } }
	sql db {
		delete from IamToken where user_id == ctx.svc_iam.user_id
	}!
	return {
		'msg': 'All tokens deleted successfully'
	}
}

pub struct DeleteTokenReq {
	id string @[json: 'id']
}

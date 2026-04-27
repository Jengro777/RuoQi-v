module user

import veb
import log
import x.json2 as json
import structs.schema_sys { SysUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/delete_user'; post]
pub fn (app &User) delete_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteUserReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_user_usecase(mut ctx Context, req DeleteUserReq) !DeleteUserResp {
	// 调用 Domain 层检查逻辑
	delete_user_domain(req)!

	// 调用 Repository 执行删除操作
	delete_user(mut ctx, req.user_id)!

	return DeleteUserResp{
		msg: 'User deleted successfully'
	}
}

// ----------------- Domain 层 -----------------
fn delete_user_domain(req DeleteUserReq) ! {
	if req.user_id == '' {
		return error('user_id cannot be empty')
	}
}

// ----------------- DTO 层 | 请求/返回结构 -----------------
pub struct DeleteUserReq {
	user_id string
}

pub struct DeleteUserResp {
	msg string
}

// ----------------- AdapterRepository 层 -----------------
fn delete_user(mut ctx Context, user_id string) ! {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		update SysUser set del_flag = 1 where id == user_id
	}!
}

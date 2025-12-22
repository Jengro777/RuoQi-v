module user

import veb
import log
import orm
import x.json2 as json
import structs.schema_core { CoreUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/user/delete'; post]
pub fn delete_user_handler(app &User, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteUserReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := delete_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_user_usecase(mut ctx Context, req DeleteUserReq) !DeleteUserResp {
	// Domain 校验
	delete_user_domain(req)!

	// Repository 执行删除
	return delete_user_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_user_domain(req DeleteUserReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteUserReq {
	user_id string @[json: 'user_id']
}

pub struct DeleteUserResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_user_repo(mut ctx Context, req DeleteUserReq) !DeleteUserResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut core_user := orm.new_query[CoreUser](db)
	core_user.set('del_flag = ?', 1)!.where('id = ?', req.user_id)!.update()!

	return DeleteUserResp{
		msg: 'User deleted successfully'
	}
}

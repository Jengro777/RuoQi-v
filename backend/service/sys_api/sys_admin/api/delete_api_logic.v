module api

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysApi }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/api/delete'; post]
pub fn(app &Api)api_delete_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteApiReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_api_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_api_usecase(mut ctx Context, req DeleteApiReq) !DeleteApiResp {
	// Domain 校验
	delete_api_domain(req)!

	// Repository 执行删除
	return delete_api_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_api_domain(req DeleteApiReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteApiReq {
	id string @[json: 'id']
}

pub struct DeleteApiResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_api_repo(mut ctx Context, req DeleteApiReq) !DeleteApiResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysApi](db)
	q.delete()!.where('id = ?', req.id)!.update()!
	// 若需要逻辑删除可以改成：
	// q.set('del_flag = ?', 1)!.where('id = ?', req.id)!.update()!

	return DeleteApiResp{
		msg: 'API deleted successfully'
	}
}

module menu

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/menu/delete'; post]
pub fn(app &Menu)delete_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn delete_menu_usecase(mut ctx Context, req DeleteMenuReq) !DeleteMenuResp {
	// 参数校验
	delete_menu_domain(req)!

	// 执行数据库删除
	return delete_menu_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_menu_domain(req DeleteMenuReq) ! {
	if req.id == '' {
		return error('menu id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteMenuReq {
	id string @[json: 'id']
}

pub struct DeleteMenuResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_menu_repo(mut ctx Context, req DeleteMenuReq) !DeleteMenuResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysMenu](db)
	q.delete()!.where('id = ?', req.id)!.update()!

	return DeleteMenuResp{
		msg: 'Menu deleted successfully'
	}
}

module menu

import veb
import log
import x.json2 as json
import structs.schema_core { CoreMenu }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/menu/delete'; post]
pub fn delete_menu_handler(app &Menu, mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := delete_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_menu_usecase(mut ctx Context, req DeleteMenuReq) !DeleteMenuResp {
	// Domain 校验
	delete_menu_domain(req)!

	// Repository 删除
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
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		delete from CoreMenu where id == req.id
	} or { return error('Failed to delete menu: ${err}') }

	return DeleteMenuResp{
		msg: 'CoreMenu deleted successfully'
	}
}

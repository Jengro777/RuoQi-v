module platform_menu

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_platform { PfMenu }
import common.api

// ═══ Handler ═══
@['/delete_menu'; post]
pub fn (app &PlatformMenu) delete_menu_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteMenuReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := delete_menu_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_menu_usecase(mut ctx Context, req DeleteMenuReq) !DeleteMenuResp {
	delete_menu_domain(req)!
	return delete_menu_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_menu_domain(req DeleteMenuReq) ! {
	if req.id == '' { return error('id is required') }
}

// ═══ DTO ═══
pub struct DeleteMenuReq {
	id string @[json: 'id']
}

pub struct DeleteMenuResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_menu_repo(mut ctx Context, req DeleteMenuReq) !DeleteMenuResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update PfMenu set del_flag = 1 where id == req.id
	}!
	return DeleteMenuResp{
		msg: 'Menu deleted'
	}
}

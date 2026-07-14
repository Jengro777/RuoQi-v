module region_adm_div

import veb
import log
import json2 as json
import structs.schema_base { BaseRegionAdmDiv }
import common.api
import structs { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &RegionAdmDiv) delete_adm_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteAdmReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := delete_adm_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_adm_usecase(mut ctx Context, req DeleteAdmReq) !DeleteAdmResp {
	// Domain 校验
	delete_adm_domain(req)!

	// Repository 执行删除
	return delete_adm_repo(mut ctx, req.adm_ids)
}

// ═══ Domain ═══
fn delete_adm_domain(req DeleteAdmReq) ! {
	if req.adm_ids.len == 0 {
		return error('No Adm ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteAdmReq {
	adm_ids []string @[json: 'ids']
}

pub struct DeleteAdmResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_adm_repo(mut ctx Context, adm_ids []string) !DeleteAdmResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from BaseRegionAdmDiv where id in adm_ids
	} or { return error('Failed to delete adm: ${err}') }

	return DeleteAdmResp{
		msg: '${adm_ids} token(s) deleted successfully'
	}
}

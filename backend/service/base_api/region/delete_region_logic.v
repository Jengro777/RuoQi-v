module region

import veb
import log
import x.json2 as json
import structs.schema_base { BaseRegion }
import common.api
import structs { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &Region) delete_region_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteRegionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	// Usecase 执行
	result := delete_region_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn delete_region_usecase(mut ctx Context, req DeleteRegionReq) !DeleteRegionResp {
	// Domain 校验
	delete_region_domain(req)!

	// Repository 执行删除
	return delete_region_repo(mut ctx, req.region_ids)
}

// ═══ Domain ═══
fn delete_region_domain(req DeleteRegionReq) ! {
	if req.region_ids.len == 0 {
		return error('No Region ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteRegionReq {
	region_ids []string @[json: 'ids']
}

pub struct DeleteRegionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_region_repo(mut ctx Context, region_ids []string) !DeleteRegionResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from BaseRegion where id in region_ids
	} or { return error('Failed to delete region: ${err}') }

	return DeleteRegionResp{
		msg: '${region_ids} region(s) deleted successfully'
	}
}

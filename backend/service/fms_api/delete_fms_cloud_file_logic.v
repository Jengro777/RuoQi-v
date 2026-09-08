module fms_api

import time
import veb
import log
import json2 as json
import model.schema_fms { FmsCloudFile, FmsCloudFileCloudFileTag }
import common.api
import model { Context }

// ═══ Handler ═══
@['/cloudfile/delete'; post]
pub fn (app &Fms) delete_fms_cloud_file_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteFmsCloudFileReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_fms_cloud_file_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_fms_cloud_file_usecase(mut ctx Context, req DeleteFmsCloudFileReq) !DeleteFmsCloudFileResp {
	delete_fms_cloud_file_domain(req)!
	return delete_fms_cloud_file_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_fms_cloud_file_domain(req DeleteFmsCloudFileReq) ! {
	if req.ids.len == 0 {
		return error('No FmsCloudFile ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteFmsCloudFileReq {
	ids []string @[json: 'ids']
}

pub struct DeleteFmsCloudFileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_fms_cloud_file_repo(mut ctx Context, ids []string) !DeleteFmsCloudFileResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	db.execute('BEGIN') or { return error('Failed to begin transaction: ${err}') }

	sql db {
		delete from FmsCloudFileCloudFileTag where cloud_file_id in ids
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to delete join table rows: ${err}')
	}

	sql db {
		update FmsCloudFile set del_flag = -1, deleted_at = time.now(), updated_at = time.now(),
		updater_id = ctx.svc_iam.user_id where id in ids && del_flag == 0
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to soft-delete cloud file: ${err}')
	}

	db.execute('COMMIT') or { return error('Failed to commit transaction: ${err}') }

	return DeleteFmsCloudFileResp{
		msg: '${ids.len} FmsCloudFile(s) deleted successfully'
	}
}

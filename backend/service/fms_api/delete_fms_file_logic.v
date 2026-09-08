module fms_api

import time
import veb
import log
import json2 as json
import model.schema_fms { FmsFile, FmsFileJoinTag }
import common.api
import model { Context }

// ═══ Handler ═══
@['/file/delete'; post]
pub fn (app &Fms) delete_fms_file_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteFmsFileReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_fms_file_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_fms_file_usecase(mut ctx Context, req DeleteFmsFileReq) !DeleteFmsFileResp {
	delete_fms_file_domain(req)!
	return delete_fms_file_repo(mut ctx, req.ids)
}

// ═══ Domain ═══
fn delete_fms_file_domain(req DeleteFmsFileReq) ! {
	if req.ids.len == 0 {
		return error('No FmsFile ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteFmsFileReq {
	ids []string @[json: 'ids']
}

pub struct DeleteFmsFileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_fms_file_repo(mut ctx Context, ids []string) !DeleteFmsFileResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	db.execute('BEGIN') or { return error('Failed to begin transaction: ${err}') }

	sql db {
		delete from FmsFileJoinTag where file_id in ids
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to delete join table rows: ${err}')
	}

	sql db {
		update FmsFile set del_flag = -1, deleted_at = time.now(), updated_at = time.now(),
		updater_id = ctx.svc_iam.user_id where id in ids && del_flag == 0
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to soft-delete file: ${err}')
	}

	db.execute('COMMIT') or { return error('Failed to commit transaction: ${err}') }

	return DeleteFmsFileResp{
		msg: '${ids.len} FmsFile(s) deleted successfully'
	}
}

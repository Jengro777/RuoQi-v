module fms_api

import time
import veb
import log
import json2 as json
import model.schema_fms { FmsCloudFileCloudFileTag, FmsCloudFileTag }
import common.api
import model { Context }

@['/cloudtag/delete'; post]
pub fn (app &Fms) delete_fms_cloud_file_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteFmsCloudFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_fms_cloud_file_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn delete_fms_cloud_file_tag_usecase(mut ctx Context, req DeleteFmsCloudFileTagReq) !DeleteFmsCloudFileTagResp {
	delete_fms_cloud_file_tag_domain(req)!
	return delete_fms_cloud_file_tag_repo(mut ctx, req.ids)
}

fn delete_fms_cloud_file_tag_domain(req DeleteFmsCloudFileTagReq) ! {
	if req.ids.len == 0 {
		return error('No FmsCloudFileTag ids provided')
	}
}

pub struct DeleteFmsCloudFileTagReq {
	ids []string @[json: 'ids']
}

pub struct DeleteFmsCloudFileTagResp {
	msg string @[json: 'msg']
}

fn delete_fms_cloud_file_tag_repo(mut ctx Context, ids []string) !DeleteFmsCloudFileTagResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	db.execute('BEGIN') or { return error('Failed to begin transaction: ${err}') }

	sql db {
		delete from FmsCloudFileCloudFileTag where cloud_file_tag_id in ids
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to delete join table rows: ${err}')
	}

	sql db {
		update FmsCloudFileTag set del_flag = -1, deleted_at = time.now(), updated_at = time.now(),
		updater_id = ctx.svc_iam.user_id where id in ids && del_flag == 0
	} or {
		db.execute('ROLLBACK') or {}
		return error('Failed to soft-delete cloud file tag: ${err}')
	}

	db.execute('COMMIT') or { return error('Failed to commit transaction: ${err}') }

	return DeleteFmsCloudFileTagResp{
		msg: '${ids.len} FmsCloudFileTag(s) deleted successfully'
	}
}

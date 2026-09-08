module fms_api

import veb
import log
import json2 as json
import time
import model.schema_fms { FmsFile }
import common.api
import model { Context }

// ═══ Handler ═══
@['/file/by_id'; post]
pub fn (app &Fms) find_fms_file_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FmsFileByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_fms_file_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_fms_file_by_id_usecase(mut ctx Context, req FmsFileByIdReq) !FmsFileByIdResp {
	find_fms_file_by_id_domain(req)!
	return find_fms_file_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_fms_file_by_id_domain(req FmsFileByIdReq) ! {
	if req.id == '' {
		return error('file id is required')
	}
}

// ═══ DTO ═══
pub struct FmsFileByIdReq {
	id string @[json: 'id']
}

pub struct FmsFileByIdResp {
	data FmsFileData
}

// ═══ Repository ═══
fn find_fms_file_by_id_repo(mut ctx Context, req FmsFileByIdReq) !FmsFileByIdResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	files := sql db {
		select from FmsFile where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed: ${err}') }
	if files.len == 0 {
		return error('FmsFile not found')
	}

	row := files[0]
	return FmsFileByIdResp{
		data: FmsFileData{
			id: row.id
			name: row.name
			file_type: row.file_type
			size: row.size
			path: row.path
			user_id: row.user_id
			md5: row.md5
			status: row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}
}

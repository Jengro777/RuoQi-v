module fms_api

import veb
import log
import time
import json2 as json
import model.schema_fms { FmsCloudFile }
import common.api
import model { Context }

// ═══ Handler ═══
@['/cloudfile/by_id'; post]
pub fn (app &Fms) find_fms_cloud_file_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FmsCloudFileByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_fms_cloud_file_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_fms_cloud_file_by_id_usecase(mut ctx Context, req FmsCloudFileByIdReq) !FmsCloudFileByIdResp {
	find_fms_cloud_file_by_id_domain(req)!
	return find_fms_cloud_file_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_fms_cloud_file_by_id_domain(req FmsCloudFileByIdReq) ! {
	if req.id == '' {
		return error('cloud file id is required')
	}
}

// ═══ DTO ═══
pub struct FmsCloudFileByIdReq {
	id string @[json: 'id']
}

pub struct FmsCloudFileByIdResp {
	data FmsCloudFileData
}

// ═══ Repository ═══
fn find_fms_cloud_file_by_id_repo(mut ctx Context, req FmsCloudFileByIdReq) !FmsCloudFileByIdResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	files := sql db {
		select from FmsCloudFile where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed: ${err}') }

	if files.len == 0 {
		return error('FmsCloudFile not found')
	}

	row := files[0]
	return FmsCloudFileByIdResp{
		data: FmsCloudFileData{
			id: row.id
			name: row.name
			url: row.url
			size: row.size
			file_type: row.file_type
			user_id: row.user_id
			cloud_file_storage_providers: row.cloud_file_storage_providers
			status: row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}
}

module fms_api

import veb
import log
import time
import json2 as json
import model.schema_fms { FmsCloudFile }
import common.api
import model { Context }

// ═══ Handler ═══
@['/cloudfile/update'; post]
pub fn (app &Fms) update_fms_cloud_file_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateFmsCloudFileReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_fms_cloud_file_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_fms_cloud_file_usecase(mut ctx Context, req UpdateFmsCloudFileReq) !UpdateFmsCloudFileResp {
	update_fms_cloud_file_domain(req)!
	return update_fms_cloud_file_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_fms_cloud_file_domain(req UpdateFmsCloudFileReq) ! {
	if req.id == '' {
		return error('cloud file id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateFmsCloudFileReq {
	id                           string @[json: 'id']
	name                         ?string @[json: 'name']
	url                          ?string @[json: 'url']
	file_type                    ?u8 @[json: 'fileType']
	cloud_file_storage_providers ?string @[json: 'cloudFileStorageProviders']
	status                       ?u8 @[json: 'status']
}

pub struct UpdateFmsCloudFileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_fms_cloud_file_repo(mut ctx Context, req UpdateFmsCloudFileReq) !UpdateFmsCloudFileResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	existing := sql db {
		select from FmsCloudFile where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed to check existence: ${err}') }
	if existing.len == 0 {
		return error('FmsCloudFile with id ${req.id} not found')
	}

	up_expr :=
		sql {
		}

	sql db {
		dynamic update FmsCloudFile set up_expr where id == req.id && del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateFmsCloudFileResp{
		msg: 'FmsCloudFile updated successfully'
	}
}

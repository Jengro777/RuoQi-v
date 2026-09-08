module fms_api

import veb
import log
import time
import json2 as json
import model.schema_fms { FmsStorageProvider }
import common.api
import model { Context }

@['/provider/by_id'; post]
pub fn (app &Fms) find_fms_storage_provider_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FmsStorageProviderByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := find_fms_storage_provider_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn find_fms_storage_provider_by_id_usecase(mut ctx Context, req FmsStorageProviderByIdReq) !FmsStorageProviderByIdResp {
	find_fms_storage_provider_by_id_domain(req)!
	return find_fms_storage_provider_by_id_repo(mut ctx, req)
}

fn find_fms_storage_provider_by_id_domain(req FmsStorageProviderByIdReq) ! {
	if req.id == '' {
		return error('provider id is required')
	}
}

pub struct FmsStorageProviderByIdReq {
	id string @[json: 'id']
}

pub struct FmsStorageProviderByIdResp {
	data FmsStorageProviderData
}

fn find_fms_storage_provider_by_id_repo(mut ctx Context, req FmsStorageProviderByIdReq) !FmsStorageProviderByIdResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	providers := sql db {
		select from FmsStorageProvider where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed: ${err}') }
	if providers.len == 0 {
		return error('FmsStorageProvider not found')
	}

	row := providers[0]
	return FmsStorageProviderByIdResp{
		data: FmsStorageProviderData{
			id: row.id
			name: row.name
			bucket: row.bucket
			endpoint: row.endpoint
			folder: row.folder
			region: row.region
			is_default: row.is_default
			use_cdn: row.use_cdn
			cdn_url: row.cdn_url
			status: row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}
}

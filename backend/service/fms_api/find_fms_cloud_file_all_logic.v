module fms_api

import veb
import log
import time
import model.schema_fms { FmsCloudFile }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/cloudfile/all'; get]
pub fn (app &Fms) find_fms_cloud_file_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FmsCloudFileListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_fms_cloud_file_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_fms_cloud_file_all_usecase(mut ctx Context, req FmsCloudFileListReq) !FmsCloudFileListResp {
	find_fms_cloud_file_all_domain(req)!
	return find_fms_cloud_file_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_fms_cloud_file_all_domain(req FmsCloudFileListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct FmsCloudFileListReq {
	page      int @[json: 'page']
	page_size int @[json: 'pageSize']
	name      string @[json: 'name']
	user_id   string @[json: 'userId']
	file_type []u8 @[json: 'fileType']
	status    []u8 @[json: 'status']
}

pub struct FmsCloudFileData {
	id                           string @[json: 'id']
	name                         string @[json: 'name']
	url                          string @[json: 'url']
	size                         u64 @[json: 'size']
	file_type                    u8 @[json: 'fileType']
	user_id                      string @[json: 'userId']
	cloud_file_storage_providers ?string @[json: 'cloudFileStorageProviders']
	status                       u8 @[json: 'status']
	updater_id                   ?string @[json: 'updaterId']
	creator_id                   ?string @[json: 'creatorId']
	created_at                   string @[json: 'createdAt']
	updated_at                   string @[json: 'updatedAt']
	deleted_at                   string @[json: 'deletedAt']
}

pub struct FmsCloudFileListResp {
	total int
	data  []FmsCloudFileData
}

// ═══ Repository ═══
fn find_fms_cloud_file_all_repo(mut ctx Context, req FmsCloudFileListReq) !FmsCloudFileListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from FmsCloudFile where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.name != '' {name == req.name},
		if req.user_id != '' {user_id == req.user_id},
		if req.file_type.len > 0 {file_type in req.file_type},
		if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from FmsCloudFile where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []FmsCloudFileData{}
	for row in result {
		datalist << FmsCloudFileData{
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

	return FmsCloudFileListResp{
		total: count
		data: datalist
	}
}

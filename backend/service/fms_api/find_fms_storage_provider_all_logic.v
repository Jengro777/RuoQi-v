module fms_api

import veb
import log
import time
import model.schema_fms { FmsStorageProvider }
import common.api
import model { Context }
import json2 as json

@['/provider/all'; get]
pub fn (app &Fms) find_fms_storage_provider_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FmsStorageProviderListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_fms_storage_provider_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn find_fms_storage_provider_all_usecase(mut ctx Context, req FmsStorageProviderListReq) !FmsStorageProviderListResp {
	find_fms_storage_provider_all_domain(req)!
	return find_fms_storage_provider_all_repo(mut ctx, req)
}

fn find_fms_storage_provider_all_domain(req FmsStorageProviderListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

pub struct FmsStorageProviderListReq {
	page      int @[json: 'page']
	page_size int @[json: 'pageSize']
	name      string @[json: 'name']
	status    []u8 @[json: 'status']
}

pub struct FmsStorageProviderData {
	id         string @[json: 'id']
	name       string @[json: 'name']
	bucket     string @[json: 'bucket']
	endpoint   string @[json: 'endpoint']
	folder     ?string @[json: 'folder']
	region     string @[json: 'region']
	is_default u8 @[json: 'isDefault']
	use_cdn    u8 @[json: 'useCdn']
	cdn_url    ?string @[json: 'cdnUrl']
	status     u8 @[json: 'status']
	updater_id ?string @[json: 'updaterId']
	creator_id ?string @[json: 'creatorId']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

pub struct FmsStorageProviderListResp {
	total int
	data  []FmsStorageProviderData
}

fn find_fms_storage_provider_all_repo(mut ctx Context, req FmsStorageProviderListReq) !FmsStorageProviderListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	mut count := sql db {
		select count from FmsStorageProvider where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }
	offset_num := (req.page - 1) * req.page_size
	where_expr :=
		sql {
		}
	result := sql db {
		dynamic select from FmsStorageProvider where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }
	mut datalist := []FmsStorageProviderData{}
	for row in result {
		datalist << FmsStorageProviderData{
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
	return FmsStorageProviderListResp{
		total: count
		data: datalist
	}
}

module fms_api

import veb
import log
import time
import model.schema_fms { FmsCloudFileTag }
import common.api
import model { Context }
import json2 as json

@['/cloudtag/all'; get]
pub fn (app &Fms) find_fms_cloud_file_tag_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FmsCloudFileTagListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_fms_cloud_file_tag_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub fn find_fms_cloud_file_tag_all_usecase(mut ctx Context, req FmsCloudFileTagListReq) !FmsCloudFileTagListResp {
	find_fms_cloud_file_tag_all_domain(req)!
	return find_fms_cloud_file_tag_all_repo(mut ctx, req)
}

fn find_fms_cloud_file_tag_all_domain(req FmsCloudFileTagListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

pub struct FmsCloudFileTagListReq {
	page      int @[json: 'page']
	page_size int @[json: 'pageSize']
	name      string @[json: 'name']
	status    []u8 @[json: 'status']
}

pub struct FmsCloudFileTagData {
	id         string @[json: 'id']
	name       string @[json: 'name']
	remark     ?string @[json: 'remark']
	status     u8 @[json: 'status']
	updater_id ?string @[json: 'updaterId']
	creator_id ?string @[json: 'creatorId']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

pub struct FmsCloudFileTagListResp {
	total int
	data  []FmsCloudFileTagData
}

fn find_fms_cloud_file_tag_all_repo(mut ctx Context, req FmsCloudFileTagListReq) !FmsCloudFileTagListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	mut count := sql db {
		select count from FmsCloudFileTag where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }
	offset_num := (req.page - 1) * req.page_size
	where_expr :=
		sql {
		}
	result := sql db {
		dynamic select from FmsCloudFileTag where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }
	mut datalist := []FmsCloudFileTagData{}
	for row in result {
		datalist << FmsCloudFileTagData{
			id: row.id
			name: row.name
			remark: row.remark
			status: row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}
	return FmsCloudFileTagListResp{
		total: count
		data: datalist
	}
}

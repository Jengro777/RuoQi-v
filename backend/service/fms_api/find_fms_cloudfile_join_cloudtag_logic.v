module fms_api

import veb
import log
import model.schema_fms { FmsCloudFileCloudFileTag }
import common.api
import model { Context }
import json2 as json

@['/cloudfile_tag/all'; get]
pub fn (app &Fms) find_fms_cloudfile_join_cloudtag_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FmsCloudFileCloudFileTagListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := find_fms_cloudfile_join_cloudtag_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn find_fms_cloudfile_join_cloudtag_all_usecase(mut ctx Context, req FmsCloudFileCloudFileTagListReq) !FmsCloudFileCloudFileTagListResp {
	find_fms_cloudfile_join_cloudtag_all_domain(req)!
	return find_fms_cloudfile_join_cloudtag_all_repo(mut ctx, req)
}

fn find_fms_cloudfile_join_cloudtag_all_domain(req FmsCloudFileCloudFileTagListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

pub struct FmsCloudFileCloudFileTagListReq {
	page              int @[json: 'page']
	page_size         int @[json: 'pageSize']
	cloud_file_tag_id string @[json: 'cloudFileTagId']
	cloud_file_id     string @[json: 'cloudFileId']
}

pub struct FmsCloudFileCloudFileTagData {
	cloud_file_tag_id string @[json: 'cloudFileTagId']
	cloud_file_id     string @[json: 'cloudFileId']
}

pub struct FmsCloudFileCloudFileTagListResp {
	total int
	data  []FmsCloudFileCloudFileTagData
}

fn find_fms_cloudfile_join_cloudtag_all_repo(mut ctx Context, req FmsCloudFileCloudFileTagListReq) !FmsCloudFileCloudFileTagListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	mut count := sql db {
		select count from FmsCloudFileCloudFileTag
	} or { return error('Failed to execute SQL query: ${err}') }
	offset_num := (req.page - 1) * req.page_size
	where_expr :=
		sql {
		}
	result := sql db {
		dynamic select from FmsCloudFileCloudFileTag where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }
	mut datalist := []FmsCloudFileCloudFileTagData{}
	for row in result {
		datalist << FmsCloudFileCloudFileTagData{
			cloud_file_tag_id: row.cloud_file_tag_id
			cloud_file_id: row.cloud_file_id
		}
	}
	return FmsCloudFileCloudFileTagListResp{
		total: count
		data: datalist
	}
}

module fms_api

import veb
import log
import model.schema_fms { FmsFileJoinTag }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/file_tag/all'; get]
pub fn (app &Fms) find_fms_file_join_tag_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[FmsFileJoinTagListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_fms_file_join_tag_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_fms_file_join_tag_all_usecase(mut ctx Context, req FmsFileJoinTagListReq) !FmsFileJoinTagListResp {
	find_fms_file_join_tag_all_domain(req)!
	return find_fms_file_join_tag_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_fms_file_join_tag_all_domain(req FmsFileJoinTagListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct FmsFileJoinTagListReq {
	page        int @[json: 'page']
	page_size   int @[json: 'pageSize']
	file_tag_id string @[json: 'fileTagId']
	file_id     string @[json: 'fileId']
}

pub struct FmsFileJoinTagData {
	file_tag_id string @[json: 'fileTagId']
	file_id     string @[json: 'fileId']
}

pub struct FmsFileJoinTagListResp {
	total int
	data  []FmsFileJoinTagData
}

// ═══ Repository ═══
fn find_fms_file_join_tag_all_repo(mut ctx Context, req FmsFileJoinTagListReq) !FmsFileJoinTagListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from FmsFileJoinTag
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		if req.file_tag_id != '' {file_tag_id == req.file_tag_id},
		if req.file_id != '' {file_id == req.file_id}
	}
	// vfmt on
	result := sql db {
		dynamic select from FmsFileJoinTag where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []FmsFileJoinTagData{}
	for row in result {
		datalist << FmsFileJoinTagData{
			file_tag_id: row.file_tag_id
			file_id: row.file_id
		}
	}

	return FmsFileJoinTagListResp{
		total: count
		data: datalist
	}
}

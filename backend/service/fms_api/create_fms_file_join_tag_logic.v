module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsFileJoinTag }
import common.api
import model { Context }

// ═══ Handler ═══
@['/file_tag/create'; post]
pub fn (app &Fms) create_fms_file_join_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateFmsFileJoinTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_fms_file_join_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_fms_file_join_tag_usecase(mut ctx Context, req CreateFmsFileJoinTagReq) !CreateFmsFileJoinTagResp {
	create_fms_file_join_tag_domain(req)!
	return create_fms_file_join_tag_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_fms_file_join_tag_domain(req CreateFmsFileJoinTagReq) ! {
	if req.file_tag_id == '' {
		return error('file tag id is required')
	}
	if req.file_id == '' {
		return error('file id is required')
	}
}

// ═══ DTO ═══
pub struct CreateFmsFileJoinTagReq {
	file_tag_id string @[json: 'fileTagId']
	file_id     string @[json: 'fileId']
}

pub struct CreateFmsFileJoinTagResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_fms_file_join_tag_repo(mut ctx Context, req CreateFmsFileJoinTagReq) !CreateFmsFileJoinTagResp {
	join := FmsFileJoinTag{
		file_tag_id: req.file_tag_id
		file_id: req.file_id
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	existing := sql db {
		select from FmsFileJoinTag where file_tag_id == req.file_tag_id && file_id == req.file_id limit 1
	} or { return error('Failed to check duplicate: ${err}') }
	if existing.len > 0 {
		return error('Link between file and tag already exists')
	}

	sql db {
		insert join into FmsFileJoinTag
	} or { return error('Failed to create file-tag link: ${err}') }

	return CreateFmsFileJoinTagResp{
		msg: 'File-tag link created successfully'
	}
}

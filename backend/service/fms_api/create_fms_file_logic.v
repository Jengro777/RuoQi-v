module fms_api

import veb
import log
import time
import rand
import json2 as json
import model.schema_fms { FmsFile }
import common.api
import model { Context }

// ═══ Handler ═══
@['/file/create'; post]
pub fn (app &Fms) create_fms_file_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateFmsFileReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_fms_file_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_fms_file_usecase(mut ctx Context, req CreateFmsFileReq) !CreateFmsFileResp {
	create_fms_file_domain(req)!
	return create_fms_file_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_fms_file_domain(req CreateFmsFileReq) ! {
	if req.name == '' {
		return error('file name is required')
	}
	if req.path == '' {
		return error('file path is required')
	}
	if req.file_type == 0 {
		return error('file type is required')
	}
	if req.size == 0 {
		return error('file size is required')
	}
}

// ═══ DTO ═══
pub struct CreateFmsFileReq {
	name      string @[json: 'name']
	file_type u8 @[json: 'fileType']
	size      u64 @[json: 'size']
	path      string @[json: 'path']
	md5       string @[json: 'md5']
	status    u8 @[json: 'status']
}

pub struct CreateFmsFileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_fms_file_repo(mut ctx Context, req CreateFmsFileReq) !CreateFmsFileResp {
	time_now := time.now()
	file := FmsFile{
		id: rand.uuid_v7()
		name: req.name
		file_type: req.file_type
		size: req.size
		path: req.path
		user_id: ctx.svc_iam.user_id
		md5: req.md5
		status: req.status
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert file into FmsFile
	} or { return error('Failed to create FmsFile: ${err}') }

	return CreateFmsFileResp{
		msg: 'FmsFile created successfully'
	}
}

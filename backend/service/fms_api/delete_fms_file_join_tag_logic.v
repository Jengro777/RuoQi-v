module fms_api

import veb
import log
import json2 as json
import model.schema_fms { FmsFileJoinTag }
import common.api
import model { Context }

// ═══ Handler ═══
@['/file_tag/delete'; post]
pub fn (app &Fms) delete_fms_file_join_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteFmsFileJoinTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := delete_fms_file_join_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_fms_file_join_tag_usecase(mut ctx Context, req DeleteFmsFileJoinTagReq) !DeleteFmsFileJoinTagResp {
	delete_fms_file_join_tag_domain(req)!
	return delete_fms_file_join_tag_repo(mut ctx, req)
}

// ═══ Domain ═══
fn delete_fms_file_join_tag_domain(req DeleteFmsFileJoinTagReq) ! {
	if req.file_tag_id == '' || req.file_id == '' {
		return error('file tag id and file id are both required')
	}
}

// ═══ DTO ═══
pub struct DeleteFmsFileJoinTagReq {
	file_tag_id string @[json: 'fileTagId']
	file_id     string @[json: 'fileId']
}

pub struct DeleteFmsFileJoinTagResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_fms_file_join_tag_repo(mut ctx Context, req DeleteFmsFileJoinTagReq) !DeleteFmsFileJoinTagResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		delete from FmsFileJoinTag where file_tag_id == req.file_tag_id && file_id == req.file_id
	} or { return error('Failed to delete file-tag link: ${err}') }

	return DeleteFmsFileJoinTagResp{
		msg: 'File-tag link deleted successfully'
	}
}

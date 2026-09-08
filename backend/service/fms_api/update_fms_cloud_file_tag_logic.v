module fms_api

import veb
import log
import time
import json2 as json
import model.schema_fms { FmsCloudFileTag }
import common.api
import model { Context }

@['/cloudtag/update'; post]
pub fn (app &Fms) update_fms_cloud_file_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateFmsCloudFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := update_fms_cloud_file_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn update_fms_cloud_file_tag_usecase(mut ctx Context, req UpdateFmsCloudFileTagReq) !UpdateFmsCloudFileTagResp {
	update_fms_cloud_file_tag_domain(req)!
	return update_fms_cloud_file_tag_repo(mut ctx, req)
}

fn update_fms_cloud_file_tag_domain(req UpdateFmsCloudFileTagReq) ! {
	if req.id == '' {
		return error('tag id is required')
	}
}

pub struct UpdateFmsCloudFileTagReq {
	id     string @[json: 'id']
	name   ?string @[json: 'name']
	remark ?string @[json: 'remark']
	status ?u8 @[json: 'status']
}

pub struct UpdateFmsCloudFileTagResp {
	msg string @[json: 'msg']
}

fn update_fms_cloud_file_tag_repo(mut ctx Context, req UpdateFmsCloudFileTagReq) !UpdateFmsCloudFileTagResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	existing := sql db {
		select from FmsCloudFileTag where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed to check existence: ${err}') }
	if existing.len == 0 {
		return error('FmsCloudFileTag with id ${req.id} not found')
	}

	up_expr :=
		sql {
		}
	sql db {
		dynamic update FmsCloudFileTag set up_expr where id == req.id && del_flag == 0
	} or { return error('Failed to update cloud file tag: ${err}') }
	return UpdateFmsCloudFileTagResp{
		msg: 'FmsCloudFileTag updated successfully'
	}
}

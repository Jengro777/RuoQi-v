module fms_api

import veb
import log
import time
import rand
import json2 as json
import model.schema_fms { FmsCloudFileTag }
import common.api
import model { Context }

// ═══ Handler ═══
@['/cloudtag/create'; post]
pub fn (app &Fms) create_fms_cloud_file_tag_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateFmsCloudFileTagReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_fms_cloud_file_tag_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

pub fn create_fms_cloud_file_tag_usecase(mut ctx Context, req CreateFmsCloudFileTagReq) !CreateFmsCloudFileTagResp {
	create_fms_cloud_file_tag_domain(req)!
	return create_fms_cloud_file_tag_repo(mut ctx, req)
}

fn create_fms_cloud_file_tag_domain(req CreateFmsCloudFileTagReq) ! {
	if req.name == '' {
		return error('tag name is required')
	}
	if req.status == 0 {
		return error('status is required')
	}
}

pub struct CreateFmsCloudFileTagReq {
	name   string @[json: 'name']
	remark ?string @[json: 'remark']
	status u8 @[json: 'status']
}

pub struct CreateFmsCloudFileTagResp {
	msg string @[json: 'msg']
}

fn create_fms_cloud_file_tag_repo(mut ctx Context, req CreateFmsCloudFileTagReq) !CreateFmsCloudFileTagResp {
	time_now := time.now()
	tag := FmsCloudFileTag{
		id: rand.uuid_v7()
		name: req.name
		remark: req.remark
		status: req.status
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		insert tag into FmsCloudFileTag
	} or { return error('Failed to create FmsCloudFileTag: ${err}') }
	return CreateFmsCloudFileTagResp{
		msg: 'FmsCloudFileTag created successfully'
	}
}

module fms_api

import veb
import log
import time
import rand
import json2 as json
import model.schema_fms { FmsCloudFile }
import common.api
import model { Context }

// ═══ Handler ═══
@['/cloudfile/create'; post]
pub fn (app &Fms) create_fms_cloud_file_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateFmsCloudFileReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_fms_cloud_file_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_fms_cloud_file_usecase(mut ctx Context, req CreateFmsCloudFileReq) !CreateFmsCloudFileResp {
	create_fms_cloud_file_domain(req)!
	return create_fms_cloud_file_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_fms_cloud_file_domain(req CreateFmsCloudFileReq) ! {
	if req.name == '' {
		return error('file name is required')
	}
	if req.url == '' {
		return error('file url is required')
	}
	if req.file_type == 0 {
		return error('file type is required')
	}
	if req.size == 0 {
		return error('file size is required')
	}
}

// ═══ DTO ═══
pub struct CreateFmsCloudFileReq {
	name                         string @[json: 'name']
	url                          string @[json: 'url']
	size                         u64 @[json: 'size']
	file_type                    u8 @[json: 'fileType']
	cloud_file_storage_providers ?string @[json: 'cloudFileStorageProviders']
	status                       u8 @[json: 'status']
}

pub struct CreateFmsCloudFileResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_fms_cloud_file_repo(mut ctx Context, req CreateFmsCloudFileReq) !CreateFmsCloudFileResp {
	time_now := time.now()
	file := FmsCloudFile{
		id: rand.uuid_v7()
		name: req.name
		url: req.url
		size: req.size
		file_type: req.file_type
		user_id: ctx.svc_iam.user_id
		cloud_file_storage_providers: req.cloud_file_storage_providers
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
		insert file into FmsCloudFile
	} or { return error('Failed to create FmsCloudFile: ${err}') }

	return CreateFmsCloudFileResp{
		msg: 'FmsCloudFile created successfully'
	}
}

module fms_api

import veb
import log
import time
import rand
import json2 as json
import model.schema_fms { FmsStorageProvider }
import common.api
import model { Context }

@['/provider/create'; post]
pub fn (app &Fms) create_fms_storage_provider_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateFmsStorageProviderReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := create_fms_storage_provider_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(data: result))
}

pub fn create_fms_storage_provider_usecase(mut ctx Context, req CreateFmsStorageProviderReq) !CreateFmsStorageProviderResp {
	create_fms_storage_provider_domain(req)!
	return create_fms_storage_provider_repo(mut ctx, req)
}

fn create_fms_storage_provider_domain(req CreateFmsStorageProviderReq) ! {
	if req.name == '' {
		return error('provider name is required')
	}
	if req.bucket == '' {
		return error('bucket is required')
	}
	if req.secret_id == '' {
		return error('secret id is required')
	}
	if req.secret_key == '' {
		return error('secret key is required')
	}
	if req.endpoint == '' {
		return error('endpoint is required')
	}
	if req.region == '' {
		return error('region is required')
	}
}

pub struct CreateFmsStorageProviderReq {
	name       string @[json: 'name']
	bucket     string @[json: 'bucket']
	secret_id  string @[json: 'secretId']
	secret_key string @[json: 'secretKey']
	endpoint   string @[json: 'endpoint']
	folder     ?string @[json: 'folder']
	region     string @[json: 'region']
	is_default u8 @[json: 'isDefault']
	use_cdn    u8 @[json: 'useCdn']
	cdn_url    ?string @[json: 'cdnUrl']
	status     u8 @[json: 'status']
}

pub struct CreateFmsStorageProviderResp {
	msg string @[json: 'msg']
}

fn create_fms_storage_provider_repo(mut ctx Context, req CreateFmsStorageProviderReq) !CreateFmsStorageProviderResp {
	time_now := time.now()
	p := FmsStorageProvider{
		id: rand.uuid_v7()
		name: req.name
		bucket: req.bucket
		secret_id: req.secret_id
		secret_key: req.secret_key
		endpoint: req.endpoint
		folder: req.folder
		region: req.region
		is_default: req.is_default
		use_cdn: req.use_cdn
		cdn_url: req.cdn_url
		status: req.status
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		insert p into FmsStorageProvider
	} or { return error('Failed to create FmsStorageProvider: ${err}') }
	return CreateFmsStorageProviderResp{
		msg: 'FmsStorageProvider created successfully'
	}
}

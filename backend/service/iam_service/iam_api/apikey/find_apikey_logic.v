module apikey

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamApiKey }
import common.api

pub struct ApiKeyItem {
	id             string   @[json: 'id']
	name           string   @[json: 'name']
	access_key_id  string   @[json: 'access_key_id']
	key_prefix     string   @[json: 'key_prefix']
	key_last_four  string   @[json: 'key_last_four']
	tenant_ids     []string @[json: 'tenant_ids']
	subproduct_ids []string @[json: 'subproduct_ids']
	subportal_ids  []string @[json: 'subportal_ids']
	scopes         []string @[json: 'scopes']
	status         u8       @[json: 'status']
	last_used_at   ?string  @[json: 'last_used_at']
	expired_at     ?string  @[json: 'expired_at']
	created_at     string   @[json: 'created_at']
}

pub struct ApiKeyListResp {
	items []ApiKeyItem @[json: 'items']
	total int          @[json: 'total']
}

@['/iam/apikey/list'; post]
pub fn (app &ApiKey) find_apikey_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_apikey_all_usecase(mut ctx) or { return ctx.json(api.json_error_500('${err}')) }
	return ctx.json(api.json_success_200(result))
}

fn find_apikey_all_usecase(mut ctx Context) !ApiKeyListResp {
	records := find_apikey_all_repo(mut ctx)!
	mut items := []ApiKeyItem{}
	for rec in records {
		items << api_key_to_item(rec)
	}
	return ApiKeyListResp{
		items: items
		total: items.len
	}
}

fn find_apikey_all_repo(mut ctx Context) ![]IamApiKey {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	return sql db {
		select from IamApiKey where user_id == ctx.svc_iam.user_id
	} or { return error('Failed: ${err}') }
}

@['/iam/apikey/detail'; post]
pub fn (app &ApiKey) find_apikey_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindApiKeyByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := find_apikey_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

pub struct FindApiKeyByIdReq {
	id string @[json: 'id']
}

fn find_apikey_by_id_usecase(mut ctx Context, req FindApiKeyByIdReq) !ApiKeyItem {
	record := find_apikey_by_id_repo(mut ctx, req.id)!
	return api_key_to_item(record)
}

fn find_apikey_by_id_repo(mut ctx Context, apikey_id string) !IamApiKey {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	keys := sql db {
		select from IamApiKey where id == apikey_id && user_id == ctx.svc_iam.user_id limit 1
	} or { return error('API Key not found') }
	if keys.len == 0 { return error('API Key not found') }
	return keys[0]
}

fn api_key_to_item(rec IamApiKey) ApiKeyItem {
	return ApiKeyItem{
		id:             rec.id
		name:           rec.name
		access_key_id:  rec.access_key_id
		key_prefix:     rec.key_prefix
		key_last_four:  rec.key_last_four
		tenant_ids:     json.decode[[]string](rec.tenant_ids) or { [] }
		subproduct_ids: json.decode[[]string](rec.subproduct_ids) or { [] }
		subportal_ids:  json.decode[[]string](rec.subportal_ids) or { [] }
		scopes:         json.decode[[]string](rec.scopes) or { ['all'] }
		status:         rec.status
		last_used_at:   if lu := rec.last_used_at { lu.format_ss() } else { none }
		expired_at:     if ex := rec.expired_at { ex.format_ss() } else { none }
		created_at:     rec.created_at.format_ss()
	}
}

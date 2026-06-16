module apikey

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamApiKey }
import common.api

pub struct UpdateApiKeyReq {
	id             string    @[json: 'id']
	name           ?string   @[json: 'name']
	tenant_ids     ?[]string @[json: 'tenant_ids']
	subproduct_ids ?[]string @[json: 'subproduct_ids']
	subportal_ids  ?[]string @[json: 'subportal_ids']
	scopes         ?[]string @[json: 'scopes']
}

@['/iam/apikey/update'; post]
pub fn (app &ApiKey) update_apikey_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateApiKeyReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_apikey_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

fn update_apikey_usecase(mut ctx Context, req UpdateApiKeyReq) !map[string]string {
	if req.id.len == 0 { return error('id is required') }
	if v := req.name {
		if v.len > 255 { return error('name too long') }
	}

	// Check that at least one field is being updated
	if req.name == none && req.tenant_ids == none && req.subproduct_ids == none
		&& req.subportal_ids == none && req.scopes == none {
		return error('no fields to update')
	}

	// Read existing record
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	keys := sql db {
		select from IamApiKey where id == req.id && user_id == ctx.svc_iam.user_id limit 1
	} or { return error('API Key not found') }
	if keys.len == 0 { return error('API Key not found') }
	existing := keys[0]

	// Apply changes (read-modify-write)
	mut name := existing.name
	mut tenant_ids := existing.tenant_ids
	mut subproduct_ids := existing.subproduct_ids
	mut subportal_ids := existing.subportal_ids
	mut scopes := existing.scopes

	if v := req.name { name = v }
	if v := req.tenant_ids { tenant_ids = json.encode(v) }
	if v := req.subproduct_ids { subproduct_ids = json.encode(v) }
	if v := req.subportal_ids { subportal_ids = json.encode(v) }
	if v := req.scopes { scopes = json.encode(v) }

	sql db {
		update IamApiKey set name = name, tenant_ids = tenant_ids, subproduct_ids = subproduct_ids,
		subportal_ids = subportal_ids, scopes = scopes where id == req.id
		&& user_id == ctx.svc_iam.user_id
	}!

	return {
		'msg': 'API Key updated successfully'
		'id':  req.id
	}
}

module apikey

import veb
import log
import time
import rand
import crypto.rand as crand
import crypto.sha256
import json2 as json
import structs { Context }
import structs.schema_iam { IamApiKey }
import common.api

pub struct CreateApiKeyReq {
	name           string   @[json: 'name']
	tenant_ids     []string @[json: 'tenant_ids']
	subproduct_ids []string @[json: 'subproduct_ids']
	subportal_ids  []string @[json: 'subportal_ids']
	scopes         []string @[json: 'scopes']
	expired_at     ?string  @[json: 'expired_at']
}

pub struct CreateApiKeyResp {
	id             string   @[json: 'id']
	name           string   @[json: 'name']
	plain_sk       string   @[json: 'plain_sk']
	access_key_id  string   @[json: 'access_key_id']
	key_prefix     string   @[json: 'key_prefix']
	key_last_four  string   @[json: 'key_last_four']
	tenant_ids     []string @[json: 'tenant_ids']
	subproduct_ids []string @[json: 'subproduct_ids']
	subportal_ids  []string @[json: 'subportal_ids']
	scopes         []string @[json: 'scopes']
	expired_at     ?string  @[json: 'expired_at']
	created_at     string   @[json: 'created_at']
}

@['/iam/apikey/create'; post]
pub fn (app &ApiKey) create_apikey_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateApiKeyReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_apikey_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('${err}'))
	}
	return ctx.json(api.json_success_200(result))
}

fn create_apikey_usecase(mut ctx Context, req CreateApiKeyReq) !CreateApiKeyResp {
	if req.name.len == 0 { return error('name is required') }
	if req.name.len > 255 { return error('name too long, max 255') }

	ak_bytes := crand.bytes(16)!
	sk_bytes := crand.bytes(32)!
	ak := 'ak-${ak_bytes.hex()}'
	sk := 'sk-${sk_bytes.hex()}'

	tenant_ids_json := json.encode(req.tenant_ids)
	subproduct_ids_json := json.encode(req.subproduct_ids)
	subportal_ids_json := json.encode(req.subportal_ids)
	scopes := if req.scopes.len > 0 { req.scopes } else { ['all'] }
	scopes_json := json.encode(scopes)

	mut expired_at := ?time.Time(none)
	if exp_str := req.expired_at {
		expired_at = time.parse_iso8601(exp_str) or { time.now() }
	}

	id := rand.uuid_v4()
	now := time.now()

	rec := IamApiKey{
		id:             id
		user_id:        ctx.svc_iam.user_id
		name:           req.name
		access_key_id:  ak
		key_prefix:     ak[..10]
		key_hash:       sha256.hexhash(sk)
		key_last_four:  sk[sk.len - 4..]
		tenant_ids:     tenant_ids_json
		subproduct_ids: subproduct_ids_json
		subportal_ids:  subportal_ids_json
		scopes:         scopes_json
		status:         0
		expired_at:     expired_at
		creator_id:     ctx.svc_iam.user_id
		created_at:     now
		updater_id:     ctx.svc_iam.user_id
		updated_at:     now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		insert rec into IamApiKey
	}!

	return CreateApiKeyResp{
		id:             id
		name:           req.name
		plain_sk:       sk
		access_key_id:  ak
		key_prefix:     ak[..10]
		key_last_four:  sk[sk.len - 4..]
		tenant_ids:     req.tenant_ids
		subproduct_ids: req.subproduct_ids
		subportal_ids:  req.subportal_ids
		scopes:         if req.scopes.len > 0 { req.scopes } else { ['all'] }
		expired_at:     req.expired_at
		created_at:     now.format_ss()
	}
}

module middleware

import time
import veb
import log
import json2 as json
import structs { Context }
import common.api
import common.jwt
import adapter.repository.middle
import crypto.sha256

fn iam_jwt_verify(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	auth_header := ctx.get_header(.authorization) or { '' }
	if auth_header.len == 0 {
		return reject(mut ctx, api.json_error_401())
	}

	if auth_header.starts_with('AK ') {
		ak := auth_header.all_after('AK ').trim_space()
		if ak.len == 0 { return reject(mut ctx, api.json_error_401()) }
		return authenticate_aksk(mut ctx, ak)
	}

	if auth_header.starts_with('Bearer ') {
		return authenticate_jwt(mut ctx, auth_header.all_after('Bearer').trim_space())
	}

	return reject(mut ctx, api.json_error(
		code:   1
		status: 401
		error:  'Unsupported authentication scheme'
	))
}

fn authenticate_jwt(mut ctx Context, token string) bool {
	secret := ctx.config.jwt.secret
	if !jwt.auth_verify(secret, token) {
		return reject(mut ctx, api.json_error_401())
	}
	payload := jwt.jwt_decode(token) or { return reject(mut ctx, api.json_error_401()) }
	ctx.svc_iam.user_id = payload.sub
	ctx.svc_iam.token_jwt = token
	ctx.svc_iam.iam_role_ids = payload.role_ids
	return true
}

fn authenticate_aksk(mut ctx Context, token string) bool {
	parts := token.split(':')
	if parts.len != 2 { return reject(mut ctx, api.json_error_401()) }
	ak := parts[0].trim_space()
	sk := parts[1].trim_space()
	if ak.len == 0 || sk.len == 0 { return reject(mut ctx, api.json_error_401()) }

	key := middle.find_apikey_by_ak(mut ctx, ak) or { return reject(mut ctx, api.json_error_401()) }

	if sha256.hexhash(sk) != key.key_hash { return reject(mut ctx, api.json_error_401()) }

	if key.status != 0 { return reject(mut ctx, api.json_error_403()) }
	if exp := key.expired_at {
		if time.now() > exp { return reject(mut ctx, api.json_error_403()) }
	}

	tenant_id := ctx.req.header.get_custom('X-Tenant-ID') or { '' }
	subproduct_id := ctx.req.header.get_custom('X-Subproduct-ID') or { '' }
	subportal_id := ctx.req.header.get_custom('X-Subportal-ID') or { '' }

	middle.check_isolation(key, tenant_id, subproduct_id, subportal_id) or {
		return reject(mut ctx, api.json_error(code: 1, status: 403, error: err.msg()))
	}

	ctx.svc_iam.user_id = key.user_id
	ctx.svc_iam.apikey_id = key.id
	ctx.svc_iam.tenant_ids = json.decode[[]string](key.tenant_ids) or { [] }
	ctx.svc_iam.subproduct_ids = json.decode[[]string](key.subproduct_ids) or { [] }
	ctx.svc_iam.subportal_ids = json.decode[[]string](key.subportal_ids) or { [] }
	middle.touch_apikey_last_used(mut ctx, key.id) or { log.warn('touch_apikey_last_used: ${err}') }
	return true
}

fn reject(mut ctx Context, err api.ApiErrorResponse) bool {
	ctx.json(err)
	return false
}

pub fn iam_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: iam_jwt_verify
		after:   false
	}
}

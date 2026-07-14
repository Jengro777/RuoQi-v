module middleware

import time
import veb
import log
import json2 as json
import structs { Context }
import structs.schema_iam { IamApiKey }
import common.api
import common.crypt
import adapter.repository.middle

const sig_skew_seconds = i64(300) // ±5 分钟时间戳偏差

// iam_auth_dispatch — 鉴权入口，按请求头分流到对应策略：
//   Bearer <token>                → JWT
//   X-Access-Key + X-Timestamp + X-Signature → AK/SK HMAC 签名模式
fn iam_auth_dispatch(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	auth_header := ctx.get_header(.authorization) or { '' }

	// Bearer token → JWT
	if auth_header.starts_with('Bearer ') {
		return authenticate_jwt(mut ctx, auth_header.all_after('Bearer ').trim_space())
	}

	// X-Access-Key → HMAC 签名模式
	access_key := ctx.req.header.get_custom(crypt.sig_header_access_key) or { '' }
	if access_key.len > 0 {
		return authenticate_aksk_signature(mut ctx, access_key)
	}

	return reject(mut ctx, api.json_error_401())
}

fn authenticate_jwt(mut ctx Context, token string) bool {
	secret := ctx.config.jwt.secret
	if !crypt.auth_verify(secret, token) {
		return reject(mut ctx, api.json_error_401())
	}
	payload := crypt.auth_decode(token) or { return reject(mut ctx, api.json_error_401()) }
	ctx.svc_iam.user_id = payload.sub
	ctx.svc_iam.token_jwt = token
	ctx.svc_iam.iam_role_ids = payload.role_ids
	return true
}

// authenticate_aksk_signature — HMAC 签名模式: X-Access-Key + X-Timestamp + X-Signature
fn authenticate_aksk_signature(mut ctx Context, ak string) bool {
	key := middle.find_apikey_by_ak(mut ctx, ak) or { return reject(mut ctx, api.json_error_401()) }

	timestamp := ctx.req.header.get_custom(crypt.sig_header_timestamp) or { '' }
	sig := ctx.req.header.get_custom(crypt.sig_header_signature) or { '' }
	if timestamp == '' || sig == '' {
		return reject(mut ctx, api.json_error(
			code:   1
			status: 401
			error:  'Missing X-Timestamp or X-Signature header'
		))
	}

	master_key := ctx.config.jwt.effective_master_key()
	sk := crypt.aes_decrypt(key.secret_key_cipher, master_key) or {
		log.warn('aes_decrypt failed for apikey ${key.id}: ${err}')
		return reject(mut ctx, api.json_error_401())
	}

	path := ctx.req.url.all_before('?')
	crypt.verify_apisign(sk, ctx.req.method.str(), path, ctx.req.data, timestamp, sig,
		sig_skew_seconds) or {
		return reject(mut ctx, api.json_error(
			code:   1
			status: 401
			error:  err.msg()
		))
	}

	return populate_aksk_context(mut ctx, key)
}

// populate_aksk_context — 公有逻辑：校验状态/过期/隔离/scope，写入上下文
fn populate_aksk_context(mut ctx Context, key IamApiKey) bool {
	if key.status != 0 {
		return reject(mut ctx, api.json_error_403())
	}
	if exp := key.expired_at {
		if time.now() > exp {
			return reject(mut ctx, api.json_error_403())
		}
	}

	tenant_id := ctx.req.header.get_custom('X-Tenant-ID') or { '' }
	subproduct_id := ctx.req.header.get_custom('X-Subproduct-ID') or { '' }
	subportal_id := ctx.req.header.get_custom('X-Subportal-ID') or { '' }

	middle.check_isolation(key, tenant_id, subproduct_id, subportal_id) or {
		return reject(mut ctx, api.json_error(code: 1, status: 403, error: err.msg()))
	}

	middle.check_scopes(key, ctx.req.method.str(), ctx.req.url) or {
		return reject(mut ctx, api.json_error(code: 1, status: 403, error: err.msg()))
	}

	ctx.svc_iam.user_id = key.user_id
	ctx.svc_iam.apikey_id = key.id
	ctx.svc_iam.tenant_ids = json.decode[[]string](key.tenant_ids) or { [] }
	ctx.svc_iam.subproduct_ids = json.decode[[]string](key.subproduct_ids) or { [] }
	ctx.svc_iam.subportal_ids = json.decode[[]string](key.subportal_ids) or { [] }
	ctx.svc_iam.active_tenant_id = tenant_id
	ctx.svc_iam.active_subproduct_id = subproduct_id
	ctx.svc_iam.active_subportal_id = subportal_id
	middle.touch_apikey_last_used(mut ctx, key.id) or { log.warn('touch_apikey_last_used: ${err}') }
	return true
}

fn reject(mut ctx Context, err api.ApiErrorResponse) bool {
	ctx.json(err)
	return false
}

pub fn iam_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: iam_auth_dispatch
		after:   false
	}
}

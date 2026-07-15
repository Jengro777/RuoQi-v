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

// ═══════════════════════════════════════════════════════════════════════════════
// 鉴权入口 — 按请求头分流
// ═══════════════════════════════════════════════════════════════════════════════

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

	ctx.json(api.json_error_401())
	return false
}

// ═══════════════════════════════════════════════════════════════════════════════
// JWT 鉴权路径
//   身份: JWT 验签 (crypt.auth_verify)
//   权限: IamToken → IamUserRole → WsRoleApi → PfApi → scope 匹配
//   数据隔离: datascope (SQL WHERE 行级过滤)
// ═══════════════════════════════════════════════════════════════════════════════

fn authenticate_jwt(mut ctx Context, token string) bool {
	secret := ctx.config.jwt.secret
	if !crypt.auth_verify(secret, token) {
		ctx.json(api.json_error_401())
		return false
	}
	payload := crypt.auth_decode(token) or {
		ctx.json(api.json_error_401())
		return false
	}
	ctx.svc_iam.user_id = payload.sub
	ctx.svc_iam.token_jwt = token
	ctx.svc_iam.iam_role_ids = payload.role_ids

	// API 权限校验（JWT / Core 路径）
	// root 用户（* 角色）跳过权限校验；其余查 ws_role_api + pf_api
	if !payload.role_ids.contains('*') {
		scopes := middle.find_user_apis_by_token(mut ctx, token) or {
			log.warn('find_user_apis_by_token failed: ${err}')
			ctx.json(api.json_error_403())
			return false
		}
		check_scopes(scopes, ctx.req.method.str(), ctx.req.url) or {
			ctx.json(api.json_error(code: 1, status: 403, error: err.msg()))
			return false
		}
	}

	return true
}

// ═══════════════════════════════════════════════════════════════════════════════
// AK/SK 鉴权路径
//   身份: HMAC 签名 (X-Access-Key + X-Timestamp + X-Signature)
//   权限: IamApiKey.scopes JSON → scope 匹配
//   数据隔离: check_isolation (租户/产品/门户) + datascope
// ═══════════════════════════════════════════════════════════════════════════════

// authenticate_aksk_signature — HMAC 签名模式: X-Access-Key + X-Timestamp + X-Signature
fn authenticate_aksk_signature(mut ctx Context, ak string) bool {
	key := middle.find_apis_by_aksk(mut ctx, ak) or {
		ctx.json(api.json_error_401())
		return false
	}

	timestamp := ctx.req.header.get_custom(crypt.sig_header_timestamp) or { '' }
	sig := ctx.req.header.get_custom(crypt.sig_header_signature) or { '' }
	if timestamp == '' || sig == '' {
		ctx.json(api.json_error(
			code:   1
			status: 401
			error:  'Missing X-Timestamp or X-Signature header'
		))
		return false
	}

	master_key := ctx.config.jwt.effective_master_key()
	sk := crypt.aes_decrypt(key.secret_key_cipher, master_key) or {
		log.warn('aes_decrypt failed for apikey ${key.id}: ${err}')
		ctx.json(api.json_error_401())
		return false
	}

	path := ctx.req.url.all_before('?')
	crypt.verify_apisign(sk, ctx.req.method.str(), path, ctx.req.data, timestamp, sig,
		sig_skew_seconds) or {
		ctx.json(api.json_error(
			code:   1
			status: 401
			error:  err.msg()
		))
		return false
	}

	return populate_aksk_context(mut ctx, key)
}

// populate_aksk_context — 公有逻辑：校验状态/过期/隔离/scope，写入上下文
fn populate_aksk_context(mut ctx Context, key IamApiKey) bool {
	if key.status != 0 {
		ctx.json(api.json_error_403())
		return false
	}
	if exp := key.expired_at {
		if time.now() > exp {
			ctx.json(api.json_error_403())
			return false
		}
	}

	tenant_id := ctx.req.header.get_custom('X-Tenant-ID') or { '' }
	subproduct_id := ctx.req.header.get_custom('X-Subproduct-ID') or { '' }
	subportal_id := ctx.req.header.get_custom('X-Subportal-ID') or { '' }

	check_isolation(key, tenant_id, subproduct_id, subportal_id) or {
		ctx.json(api.json_error(code: 1, status: 403, error: err.msg()))
		return false
	}

	scopes := json.decode[[]string](key.scopes) or {
		ctx.json(api.json_error(code: 1, status: 403, error: 'invalid scopes JSON'))
		return false
	}
	check_scopes(scopes, ctx.req.method.str(), ctx.req.url) or {
		ctx.json(api.json_error(code: 1, status: 403, error: err.msg()))
		return false
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

// check_isolation — AK/SK 专用: 校验 API Key 的租户/产品/门户隔离白名单
fn check_isolation(key IamApiKey, tenant_id string, subproduct_id string, subportal_id string) ! {
	if key.tenant_ids == '[]' && key.subproduct_ids == '[]' && key.subportal_ids == '[]' { return }
	if key.tenant_ids != '[]' {
		allowed := json.decode[[]string](key.tenant_ids) or { return error('invalid tenant_ids') }
		if tenant_id == '' { return error('X-Tenant-ID is required') }
		if !allowed.contains(tenant_id) { return error('tenant not allowed') }
	}
	if key.subproduct_ids != '[]' {
		allowed := json.decode[[]string](key.subproduct_ids) or {
			return error('invalid subproduct_ids')
		}
		if subproduct_id == '' { return error('X-Subproduct-ID is required') }
		if !allowed.contains(subproduct_id) { return error('subproduct not allowed') }
	}
	if key.subportal_ids != '[]' {
		allowed := json.decode[[]string](key.subportal_ids) or {
			return error('invalid subportal_ids')
		}
		if subportal_id == '' { return error('X-Subportal-ID is required') }
		if !allowed.contains(subportal_id) { return error('subportal not allowed') }
	}
}

// ═══════════════════════════════════════════════════════════════════════════════
// 共享鉴权逻辑 — JWT / AK/SK 两条路径共用
// ═══════════════════════════════════════════════════════════════════════════════

// check_scopes 校验请求的 method+url 是否在允许的 scope 列表中
// scopes 格式: []string
//   ["all"]              — 不限 API（显式通配，默认值）
//   []                   — 无任何 API 权限
//   ["/iam/user"]        — 路径前缀匹配（如 /iam/user/list、/iam/user/create 均命中）
//   ["POST:/iam/user"]   — 方法+路径前缀匹配（仅 POST 请求命中）
fn check_scopes(allowed_scopes []string, method string, url string) ! {
	// ["all"] 表示不限制 API；空数组 = 无权限
	if allowed_scopes.contains('all') { return }
	if allowed_scopes.len == 0 {
		return error('scope not allowed: empty scopes, ${method} ${url}')
	}
	// 逐个 scope 进行匹配
	for s in allowed_scopes {
		if scope_match(s, method, url) { return }
	}
	return error('scope not allowed: ${method} ${url}')
}

fn scope_match(scope string, method string, url string) bool {
	mut pattern := scope
	mut required_method := ''

	// 解析 "METHOD:path" 格式
	if pattern.contains(':') {
		parts := pattern.split_nth(':', 1)
		method_part := parts[0].to_upper()
		// 全字母 = HTTP 方法（GET/POST/PUT/DELETE/PATCH 等）
		if method_part.bytes().all(it.is_letter()) {
			required_method = method_part
			pattern = parts[1]
		}
	}

	// 如果 scope 指定了方法，方法必须匹配
	if required_method != '' && method.to_upper() != required_method {
		return false
	}

	// 路径前缀匹配
	return url.starts_with(pattern)
}

pub fn iam_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: iam_auth_dispatch
		after:   false
	}
}

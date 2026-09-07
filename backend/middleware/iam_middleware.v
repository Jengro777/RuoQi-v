module middleware

import time
import veb
import log
import json2 as json
import model { Context }
import model.schema_iam { IamApiKey }
import model.schema_tenant { TnMember }
import common.api
import common.crypt
import adapter.repository.middle

const sig_skew_seconds = i64(300) // ±5 分钟时间戳偏差

// Debug 硬编码 AK/SK — 拥有全部权限，跳过数据库查询和 scope/isolation 校验
// 仅在 debug 编译 AND 环境变量 IAM_DEBUG=1 时才启用
// v -prod 生产构建自动排除所有 debug 代码
$if debug {
	const debug_ak = 'DEBUG-FULL-ACCESS-KEY'
	const debug_sk = 'DEBUG-FULL-SECRET-KEY'
}

// iam_auth_scoped — 身份认证 + 租户成员校验 + datascope 隔离
// 用于：会员端、顾客端等需要租户数据隔离但不需要 workspace 权限的端点
//   Bearer token → JWT 验证身份 → 校验 tn_member (X-Tenant-ID) → 写入 scope_sc
//   X-Access-Key → HMAC 签名模式（AK/SK 自带 scope + 隔离）
fn iam_auth_scoped(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	auth_header := ctx.get_header(.authorization) or { '' }

	// Bearer token → JWT（验证身份 + 租户成员校验）
	if auth_header.starts_with('Bearer ') {
		token := auth_header.all_after('Bearer ').trim_space()
		return authenticate_jwt_identity(mut ctx, token) && authorize_tenant_membership(mut ctx)
	}

	// X-Access-Key → HMAC 签名模式（AK/SK 自带 scope + 隔离）
	access_key := ctx.req.header.get_custom(crypt.sig_header_access_key) or { '' }
	if access_key.len > 0 {
		return authenticate_aksk_signature(mut ctx, access_key)
	}

	ctx.json(api.json_error_401())
	return false
}

// ═══════════════════════════════════════════════════════════════════════════════
// 鉴权调度入口 — 按请求头分流到对应策略：
//   Bearer <token>                → JWT
//   X-Access-Key + X-Timestamp + X-Signature → AK/SK HMAC 签名模式
// ═══════════════════════════════════════════════════════════════════════════════

// iam_auth_identity — 仅身份认证，不检查 workspace 业务权限
// 用于：个人资料、Token 管理等"已登录即可"的自服务端点
fn iam_auth_identity(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	auth_header := ctx.get_header(.authorization) or { '' }

	// Bearer token → JWT（仅验证身份）
	if auth_header.starts_with('Bearer ') {
		return authenticate_jwt_identity(mut ctx, auth_header.all_after('Bearer ').trim_space())
	}

	// X-Access-Key → HMAC 签名模式（AK/SK 自带 scope 校验）
	access_key := ctx.req.header.get_custom(crypt.sig_header_access_key) or { '' }
	if access_key.len > 0 {
		return authenticate_aksk_signature(mut ctx, access_key)
	}

	ctx.json(api.json_error_401())
	return false
}

// iam_auth_full — 身份认证 + workspace 业务权限校验
// 用于：用户管理、工作区管理等需要 workspace 权限的端点
fn iam_auth_full(mut ctx Context) bool {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	auth_header := ctx.get_header(.authorization) or { '' }

	// Bearer token → JWT（验证身份 + workspace 权限）
	if auth_header.starts_with('Bearer ') {
		token := auth_header.all_after('Bearer ').trim_space()
		return authenticate_jwt_identity(mut ctx, token)
			&& authorize_workspace_permission(mut ctx, token)
	}

	// X-Access-Key → HMAC 签名模式（AK/SK 自带 scope 校验）
	access_key := ctx.req.header.get_custom(crypt.sig_header_access_key) or { '' }
	if access_key.len > 0 {
		return authenticate_aksk_signature(mut ctx, access_key)
	}

	ctx.json(api.json_error_401())
	return false
}

// ═══════════════════════════════════════════════════════════════════════════════
// JWT 鉴权 — 身份验证层
//   仅验证 JWT 签名并提取 user_id，不检查业务权限
// ═══════════════════════════════════════════════════════════════════════════════

fn authenticate_jwt_identity(mut ctx Context, token string) bool {
	secret := ctx.config.crypt.jwt_secret
	payload := crypt.verify_and_decode[crypt.AuthPayload](secret, token) or {
		ctx.json(api.json_error_401())
		return false
	}
	ctx.svc_iam.user_id = payload.sub
	ctx.svc_iam.token_jwt = token
	return true
}

// ═══════════════════════════════════════════════════════════════════════════════
// JWT 鉴权 — workspace 权限校验层
//   查询链: IamToken → WsMemberRole → WsRoleApi → PfApi → scope 匹配
//   数据隔离: datascope (SQL WHERE 行级过滤)
// ═══════════════════════════════════════════════════════════════════════════════

fn authorize_workspace_permission(mut ctx Context, token string) bool {
	scopes := middle.find_user_apis_by_token(mut ctx, token) or {
		log.warn('find_user_apis_by_token failed: ${err}')
		ctx.json(api.json_error_403())
		return false
	}
	check_scopes(scopes, ctx.req.method.str(), ctx.req.url.all_before('?')) or {
		ctx.json(api.json_error(code: 1, status: 403, error: err.msg()))
		return false
	}
	return true
}

// ═══════════════════════════════════════════════════════════════════════════════
// JWT 鉴权 — 租户成员校验层
//   查询 tn_member 确认用户已入驻 X-Tenant-ID + X-Product-ID + X-Portal-ID 组合
//   每个门户有独立的注册/授权流程，入驻后才可访问
//   写入 scope_sc 用于 datascope，不检查 workspace 角色
//   适用于会员/顾客等非管理员用户
// ═══════════════════════════════════════════════════════════════════════════════

fn authorize_tenant_membership(mut ctx Context) bool {
	tenant_id := ctx.req.header.get_custom('X-Tenant-ID') or { '' }
	product_id := ctx.req.header.get_custom('X-Product-ID') or { '' }
	portal_id := ctx.req.header.get_custom('X-Portal-ID') or { '' }
	if tenant_id == '' || product_id == '' || portal_id == '' {
		ctx.json(api.json_error(
			code: 1
			status: 400
			error: 'X-Tenant-ID, X-Product-ID and X-Portal-ID are required'
		))
		return false
	}

	db, conn := ctx.dbpool.acquire() or {
		ctx.json(api.json_error_500('Failed to acquire DB conn'))
		return false
	}
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	members := sql db {
		select from TnMember where tenant_id == tenant_id && user_id == ctx.svc_iam.user_id
		&& product_id == product_id && portal_id == portal_id && status == 1 && del_flag == 0 limit 1
	} or {
		ctx.json(api.json_error_403())
		return false
	}
	if members.len == 0 {
		ctx.json(api.json_error(
			code: 1
			status: 403
			error: 'user not a member of this tenant/product/portal'
		))
		return false
	}

	// 写入 scope_sc 和 svc_iam，datascope 中间件将按 tenant_id 过滤数据
	ctx.scope_sc.tenant_id = tenant_id
	ctx.svc_iam.active_tenant_id = tenant_id
	ctx.svc_iam.active_subproduct_id = product_id
	ctx.svc_iam.active_subportal_id = portal_id
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
	// Debug 硬编码 AK — 仅 debug 编译时可用，-prod 构建自动排除
	$if debug {
		if ak == debug_ak {
			return authenticate_debug_aksk(mut ctx)
		}
	}

	timestamp := ctx.req.header.get_custom(crypt.sig_header_timestamp) or { '' }
	sig := ctx.req.header.get_custom(crypt.sig_header_signature) or { '' }
	if timestamp == '' || sig == '' {
		ctx.json(api.json_error(
			code: 1
			status: 401
			error: 'Missing X-Timestamp or X-Signature header'
		))
		return false
	}

	key := middle.find_apis_by_aksk(mut ctx, ak) or { return reject(mut ctx, api.json_error_401()) }

	aksk_encrypt := ctx.config.crypt.effective_aksk_encrypt()
	sk := crypt.aes_decrypt(key.secret_key_cipher, aksk_encrypt) or {
		log.warn('aes_decrypt failed for apikey ${key.id}: ${err}')
		ctx.json(api.json_error_401())
		return false
	}

	path := ctx.req.url.all_before('?')
	crypt.verify_apisign(sk, ctx.req.method.str(), path, ctx.req.data, timestamp, sig, sig_skew_seconds) or {
		ctx.json(api.json_error(
			code: 1
			status: 401
			error: err.msg()
		))
		return false
	}

	return populate_aksk_context(mut ctx, key)
}

// populate_aksk_context — 公有逻辑：校验状态/过期/隔离/scope，写入上下文
fn populate_aksk_context(mut ctx Context, key IamApiKey) bool {
	if key.status != 1 {
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

	// 解析隔离白名单（一次解码，check_isolation + ctx 写入共用）
	// 解码失败必须拒绝请求，不能静默回退为空（否则 JSON 损坏会导致隔离绕过）
	tenants := json.decode[[]string](key.tenant_ids) or {
		log.warn('invalid tenant_ids JSON for apikey ${key.id}: ${err}')
		ctx.json(api.json_error(code: 1, status: 403, error: 'invalid tenant_ids'))
		return false
	}
	subproducts := json.decode[[]string](key.subproduct_ids) or {
		log.warn('invalid subproduct_ids JSON for apikey ${key.id}: ${err}')
		ctx.json(api.json_error(code: 1, status: 403, error: 'invalid subproduct_ids'))
		return false
	}
	subportals := json.decode[[]string](key.subportal_ids) or {
		log.warn('invalid subportal_ids JSON for apikey ${key.id}: ${err}')
		ctx.json(api.json_error(code: 1, status: 403, error: 'invalid subportal_ids'))
		return false
	}

	check_isolation(tenants, subproducts, subportals, tenant_id, subproduct_id, subportal_id) or {
		ctx.json(api.json_error(code: 1, status: 403, error: err.msg()))
		return false
	}

	scopes := json.decode[[]string](key.scopes) or {
		ctx.json(api.json_error(code: 1, status: 403, error: 'invalid scopes JSON'))
		return false
	}
	check_scopes(scopes, ctx.req.method.str(), ctx.req.url.all_before('?')) or {
		ctx.json(api.json_error(code: 1, status: 403, error: err.msg()))
		return false
	}

	ctx.svc_iam.user_id = key.user_id
	ctx.svc_iam.apikey_id = key.id
	ctx.svc_iam.tenant_ids = tenants
	ctx.svc_iam.subproduct_ids = subproducts
	ctx.svc_iam.subportal_ids = subportals
	ctx.svc_iam.active_tenant_id = tenant_id
	ctx.svc_iam.active_subproduct_id = subproduct_id
	ctx.svc_iam.active_subportal_id = subportal_id
	middle.touch_apikey_last_used(mut ctx, key.id) or { log.warn('touch_apikey_last_used: ${err}') }
	return true
}

// check_isolation — AK/SK 专用: 校验 API Key 的租户/产品/门户隔离白名单
// tenants/subproducts/subportals 应由调用方预先从 JSON 解码，解码失败视为空（无隔离限制）
fn check_isolation(tenants []string, subproducts []string, subportals []string, tenant_id string, subproduct_id string, subportal_id string) ! {
	if tenants.len == 0 && subproducts.len == 0 && subportals.len == 0 {
		return
	}

	if tenants.len > 0 {
		if tenant_id == '' {
			return error('X-Tenant-ID is required')
		}
		if !tenants.contains(tenant_id) {
			return error('tenant not allowed')
		}
	}
	if subproducts.len > 0 {
		if subproduct_id == '' {
			return error('X-Subproduct-ID is required')
		}
		if !subproducts.contains(subproduct_id) {
			return error('subproduct not allowed')
		}
	}
	if subportals.len > 0 {
		if subportal_id == '' {
			return error('X-Subportal-ID is required')
		}
		if !subportals.contains(subportal_id) {
			return error('subportal not allowed')
		}
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
	if allowed_scopes.contains('all') {
		return
	}
	if allowed_scopes.len == 0 {
		return error('scope not allowed: empty scopes, ${method} ${url}')
	}
	// 逐个 scope 进行匹配
	for s in allowed_scopes {
		if scope_match(s, method, url) {
			return
		}
	}
	return error('scope not allowed: ${method} ${url}')
}

fn scope_match(scope string, method string, url string) bool {
	// 拒绝空 scope（空字符串会通配所有 URL）
	if scope == '' {
		return false
	}

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
			// 拒绝空路径（如 "POST:" 会通配所有 POST 请求）
			if pattern == '' {
				return false
			}
		}
	}

	// 如果 scope 指定了方法，方法必须匹配
	if required_method != '' && method.to_upper() != required_method {
		return false
	}

	// 路径前缀匹配 — 必须匹配到路径段边界，防止 /user 匹配 /user-mgmt
	// 规范化：去除尾部斜杠，确保前缀匹配不受尾部斜杠影响
	pattern = pattern.trim_string_right('/')
	return url.starts_with(pattern + '/') || url == pattern
}

// authenticate_debug_aksk — 调试用硬编码 AK/SK 认证，拥有全部权限（仅 debug 模式编译）
$if debug {
	fn authenticate_debug_aksk(mut ctx Context) bool {
		timestamp := ctx.req.header.get_custom(crypt.sig_header_timestamp) or { '' }
		sig := ctx.req.header.get_custom(crypt.sig_header_signature) or { '' }
		if timestamp == '' || sig == '' {
			return reject(mut ctx, api.json_error(
				code: 1
				status: 401
				error: 'Missing X-Timestamp or X-Signature header'
			))
		}

		path := ctx.req.url.all_before('?')
		crypt.verify_apisign(debug_sk, ctx.req.method.str(), path, ctx.req.data, timestamp, sig, sig_skew_seconds) or {
			return reject(mut ctx, api.json_error(
				code: 1
				status: 401
				error: err.msg()
			))
		}

		// 赋予全部权限 — tenant_ids/subproduct_ids/subportal_ids 为空表示不限隔离
		ctx.svc_iam.user_id = 'debug-admin'
		ctx.svc_iam.apikey_id = 'debug-apikey-id'
		ctx.svc_iam.tenant_ids = []
		ctx.svc_iam.subproduct_ids = []
		ctx.svc_iam.subportal_ids = []
		return true
	}
}

fn reject(mut ctx Context, err api.ApiErrorResponse) bool {
	ctx.json(err)
	return false
}

// iam_identity_middleware — 仅验证 JWT/AK/SK 身份，不检查 workspace 业务权限
// 用于：个人资料、Token 管理、等"已登录即可"的自服务端点
pub fn iam_identity_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: iam_auth_identity
		after: false
	}
}

// iam_full_middleware — 身份认证 + workspace 业务权限校验
// 用于：用户管理、工作区管理等需要 workspace 权限的管理端点
pub fn iam_full_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: iam_auth_full
		after: false
	}
}

// iam_scoped_middleware — 身份认证 + 租户成员校验 + datascope 隔离
// 用于：会员端、顾客端等需要租户数据隔离但不需要 workspace 权限的端点
pub fn iam_scoped_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: iam_auth_scoped
		after: false
	}
}

// iam_middleware — 兼容别名，等同 iam_full_middleware
@[deprecated]
pub fn iam_middleware() veb.MiddlewareOptions[Context] {
	return iam_full_middleware()
}

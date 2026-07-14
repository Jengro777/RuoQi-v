module middle

import time
import log
import json2 as json
import structs { Context }
import structs.schema_iam { IamApiKey }

pub fn find_apikey_by_ak(mut ctx Context, ak string) !IamApiKey {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	keys := sql db {
		select from IamApiKey where access_key_id == ak limit 1
	}!
	if keys.len != 1 { return error('Access Key ID not found') }
	return keys[0]
}

pub fn touch_apikey_last_used(mut ctx Context, apikey_id string) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamApiKey set last_used_at = time.now() where id == apikey_id
	}!
}

// check_scopes 校验 API Key 的权限范围是否覆盖当前请求
// scopes 格式: JSON 字符串数组
//   ["all"]              — 不限 API（显式通配，默认值）
//   ["/iam/user"]        — 路径前缀匹配（如 /iam/user/list、/iam/user/create 均命中）
//   ["POST:/iam/user"]   — 方法+路径前缀匹配（仅 POST 请求命中）
pub fn check_scopes(key IamApiKey, method string, url string) ! {
	scopes := json.decode[[]string](key.scopes) or { return error('invalid scopes JSON') }

	// 空数组或 ["all"] 均表示不限制 API
	if scopes.len == 0 || scopes.contains('all') { return }
	// 逐个 scope 进行匹配
	for s in scopes {
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

pub fn check_isolation(key IamApiKey, tenant_id string, subproduct_id string, subportal_id string) ! {
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

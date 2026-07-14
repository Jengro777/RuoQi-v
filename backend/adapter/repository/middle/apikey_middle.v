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

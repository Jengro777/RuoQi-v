module middle

import time
import log
import json2 as json
import structs { Context }
import structs.schema_iam { IamApiKey }

pub fn find_apis_by_aksk(mut ctx Context, ak string) !IamApiKey {
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

// find_user_apis_by_ak 根据 Access Key 查询用户可访问的 API 权限列表（AK/SK 路径）
pub fn find_user_apis_by_ak(mut ctx Context, ak string) ![]string {
	key := find_apis_by_aksk(mut ctx, ak)!
	return json.decode[[]string](key.scopes) or { return error('invalid scopes JSON') }
}

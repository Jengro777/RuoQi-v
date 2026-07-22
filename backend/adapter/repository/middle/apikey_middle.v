module middle

import time
import log
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

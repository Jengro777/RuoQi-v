module apikey

import veb
import log
import json2 as json
import model { Context }
import common.api
import model.schema_iam { IamApiKey }

pub struct DeleteApiKeyReq {
	id string @[json: 'id']
}

@['/delete'; post]
pub fn (app &ApiKey) delete_apikey_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[DeleteApiKeyReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}
	result := delete_apikey_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(code: api.err_common_server, msg: '${err}'))
	}
	return ctx.json(api.json_success(data: result))
}

fn delete_apikey_usecase(mut ctx Context, req DeleteApiKeyReq) !map[string]string {
	if req.id.len == 0 {
		return error('id is required')
	}
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	sql db {
		update IamApiKey set status = 2 where id == req.id && user_id == ctx.svc_iam.user_id
	}!
	return {
		'msg': 'API Key deleted successfully'
		'id':  req.id
	}
}

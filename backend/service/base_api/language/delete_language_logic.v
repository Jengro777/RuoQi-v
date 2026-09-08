module language

import time
import veb
import log
import json2 as json
import model.schema_base { BaseLanguage }
import common.api
import model { Context }

// ═══ Handler ═══
@['/delete'; post]
pub fn (app &Language) delete_language_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteLanguageReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	// Usecase 执行
	result := delete_language_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn delete_language_usecase(mut ctx Context, req DeleteLanguageReq) !DeleteLanguageResp {
	// Domain 校验
	delete_language_domain(req)!

	// Repository 执行删除
	return delete_language_repo(mut ctx, req.language_ids)
}

// ═══ Domain ═══
fn delete_language_domain(req DeleteLanguageReq) ! {
	if req.language_ids.len == 0 {
		return error('No Language ids provided')
	}
}

// ═══ DTO ═══
pub struct DeleteLanguageReq {
	language_ids []string @[json: 'ids']
}

pub struct DeleteLanguageResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn delete_language_repo(mut ctx Context, language_ids []string) !DeleteLanguageResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	sql db {
		update BaseLanguage set del_flag = -1, updated_at = time.now(), updater_id = ctx.svc_iam.user_id
		where id in language_ids && del_flag == 0
	} or { return error('Failed to soft-delete language: ${err}') }

	return DeleteLanguageResp{
		msg: '${language_ids} language(s) deleted successfully'
	}
}

module language

import veb
import log
import time
import json2 as json
import model.schema_base { BaseLanguage }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Language) update_language_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateLanguageReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_language_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_language_usecase(mut ctx Context, req UpdateLanguageReq) !UpdateLanguageResp {
	// Domain 校验
	update_language_domain(req)!

	// Repository 更新
	return update_language_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_language_domain(req UpdateLanguageReq) ! {
	if req.id == '' {
		return error('language id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateLanguageReq {
	id                       string @[json: 'id']
	language_self_proclaimed ?string @[json: 'languageSelfProclaimed']
	language_code            ?string @[json: 'languageCode']
	two_letter_code          ?string @[json: 'twoLetterCode']
	three_letter_code        ?string @[json: 'threeLetterCode']
	utf8_encoding            ?string @[json: 'utf8Encoding']
	sort                     ?int @[json: 'sort']
	status                   ?u8 @[json: 'status']
	is_basic                 ?u8 @[json: 'isBasic']
}

pub struct UpdateLanguageResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_language_repo(mut ctx Context, req UpdateLanguageReq) !UpdateLanguageResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr :=
		sql {
		}

	sql db {
		dynamic update BaseLanguage set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateLanguageResp{
		msg: 'language updated successfully'
	}
}

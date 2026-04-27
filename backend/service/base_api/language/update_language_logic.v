module language

import veb
import log
import time
import x.json2 as json
import structs.schema_base { BaseLanguage }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &Language) update_language_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateLanguageReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_language_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_language_usecase(mut ctx Context, req UpdateLanguageReq) !UpdateLanguageResp {
	// Domain 校验
	update_language_domain(req)!

	// Repository 更新
	return update_language(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_language_domain(req UpdateLanguageReq) ! {
	if req.id == '' {
		return error('language id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateLanguageReq {
	id                       string  @[json: 'id']
	language_self_proclaimed ?string @[json: 'languageSelfProclaimed']
	language_code            ?string @[json: 'languageCode']
	two_letter_code          ?string @[json: 'twoLetterCode']
	three_letter_code        ?string @[json: 'threeLetterCode']
	utf8_encoding            ?string @[json: 'utf8Encoding']
	sort                     ?int    @[json: 'sort']
	status                   ?u8     @[json: 'status']
	is_basic                 ?u8     @[json: 'isBasic']
}

pub struct UpdateLanguageResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn update_language(mut ctx Context, req UpdateLanguageReq) !UpdateLanguageResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if language_self_proclaimed := req.language_self_proclaimed {
			language_self_proclaimed == language_self_proclaimed
		},
		if language_code := req.language_code { language_code == language_code },
		if two_letter_code := req.two_letter_code { two_letter_code == two_letter_code },
		if three_letter_code := req.three_letter_code { three_letter_code == three_letter_code },
		if utf8_encoding := req.utf8_encoding { utf8_encoding == utf8_encoding },
		if is_basic := req.is_basic { is_basic == is_basic },
		if sort := req.sort { sort == sort },
		if status := req.status { status == status },
		updated_at == time.now()
	}

	sql db {
		dynamic update BaseLanguage set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateLanguageResp{
		msg: 'language updated successfully'
	}
}

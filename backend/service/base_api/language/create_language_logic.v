module language

import veb
import log
import time
import rand
import json2 as json
import structs.schema_base { BaseLanguage }
import common.api
import structs { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &Language) create_language_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateLanguageReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_language_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_language_usecase(mut ctx Context, req CreateLanguageReq) !CreateLanguageResp {
	// create_language_domain(req)!
	return create_language_repo(mut ctx, req)
}

// ═══ Domain ═══
// fn create_language_domain(req CreateLanguageReq) ! {
// if req.path == '' {
// 	return error('path is required')
// }
// if req.method == '' {
// 	return error('method is required')
// }
// if req.service_name == '' {
// 	return error('service_name is required')
// }
// }

// ═══ DTO ═══
pub struct CreateLanguageReq {
	language_self_proclaimed string @[json: 'languageSelfProclaimed']
	language_code            string @[json: 'languageCode']
	two_letter_code          string @[json: 'twoLetterCode']
	three_letter_code        string @[json: 'threeLetterCode']
	utf8_encoding            string @[json: 'utf8Encoding']
	sort                     ?int   @[json: 'sort']
	status                   u8     @[json: 'status']
	is_basic                 u8     @[json: 'isBasic']
}

pub struct CreateLanguageResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_language_repo(mut ctx Context, req CreateLanguageReq) !CreateLanguageResp {
	time_now := time.now()
	base_language := BaseLanguage{
		id:                       rand.uuid_v7()
		language_self_proclaimed: req.language_self_proclaimed
		language_code:            req.language_code
		two_letter_code:          req.two_letter_code
		three_letter_code:        req.three_letter_code
		utf8_encoding:            req.utf8_encoding
		sort:                     req.sort
		status:                   req.status
		is_basic:                 req.is_basic
		created_at:               time_now
		updated_at:               time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_language into BaseLanguage
	} or { return error('Failed to create Currency: ${err}') }

	return CreateLanguageResp{
		msg: 'Language created successfully'
	}
}

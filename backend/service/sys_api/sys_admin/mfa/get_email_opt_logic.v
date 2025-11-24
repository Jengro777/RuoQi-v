module mfa

import veb
import log
import x.json2 as json
import structs { Context }
import regex
import common.api
import common.opt

// ----------------- Handler 层 -----------------
@['/login_by_email'; post]
pub fn (app &MFA) mfa_email_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[EmailLoginReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := email_login_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn email_login_usecase(mut ctx Context, req EmailLoginReq) !EmailLoginResp {
	// Domain 参数校验
	email_login_domain(req)!

	// Repository 层生成 OTP
	return email_login(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn email_login_domain(req EmailLoginReq) ! {
	if req.email == '' {
		return error('email is required')
	}
	if !email_re.matches_string(req.email) {
		return error('invalid email format')
	}
}

// ----------------- DTO 层 -----------------
pub struct EmailLoginReq {
	email string @[json: 'email']
}

pub struct EmailLoginResp {
	code      string @[json: 'code']
	token_opt string @[json: 'token_opt']
	msg       string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
const email_re = regex.regex_opt(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') or {
	panic('Invalid email regex pattern')
}

fn email_login(mut ctx Context, req EmailLoginReq) !EmailLoginResp {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	token_opt, opt_num := opt.opt_generate()

	// 未来可以在这里插入 DB 日志
	/*
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}
	*/

	return EmailLoginResp{
		code:      opt_num
		token_opt: token_opt
		msg:       'OTP generated successfully'
	}
}

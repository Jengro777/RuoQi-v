module mfa

import veb
import log
import x.json2 as json
import regex
import common.jwt
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/login_by_sms'; post]
pub fn (app &MFA) find_sms_opt_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[SmsLoginReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_sms_opt_usecase(req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn find_sms_opt_usecase(req SmsLoginReq) !SmsLoginResp {
	// Domain 校验
	find_sms_opt_domain(req)!

	// Repository / 核心逻辑
	return find_sms_opt_repo()
}

// ----------------- Domain 层 -----------------
fn find_sms_opt_domain(req SmsLoginReq) ! {
	if req.email == '' {
		return error('Email is required')
	}
	if !phone_re.matches_string(req.email) {
		return error('Invalid email format')
	}
}

// ----------------- DTO 层 -----------------
pub struct SmsLoginReq {
	email string @[json: 'email']
}

pub struct SmsLoginResp {
	token_opt string @[json: 'token_opt']
	code      string @[json: 'code']
	msg       string @[json: 'msg']
}

// ----------------- Repository / 核心逻辑层 -----------------

// 模块级常量 - 编译期初始化
const phone_re = regex.regex_opt(r'^\+?[0-9]{1,4}?[-\s]?\(?[0-9]{1,4}\)?[-\s]?[0-9]{1,12}$') or {
	panic('Invalid phone regex pattern')
}

fn find_sms_opt_repo() !SmsLoginResp {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	token_opt, opt_num := jwt.opt_generate()

	// TODO: 可选数据库保存逻辑
	/*
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or {
			log.warn('Failed to release connection ${@LOCATION}: ${err}')
		}
	}

	infos := schema_sys.SysMFAlog{
		id:            rand.uuid_v7()
		verify_source: req.email
		method:        'SMS'
		code:          opt_num
		created_at:    time.now()
	}
	mut sys_info := orm.new_query[schema_sys.SysMFAlog](db)
	sys_info.insert(infos)!
	*/

	return SmsLoginResp{
		token_opt: token_opt
		code:      opt_num
		msg:       'SMS code generated successfully'
	}
}

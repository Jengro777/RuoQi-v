module authentication

import veb
import log
import common.jwt
import common.api
import structs { Context }

@['/captcha'; get; post]
pub fn (app &Authentication) find_image_captcha_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	captcha_token, captcha_image, _ := jwt.captcha_generate() or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}
	return ctx.json(api.json_success(
		code:   200
		status: 200
		data:   GetCaptchaResp{
			captcha_token: captcha_token
			captcha_image: captcha_image
		}
		msg:    'captcha generated'
	))
}

@['/email_opt'; post]
pub fn (app &Authentication) find_email_opt_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	_, opt_token := jwt.opt_generate()
	return ctx.json(api.json_success(
		code:   200
		status: 200
		data:   GetOptResp{
			opt_token: opt_token
		}
		msg:    'email OTP generated'
	))
}

@['/sms_opt'; post]
pub fn (app &Authentication) find_sms_opt_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	_, opt_token := jwt.opt_generate()
	return ctx.json(api.json_success(
		code:   200
		status: 200
		data:   GetOptResp{
			opt_token: opt_token
		}
		msg:    'sms OTP generated'
	))
}

pub struct GetCaptchaResp {
	captcha_token string @[json: 'captchaToken']
	captcha_image string @[json: 'captchaImage']
}

pub struct GetOptResp {
	opt_token string @[json: 'optToken']
}

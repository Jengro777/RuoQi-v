module authentication

import veb
import log
import common.crypt
import common.api
import structs { Context }

// ═══ Handler ═══
@['/captcha'; get; post]
pub fn (app &Authentication) find_image_captcha_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	captcha_token, captcha_image, _ := crypt.captcha_generate(ctx.config.jwt.secret) or {
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

// ═══ DTO ═══
pub struct GetCaptchaResp {
	captcha_token string @[json: 'captchaToken']
	captcha_image string @[json: 'captchaImage']
}

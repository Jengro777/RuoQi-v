module authentication

import veb
import log
import common.crypt
import common.api
import model { Context }

// ═══ Handler ═══
@['/captcha'; get; post]
pub fn (app &Authentication) find_image_captcha_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	captcha_token, captcha_image, _ := crypt.captcha_generate(ctx.config.crypt.jwt_secret) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(api.json_success(
		data: GetCaptchaResp{
			captcha_token: captcha_token
			captcha_image: captcha_image
		}
		msg: 'captcha generated'
	))
}

// ═══ DTO ═══
pub struct GetCaptchaResp {
	captcha_token string @[json: 'captchaToken']
	captcha_image string @[json: 'captchaImage']
}

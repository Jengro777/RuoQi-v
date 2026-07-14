module authentication

import veb
import log
import common.crypt
import common.api
import structs { Context }

// ═══ Handler ═══
@['/email_opt'; post]
pub fn (app &Authentication) find_email_opt_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	_, opt_token := crypt.opt_generate(ctx.config.jwt.secret)
	return ctx.json(api.json_success(
		code:   200
		status: 200
		data:   GetOptResp{
			opt_token: opt_token
		}
		msg:    'email OTP generated'
	))
}

// ═══ DTO ═══
pub struct GetOptResp {
	opt_token string @[json: 'optToken']
}

module authentication

import veb
import log
import common.jwt
import common.api
import structs { Context }

// ═══ Handler ═══
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

// ═══ DTO ═══
// GetOptResp defined in find_email_opt_logic.v (shared via module scope)

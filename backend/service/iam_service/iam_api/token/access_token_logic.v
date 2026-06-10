module token

import time
import rand
import structs { Context }
import common.jwt

pub fn generate_iam_token(mut ctx Context, user_id string, username string, login_ip string, device_id string) !string {
	payload := jwt.AuthPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: user_id
			exp: time.now().add_days(30).unix()
			nbf: time.now().unix()
			iat: time.now().unix()
			jti: rand.uuid_v4()
		}
		role_ids:    []string{}
		client_ip:   login_ip
		device_id:   device_id
	}
	return jwt.auth_generate(ctx.config.jwt.secret, payload)
}

pub fn verify_iam_token_and_populate_ctx(mut ctx Context, token_str string) ! {
	payload := jwt.verify_and_decode[jwt.AuthPayload](ctx.config.jwt.secret, token_str) or {
		return error('JWT verification failed')
	}
	ctx.svc_iam.user_id = payload.sub
	ctx.svc_iam.token_jwt = token_str
	ctx.svc_iam.role_ids = payload.role_ids
}

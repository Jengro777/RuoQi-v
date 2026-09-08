module token

import time
import rand
import model { Context }
import common.crypt

pub fn generate_iam_token(mut ctx Context, user_id string, username string, login_ip string, device_id string) !string {
	payload := crypt.AuthPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: user_id
			exp: time.now().add_days(30).unix()
			nbf: time.now().unix()
			iat: time.now().unix()
			jti: rand.uuid_v4()
		}
		client_ip: login_ip
		device_id: device_id
	}
	return crypt.auth_generate(ctx.config.crypt.jwt_secret, payload)
}

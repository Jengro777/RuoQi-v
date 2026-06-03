// ==============================================================================
// opt_test.v — OTP 测试
// 对应 opt.v：OptPayload / opt_generate / opt_verify
// ==============================================================================
module test

import common.jwt
import time

fn test_opt_generate() {
	token, opt_num := jwt.opt_generate()
	dump(token)
	dump(opt_num)
	assert typeof(token).name == 'string'
	assert typeof(opt_num).name == 'string'
	assert token != ''
}

fn test_opt_verify() {
	token, opt := jwt.opt_generate()
	verify := jwt.opt_verify(token, opt)
	assert verify == true
}

fn test_opt_verify_wrong_code() {
	token, _ := jwt.opt_generate()
	assert jwt.opt_verify(token, '00000') == false
}

fn test_opt_verify_tampered_token() {
	token, opt_num := jwt.opt_generate()
	parts := token.split('.')
	tampered := '${parts[0]}.${parts[1]}.INVALIDSIGNATURE'
	assert jwt.opt_verify(tampered, opt_num) == false
}

fn test_opt_verify_expired_token() {
	now := time.now().unix()
	payload := jwt.OptPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'opt'
			exp: now - 1
			nbf: now - 120
			iat: now - 120
			jti: 'expired-jti'
		}
		opt_text:    '12345'
	}
	token := jwt.sign_payload[jwt.OptPayload](jwt.jwt_secret, payload)
	assert jwt.opt_verify(token, '12345') == false
}

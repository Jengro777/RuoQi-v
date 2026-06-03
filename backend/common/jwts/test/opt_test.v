// ==============================================================================
// opt_test.v — OTP 测试
// 对应 opt.v：OptPayload / opt_generate / opt_verify
// ==============================================================================
module test

import common.jwts
import time

fn test_opt_generate() {
	token, opt_num := jwts.opt_generate()
	dump(token)
	dump(opt_num)
	assert typeof(token).name == 'string'
	assert typeof(opt_num).name == 'string'
	assert token != ''
}

fn test_opt_verify() {
	token, opt := jwts.opt_generate()
	verify := jwts.opt_verify(token, opt)
	assert verify == true
}

fn test_opt_verify_wrong_code() {
	token, _ := jwts.opt_generate()
	assert jwts.opt_verify(token, '00000') == false
}

fn test_opt_verify_tampered_token() {
	token, opt_num := jwts.opt_generate()
	parts := token.split('.')
	tampered := '${parts[0]}.${parts[1]}.INVALIDSIGNATURE'
	assert jwts.opt_verify(tampered, opt_num) == false
}

fn test_opt_verify_expired_token() {
	now := time.now().unix()
	payload := jwts.OptPayload{
		BasePayload: jwts.BasePayload{
			iss: 'ruoqi-v'
			sub: 'opt'
			exp: now - 1
			nbf: now - 120
			iat: now - 120
			jti: 'expired-jti'
		}
		opt_text:    '12345'
	}
	token := jwts.sign_payload[jwts.OptPayload](jwts.jwt_secret, payload)
	assert jwts.opt_verify(token, '12345') == false
}

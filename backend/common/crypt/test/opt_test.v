// ==============================================================================
// opt_test.v — OTP 测试
// 对应 opt.v：OptPayload / opt_generate / opt_verify
// ==============================================================================
module test

import common.crypt
import time

const test_jwt_secret = 'test-jwt-secret'

fn test_opt_generate() {
	token, opt_num := crypt.opt_generate(test_jwt_secret)
	dump(token)
	dump(opt_num)
	assert typeof(token).name == 'string'
	assert typeof(opt_num).name == 'string'
	assert token != ''
}

fn test_opt_verify() {
	token, opt := crypt.opt_generate(test_jwt_secret)
	verify := crypt.opt_verify(test_jwt_secret, token, opt)
	assert verify == true
}

fn test_opt_verify_wrong_code() {
	token, _ := crypt.opt_generate(test_jwt_secret)
	assert crypt.opt_verify(test_jwt_secret, token, '00000') == false
}

fn test_opt_verify_tampered_token() {
	token, opt_num := crypt.opt_generate(test_jwt_secret)
	parts := token.split('.')
	tampered := '${parts[0]}.${parts[1]}.INVALIDSIGNATURE'
	assert crypt.opt_verify(test_jwt_secret, tampered, opt_num) == false
}

fn test_opt_verify_expired_token() {
	now := time.now().unix()
	payload := crypt.OptPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'opt'
			exp: now - 1
			nbf: now - 120
			iat: now - 120
			jti: 'expired-jti'
		}
		opt_text:    '12345'
	}
	token := crypt.sign_payload[crypt.OptPayload](test_jwt_secret, payload)
	assert crypt.opt_verify(test_jwt_secret, token, '12345') == false
}

// ==============================================================================
// core_test.v — 共享基础设施测试
// 对应 jwt_core.v：JwtHeader / constant_time_compare / sign_payload / verify_and_decode
// ==============================================================================
module test

import common.jwt
import time

fn test_constant_time_compare_match() {
	assert jwt.constant_time_compare('abc', 'abc') == true
}

fn test_constant_time_compare_mismatch() {
	assert jwt.constant_time_compare('abc', 'abd') == false
}

fn test_constant_time_compare_diff_len() {
	assert jwt.constant_time_compare('abcdef', 'abc') == false
}

fn test_sign_and_verify_roundtrip() {
	now := time.now().unix()
	payload := jwt.OptPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'roundtrip-user'
			exp: now + 300
			nbf: now
			iat: now
			jti: 'jti-rt'
		}
		opt_text:    '67890'
	}
	token := jwt.sign_payload[jwt.OptPayload](jwt.jwt_secret, payload)
	decoded := jwt.verify_and_decode[jwt.OptPayload](jwt.jwt_secret, token)!

	assert decoded.iss == payload.iss
	assert decoded.sub == payload.sub
	assert decoded.jti == payload.jti
	assert decoded.opt_text == payload.opt_text
}

fn test_verify_and_decode_wrong_secret() {
	token, _ := jwt.opt_generate()
	_ := jwt.verify_and_decode[jwt.OptPayload]('wrong-secret', token) or {
		assert true
		return
	}
	assert false, 'verify_and_decode should fail with wrong secret'
}

fn test_verify_and_decode_expired() {
	now := time.now().unix()
	payload := jwt.OptPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'exp-test'
			exp: now - 1
			nbf: now - 120
			iat: now - 120
			jti: 'expired-jti'
		}
		opt_text:    '12345'
	}
	token := jwt.sign_payload[jwt.OptPayload](jwt.jwt_secret, payload)
	_ := jwt.verify_and_decode[jwt.OptPayload](jwt.jwt_secret, token) or {
		assert true
		return
	}
	assert false, 'verify_and_decode should fail for expired token'
}

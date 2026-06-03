// ==============================================================================
// core_test.v — 共享基础设施测试
// 对应 jwt_core.v：JwtHeader / constant_time_compare / sign_payload / verify_and_decode
// ==============================================================================
module test

import common.jwts
import time

fn test_constant_time_compare_match() {
	assert jwts.constant_time_compare('abc', 'abc') == true
}

fn test_constant_time_compare_mismatch() {
	assert jwts.constant_time_compare('abc', 'abd') == false
}

fn test_constant_time_compare_diff_len() {
	assert jwts.constant_time_compare('abcdef', 'abc') == false
}

fn test_sign_and_verify_roundtrip() {
	now := time.now().unix()
	payload := jwts.OptPayload{
		BasePayload: jwts.BasePayload{
			iss: 'ruoqi-v'
			sub: 'roundtrip-user'
			exp: now + 300
			nbf: now
			iat: now
			jti: 'jti-rt'
		}
		opt_text:    '67890'
	}
	token := jwts.sign_payload[jwts.OptPayload](jwts.jwt_secret, payload)
	decoded := jwts.verify_and_decode[jwts.OptPayload](jwts.jwt_secret, token)!

	assert decoded.iss == payload.iss
	assert decoded.sub == payload.sub
	assert decoded.jti == payload.jti
	assert decoded.opt_text == payload.opt_text
}

fn test_verify_and_decode_wrong_secret() {
	token, _ := jwts.opt_generate()
	_ := jwts.verify_and_decode[jwts.OptPayload]('wrong-secret', token) or {
		assert true
		return
	}
	assert false, 'verify_and_decode should fail with wrong secret'
}

fn test_verify_and_decode_expired() {
	now := time.now().unix()
	payload := jwts.OptPayload{
		BasePayload: jwts.BasePayload{
			iss: 'ruoqi-v'
			sub: 'exp-test'
			exp: now - 1
			nbf: now - 120
			iat: now - 120
			jti: 'expired-jti'
		}
		opt_text:    '12345'
	}
	token := jwts.sign_payload[jwts.OptPayload](jwts.jwt_secret, payload)
	_ := jwts.verify_and_decode[jwts.OptPayload](jwts.jwt_secret, token) or {
		assert true
		return
	}
	assert false, 'verify_and_decode should fail for expired token'
}

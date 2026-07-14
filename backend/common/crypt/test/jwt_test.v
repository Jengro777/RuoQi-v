// ==============================================================================
// jwt_test.v — JWT 签发 / 验证 / 解析测试
// 对应 jwt.v：sign_payload / verify_and_decode / decode_payload
// 数据结构定义见 jwt_struct.v。
// ==============================================================================
module test

import common.crypt
import time

const test_jwt_secret = 'test-jwt-secret'

// ---- sign_payload + verify_and_decode ---------------------------------------

fn test_sign_and_verify_roundtrip() {
	now := time.now().unix()
	payload := crypt.OptPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'roundtrip-user'
			exp: now + 300
			nbf: now
			iat: now
			jti: 'jti-rt'
		}
		opt_text:    '67890'
	}
	token := crypt.sign_payload[crypt.OptPayload](test_jwt_secret, payload)
	decoded := crypt.verify_and_decode[crypt.OptPayload](test_jwt_secret, token)!

	assert decoded.iss == payload.iss
	assert decoded.sub == payload.sub
	assert decoded.jti == payload.jti
	assert decoded.opt_text == payload.opt_text
}

fn test_verify_and_decode_wrong_secret() {
	token, _ := crypt.opt_generate(test_jwt_secret)
	_ := crypt.verify_and_decode[crypt.OptPayload]('wrong-secret', token) or {
		assert true
		return
	}
	assert false, 'verify_and_decode should fail with wrong secret'
}

fn test_verify_and_decode_expired() {
	now := time.now().unix()
	payload := crypt.OptPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'exp-test'
			exp: now - 1
			nbf: now - 120
			iat: now - 120
			jti: 'expired-jti'
		}
		opt_text:    '12345'
	}
	token := crypt.sign_payload[crypt.OptPayload](test_jwt_secret, payload)
	_ := crypt.verify_and_decode[crypt.OptPayload](test_jwt_secret, token) or {
		assert true
		return
	}
	assert false, 'verify_and_decode should fail for expired token'
}

fn test_verify_and_decode_not_yet_valid() {
	now := time.now().unix()
	payload := crypt.OptPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'future-test'
			exp: now + 7200
			nbf: now + 3600 // 1 小时后才生效
			iat: now
			jti: 'future-jti'
		}
		opt_text:    '99999'
	}
	token := crypt.sign_payload[crypt.OptPayload](test_jwt_secret, payload)
	_ := crypt.verify_and_decode[crypt.OptPayload](test_jwt_secret, token) or {
		assert true
		return
	}
	assert false, 'verify_and_decode should fail for not-yet-valid token'
}

fn test_verify_and_decode_tampered_payload() {
	now := time.now().unix()
	payload := crypt.OptPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'tamper-test'
			exp: now + 300
			nbf: now
			iat: now
			jti: 'tamper-jti'
		}
		opt_text:    '11111'
	}
	token := crypt.sign_payload[crypt.OptPayload](test_jwt_secret, payload)
	parts := token.split('.')
	// 篡改 payload 部分
	tampered := '${parts[0]}.TAMPERED.${parts[2]}'
	_ := crypt.verify_and_decode[crypt.OptPayload](test_jwt_secret, tampered) or {
		assert true
		return
	}
	assert false, 'verify_and_decode should reject tampered token'
}

// ---- decode_payload ---------------------------------------------------------

fn test_decode_payload() {
	now := time.now().unix()
	payload := crypt.OptPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'decode-test'
			exp: now + 3600
			nbf: now
			iat: now
			jti: 'decode-jti'
		}
		opt_text:    '54321'
	}
	token := crypt.sign_payload[crypt.OptPayload](test_jwt_secret, payload)
	decoded := crypt.decode_payload[crypt.OptPayload](token)!
	assert decoded.sub == 'decode-test'
	assert decoded.opt_text == '54321'
}

fn test_decode_payload_invalid_format() {
	_ := crypt.decode_payload[crypt.OptPayload]('not.a.token') or {
		assert true
		return
	}
	assert false, 'decode_payload should fail for invalid format'
}

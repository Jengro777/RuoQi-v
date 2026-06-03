// ==============================================================================
// auth_test.v — 认证会话测试
// 对应 auth.v：AuthPayload / auth_generate / auth_verify / auth_decode
// ==============================================================================
module test

import common.jwt
import time

// ---- auth_generate ----------------------------------------------------------

fn test_auth_generate() {
	now := time.now().unix()
	secret := 'test-auth-secret'
	payload := jwt.AuthPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'user-123'
			exp: now + 3600
			nbf: now
			iat: now
			jti: 'jti-001'
		}
		role_ids:    ['admin']
		client_ip:   '10.0.0.1'
		device_id:   'dev-a'
	}
	token := jwt.auth_generate(secret, payload)
	dump(token)
	assert typeof(token).name == 'string'
	assert token != ''
	assert token.split('.').len == 3
}

// ---- auth_verify ------------------------------------------------------------

fn test_auth_verify() {
	now := time.now().unix()
	secret := 'test-auth-secret'
	payload := jwt.AuthPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'user-123'
			exp: now + 3600
			nbf: now
			iat: now
			jti: 'jti-ver'
		}
	}
	token := jwt.auth_generate(secret, payload)
	assert jwt.auth_verify(secret, token) == true
}

fn test_auth_verify_wrong_secret() {
	now := time.now().unix()
	payload := jwt.AuthPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'u1'
			exp: now + 3600
			nbf: now
			iat: now
			jti: 'j1'
		}
	}
	token := jwt.auth_generate('secret-a', payload)
	assert jwt.auth_verify('secret-b', token) == false
}

fn test_auth_verify_expired() {
	now := time.now().unix()
	payload := jwt.AuthPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'u1'
			exp: now - 1
			nbf: now - 3600
			iat: now - 3600
			jti: 'j1'
		}
	}
	token := jwt.auth_generate('secret', payload)
	assert jwt.auth_verify('secret', token) == false
}

// ---- auth_decode ------------------------------------------------------------

fn test_auth_decode() {
	now := time.now().unix()
	secret := 'decode-secret'
	payload := jwt.AuthPayload{
		BasePayload: jwt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'decode-test'
			exp: now + 3600
			nbf: now
			iat: now
			jti: 'jti-decode'
		}
		role_ids:    ['admin', 'user']
		client_ip:   '192.168.1.1'
	}
	token := jwt.auth_generate(secret, payload)
	decoded := jwt.auth_decode(token)!
	assert decoded.sub == payload.sub
	assert decoded.role_ids == payload.role_ids
	assert decoded.client_ip == payload.client_ip
}

fn test_auth_decode_invalid() {
	_ := jwt.auth_decode('not.a.valid.token') or {
		assert true
		return
	}
	assert false, 'expected error for invalid token'
}

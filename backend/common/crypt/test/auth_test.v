// ==============================================================================
// auth_test.v — 认证会话测试
// 对应 auth.v：AuthPayload / auth_generate / auth_verify
// ==============================================================================
module test

import common.crypt
import time

// ---- auth_generate ----------------------------------------------------------

fn test_auth_generate() {
	now := time.now().unix()
	secret := 'test-auth-secret'
	payload := crypt.AuthPayload{
		BasePayload: crypt.BasePayload{
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
	token := crypt.auth_generate(secret, payload)
	dump(token)
	assert typeof(token).name == 'string'
	assert token != ''
	assert token.split('.').len == 3
}

// ---- auth_verify ------------------------------------------------------------

fn test_auth_verify() {
	now := time.now().unix()
	secret := 'test-auth-secret'
	payload := crypt.AuthPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'user-123'
			exp: now + 3600
			nbf: now
			iat: now
			jti: 'jti-ver'
		}
	}
	token := crypt.auth_generate(secret, payload)
	assert crypt.auth_verify(secret, token) == true
}

fn test_auth_verify_wrong_secret() {
	now := time.now().unix()
	payload := crypt.AuthPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'u1'
			exp: now + 3600
			nbf: now
			iat: now
			jti: 'j1'
		}
	}
	token := crypt.auth_generate('secret-a', payload)
	assert crypt.auth_verify('secret-b', token) == false
}

fn test_auth_verify_expired() {
	now := time.now().unix()
	payload := crypt.AuthPayload{
		BasePayload: crypt.BasePayload{
			iss: 'ruoqi-v'
			sub: 'u1'
			exp: now - 1
			nbf: now - 3600
			iat: now - 3600
			jti: 'j1'
		}
	}
	token := crypt.auth_generate('secret', payload)
	assert crypt.auth_verify('secret', token) == false
}

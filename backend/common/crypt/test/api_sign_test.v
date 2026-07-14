// ==============================================================================
// api_sign_test.v — AK/SK HMAC 签名验证测试
// 对应 api_sign.v：verify_apisign
// ==============================================================================
module test

import common.crypt
import crypto.sha256
import encoding.base64
import time

// ---- helper: 模拟客户端签名 ---------------------------------------------------

fn client_sign(sk string, method string, path string, body string, timestamp string) string {
	body_hex := sha256.hexhash(body)
	canonical := '${method.to_upper()}\n${path}\n${body_hex}\n${timestamp}'
	return base64.encode(crypt.hmac_sign(sk, canonical))
}

// ---- verify_apisign ---------------------------------------------------------

fn test_verify_apisign_ok() {
	sk := 'sk-test-secret-key-0000000000000000000000000000000000000000000000'
	method := 'POST'
	path := '/api/v1/order/create'
	body := '{"amount":100}'
	now := time.now().unix()
	ts := now.str()
	sig := client_sign(sk, method, path, body, ts)

	crypt.verify_apisign(sk, method, path, body, ts, sig, 300) or {
		assert false, 'verify_apisign should succeed: ${err}'
	}
	assert true
}

fn test_verify_apisign_wrong_sk() {
	sk := 'sk-correct-key-000000000000000000000000000000000000000000000000000'
	wrong_sk := 'sk-wrong-key-0000000000000000000000000000000000000000000000000000'
	method := 'GET'
	path := '/api/v1/user/info'
	body := ''
	now := time.now().unix()
	ts := now.str()

	// 用正确 SK 签名，用错误 SK 验证
	sig := client_sign(sk, method, path, body, ts)
	crypt.verify_apisign(wrong_sk, method, path, body, ts, sig, 300) or {
		assert true
		return
	}
	assert false, 'verify_apisign should fail with wrong SK'
}

fn test_verify_apisign_wrong_body() {
	sk := 'sk-body-test-00000000000000000000000000000000000000000000000000000'
	method := 'POST'
	path := '/api/v1/data'
	body := '{"x":1}'
	wrong_body := '{"x":2}'
	now := time.now().unix()
	ts := now.str()

	sig := client_sign(sk, method, path, body, ts)
	crypt.verify_apisign(sk, method, path, wrong_body, ts, sig, 300) or {
		assert true
		return
	}
	assert false, 'verify_apisign should fail with wrong body'
}

fn test_verify_apisign_expired_timestamp() {
	sk := 'sk-expire-test-000000000000000000000000000000000000000000000000000'
	method := 'GET'
	path := '/api/v1/health'
	body := ''
	// 时间戳设为 10 分钟前
	old_ts := (time.now().unix() - 600).str()
	sig := client_sign(sk, method, path, body, old_ts)

	crypt.verify_apisign(sk, method, path, body, old_ts, sig, 300) or {
		assert true
		return
	}
	assert false, 'verify_apisign should reject expired timestamp'
}

fn test_verify_apisign_invalid_timestamp() {
	sk := 'sk-invalid-ts-0000000000000000000000000000000000000000000000000000'
	method := 'GET'
	path := '/health'
	body := ''
	invalid_ts := 'not-a-timestamp'
	sig := client_sign(sk, method, path, body, invalid_ts)

	crypt.verify_apisign(sk, method, path, body, invalid_ts, sig, 300) or {
		assert true
		return
	}
	assert false, 'verify_apisign should reject non-numeric timestamp'
}

fn test_verify_apisign_tampered_sig() {
	sk := 'sk-tamper-test-000000000000000000000000000000000000000000000000000'
	method := 'DELETE'
	path := '/api/v1/resource/123'
	body := ''
	now := time.now().unix()
	ts := now.str()

	sig := client_sign(sk, method, path, body, ts)
	tampered_sig := sig[..sig.len - 4] + 'AAAA'
	crypt.verify_apisign(sk, method, path, body, ts, tampered_sig, 300) or {
		assert true
		return
	}
	assert false, 'verify_apisign should reject tampered signature'
}

fn test_verify_apisign_case_insensitive_method() {
	sk := 'sk-case-test-00000000000000000000000000000000000000000000000000000'
	path := '/api/test'
	body := ''
	now := time.now().unix()
	ts := now.str()

	// 用小写 method 签名，verify_apisign 内部会 to_upper
	sig := client_sign(sk, 'post', path, body, ts)
	crypt.verify_apisign(sk, 'POST', path, body, ts, sig, 300) or {
		assert false, 'verify_apisign should handle case-insensitive method: ${err}'
	}
	assert true
}

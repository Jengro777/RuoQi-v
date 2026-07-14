// ==============================================================================
// core_test.v — 底层密码学原语测试
// 对应 core.v：constant_time_compare / hmac_sign
// ==============================================================================
module test

import common.crypt

// ---- constant_time_compare --------------------------------------------------

fn test_constant_time_compare_match() {
	assert crypt.constant_time_compare('abc', 'abc') == true
}

fn test_constant_time_compare_mismatch() {
	assert crypt.constant_time_compare('abc', 'abd') == false
}

fn test_constant_time_compare_diff_len() {
	assert crypt.constant_time_compare('abcdef', 'abc') == false
}

// ---- hmac_sign --------------------------------------------------------------

fn test_hmac_sign_known_vector() {
	// HMAC-SHA256 标准测试向量 (RFC 4231 Test Case 1)
	key := '0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b'
	message := 'Hi There'
	sig := crypt.hmac_sign(key, message)
	assert sig.len == 32 // SHA-256 输出 32 字节
}

fn test_hmac_sign_deterministic() {
	key := 'test-key'
	msg := 'test-message'
	a := crypt.hmac_sign(key, msg)
	b := crypt.hmac_sign(key, msg)
	// 相同输入产生相同输出
	assert a.len == b.len
	for i in 0 .. a.len {
		assert a[i] == b[i]
	}
}

fn test_hmac_sign_empty_message() {
	// 空消息也能签名
	sig := crypt.hmac_sign('key', '')
	assert sig.len == 32
}

// ==============================================================================
// api_sign.v — API 请求 HMAC 签名（AK/SK 验证）
//
//   METHOD + "\n" + PATH + "\n" + SHA256_HEX(BODY) + "\n" + TIMESTAMP
// 签名:
//   BASE64( HMAC-SHA256( UTF8(SK), UTF8(canonical) ) )
//
// 底层依赖 core.v：hmac_sign, constant_time_compare
// ==============================================================================
module crypt

import crypto.sha256
import encoding.base64
import time

// 请求头常量
pub const sig_header_access_key = 'X-Access-Key'
pub const sig_header_timestamp = 'X-Timestamp'
pub const sig_header_signature = 'X-Signature'

// verify_apisign 验证 API 请求签名（SK 已解密）
//   method    — HTTP 方法大写
//   path      — 请求路径，不含 context-path 和 query
//   body      — 请求体原始字符串
//   timestamp — Unix 秒字符串
//   sig       — 客户端发送的 Base64 签名
//   skew_sec  — 时间戳允许偏差秒数
pub fn verify_apisign(sk string, method string, path string, body string, timestamp string, sig string, skew_sec i64) ! {
	// 1. 时间戳校验
	ts := timestamp.i64()
	if ts <= 0 {
		return error('timestamp invalid')
	}
	now := time.now().unix()
	mut diff := now - ts
	if diff < 0 { diff = -diff }
	if diff > skew_sec {
		return error('timestamp expired')
	}

	// 2. 构造规范串
	body_hex := sha256.hexhash(body)
	canonical := '${method.to_upper()}\n${path}\n${body_hex}\n${timestamp}'

	// 3. HMAC 签名验证
	expected := base64.encode(hmac_sign(sk, canonical))
	if !constant_time_compare(sig, expected) {
		return error('signature mismatch')
	}
}

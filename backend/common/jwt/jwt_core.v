// ==============================================================================
// jwt_core.v — 共享 JWT 函数
//
// 数据结构定义见 struct.v。
// ==============================================================================
module jwt

import crypto.hmac
import crypto.sha256
import encoding.base64
import json2 as json
import time

// ---- 常量时间比较（防时序攻击）------------------------------------------------

pub fn constant_time_compare(a string, b string) bool {
	mut diff := a.len ^ b.len
	max_len := if a.len > b.len { a.len } else { b.len }
	for i in 0 .. max_len {
		a_char := if i < a.len { a[i] } else { u8(0) }
		b_char := if i < b.len { b[i] } else { u8(0) }
		diff |= int(a_char) ^ int(b_char)
	}
	return diff == 0
}

// ---- 泛型签发 ----------------------------------------------------------------

// sign_payload 将任意 payload 序列化并签名，返回完整的 JWT token。
// T 必须是可 JSON 序列化的 struct。
pub fn sign_payload[T](secret string, payload T) string {
	header_b64 := base64.url_encode_str(json.encode(JwtHeader{
		alg: 'HS256'
		typ: 'JWT'
	}))
	playload_b64 := base64.url_encode_str(json.encode(payload))
	message := '${header_b64}.${playload_b64}'
	signature := hmac.new(secret.bytes(), message.bytes(), sha256.sum, 64)
	return '${header_b64}.${playload_b64}.${base64.url_encode_str(signature.bytestr())}'
}

// ---- 泛型验证管道 -------------------------------------------------------------
// 替代三模块中各自手写的 ~25 行验证代码。

// verify_and_decode 完成完整 JWT 验证：
//   1. 分割 token     2. 校验 header
//   3. 校验签名        4. 解码为 T
//   5. 通过 JwtTimeBounded 接口校验 exp / nbf
//
// 各模块的 _verify 函数只需调用此函数，再做一步业务字段比对。
pub fn verify_and_decode[T](secret string, token string) !T {
	parts := token.split('.')
	if parts.len != 3 {
		return error('JWT: expected 3 parts, got ${parts.len}')
	}

	// 1. 校验 header
	header := json.decode[JwtHeader](base64.url_decode_str(parts[0])) or {
		return error('JWT: invalid header encoding')
	}
	if header.alg != 'HS256' || header.typ != 'JWT' {
		return error('JWT: unsupported algorithm or type')
	}

	// 2. 校验签名
	message := '${parts[0]}.${parts[1]}'
	real_sig := hmac.new(secret.bytes(), message.bytes(), sha256.sum, 64)
	expected_sig := base64.url_encode_str(real_sig.bytestr())
	if !constant_time_compare(parts[2], expected_sig) {
		return error('JWT: signature mismatch')
	}

	// 3. 解码 payload
	payload := json.decode[T](base64.url_decode_str(parts[1])) or {
		return error('JWT: payload decode failed')
	}

	// 4. 时间校验 —— 所有 payload 都嵌入 BasePayload，满足 JwtTimeBounded
	mut jtb := JwtTimeBounded(&payload)
	if time.now().unix() >= jtb.exp {
		return error('JWT: token expired')
	}
	if time.now().unix() < jtb.nbf {
		return error('JWT: token not yet valid')
	}

	return payload
}

// 解析 JWT token（不验证签名，只解析 payload）
pub fn jwt_decode(token string) !AuthPayload {
	parts := token.split('.')
	if parts.len != 3 {
		return error('Invalid JWT format: expected 3 parts, got ${parts.len}')
	}
	// 解析 JSON
	payload := json.decode[AuthPayload](base64.url_decode_str(parts[1])) or {
		return error('Failed to parse JWT payload JSON: ${err}')
	}
	return payload
}

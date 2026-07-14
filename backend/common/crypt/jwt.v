// ==============================================================================
// jwt.v — JWT 协议：签发 / 验证 / 解析（基于 crypt 模块底层原语）
//
// 底层依赖 core.v：hmac_sign, constant_time_compare
// 数据结构定义见 jwt_struct.v。
// ==============================================================================
module crypt

import encoding.base64
import json2 as json
import time

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
	sig_b64 := base64.url_encode_str(hmac_sign(secret, message).bytestr())
	return '${header_b64}.${playload_b64}.${sig_b64}'
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
	expected_sig := base64.url_encode_str(hmac_sign(secret, message).bytestr())
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

// decode_payload 解析 JWT payload（不验证签名）。
// 只适合在调用方已经完成签名验证后使用，或者用于非信任场景的调试解析。
pub fn decode_payload[T](token string) !T {
	parts := token.split('.')
	if parts.len != 3 {
		return error('Invalid JWT format: expected 3 parts, got ${parts.len}')
	}
	payload := json.decode[T](base64.url_decode_str(parts[1])) or {
		return error('Failed to parse JWT payload JSON: ${err}')
	}
	return payload
}

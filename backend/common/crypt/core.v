// ==============================================================================
// core.v — crypt 模块底层密码学原语（无协议依赖）
//
//   constant_time_compare — 防时序攻击的字符串比对
//   hmac_sign             — HMAC-SHA256 签名（JWT / AK-SK 共用）
//
// JWT 协议见 jwt.v，SK 存储加密见 secret_cipher.v。
// ==============================================================================
module crypt

import crypto.hmac
import crypto.sha256

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

// ---- 统一 HMAC ---------------------------------------------------------------

// hmac_sign 对 message 做 HMAC-SHA256，返回原始字节（JWT / AK-SK 共用）
pub fn hmac_sign(key string, message string) []u8 {
	return hmac.new(key.bytes(), message.bytes(), sha256.sum, sha256.block_size)
}

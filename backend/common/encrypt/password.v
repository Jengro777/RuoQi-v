module encrypt

import crypto.bcrypt
import crypto.sha256
import regex
import strconv

pub const client_salt = '7x!A@D#Ke9q2$}{{*)%~?'
const expected_sha_len = 64

// ===================================================================
// SHA256 hex 格式检查
// ===================================================================
pub fn is_sha256(s string) bool {
	if s.len != expected_sha_len {
		return false
	}
	r := regex.regex_opt(r'^[0-9a-fA-F]{64}$') or { return false }
	return r.matches_string(s)
}

// ===================================================================
// SHA256 hex 生成
// ===================================================================
pub fn sha256_hex(s string) string {
	return sha256.hexhash(s)
}

// ===================================================================
// hex -> u8 array 转换
// ===================================================================
fn hex_to_u8(s string) ![]u8 {
	if s.len % 2 != 0 {
		return error('invalid hex length')
	}
	mut b := []u8{cap: s.len / 2}
	for i := 0; i < s.len; i += 2 {
		val := u8(strconv.parse_uint(s[i..i + 2], 16, 8) or { return error('invalid hex') })
		b << val
	}
	return b
}

// ===================================================================
// bcrypt 生成
// ===================================================================
pub fn bcrypt_hash(client_sha string) !string {
	if client_sha.len == 0 {
		return error('empty password hash')
	}
	if !is_sha256(client_sha) {
		return error('input must be sha256 hex string')
	}
	b := hex_to_u8(client_sha)!
	return bcrypt.generate_from_password(b, bcrypt.default_cost)
}

// ===================================================================
// bcrypt 验证
// ===================================================================
pub fn bcrypt_verify(client_sha string, stored_hash string) bool {
	if client_sha.len == 0 || stored_hash.len == 0 {
		return false
	}
	if !is_sha256(client_sha) {
		return false
	}

	// SHA256 hex 转字节
	b := hex_to_u8(client_sha) or { return false }

	// bcrypt hash 转字节
	hash_bytes := stored_hash.bytes() // []u8

	// 调用 compare_hash_and_password
	// 成功 -> 返回 true
	// 失败 -> or { return false } 捕获
	bcrypt.compare_hash_and_password(b, hash_bytes) or { return false }

	return true
}

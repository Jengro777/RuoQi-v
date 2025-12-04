module jwt

// JWT标准声明 (Standard Claims) https://datatracker.ietf.org/doc/html/rfc7519#section-4.1
import crypto.hmac
import crypto.sha256
import encoding.base64
import x.json2 as json
import time

// JWT 头部固定使用HS256算法 [使用这种方式，编译器会产生c错误]
const header = base64.url_encode_str(json.encode(JwtHeader{
	alg: 'HS256'
	typ: 'JWT'
}))

//生成令牌
pub fn jwt_generate(secret string, payload JwtPayload) string {
	playload_64 := base64.url_encode_str(json.encode(payload))

	message := '${header}.${playload_64}'
	signature := hmac.new(secret.bytes(), message.bytes(), sha256.sum, 64)
	base64_signature := base64.url_encode_str(signature.bytestr())
	return '${header}.${playload_64}.${base64_signature}'
}

// 验证令牌
pub fn jwt_verify(secret string, token string) bool {
	// 1.分割验证
	parts := token.split('.')
	if parts.len != 3 {
		return false
	}

	// 2. 验证头部
	// header_str := base64.url_decode_str(parts[0]) // or { return false }
	headers := json.decode[JwtHeader](base64.url_decode_str(parts[0])) or { return false }
	if headers.alg != 'HS256' || headers.typ != 'JWT' {
		return false
	}

	// 3. 验证签名（防时序攻击）
	message := '${parts[0]}.${parts[1]}'
	real_sig := hmac.new(secret.bytes(), message.bytes(), sha256.sum, 64)
	expected_sig := base64.url_encode_str(real_sig.bytestr())
	if !constant_time_compare(parts[2], expected_sig) {
		return false
	}

	// 解码payload
	// payload_str := base64.url_decode_str(parts[1]) // or { return false }
	payload := json.decode[JwtPayload](base64.url_decode_str(parts[1])) or { return false }

	// 4. 时间验证
	now := time.now().unix()
	// 检查exp（过期时间）和nbf（生效时间）
	if now >= payload.exp || now < payload.nbf {
		return false
	}

	return true
}

// 解析 JWT token（不验证签名，只解析 payload）
pub fn jwt_decode(token string) !JwtPayload {
	parts := token.split('.')
	if parts.len != 3 {
		return error('Invalid JWT format: expected 3 parts, got ${parts.len}')
	}
	// 解析 JSON
	payload := json.decode[JwtPayload](base64.url_decode_str(parts[1])) or {
		return error('Failed to parse JWT payload JSON: ${err}')
	}
	return payload
}

// 恒定时间比较
fn constant_time_compare(a string, b string) bool {
	// 将长度差异转换为非零值（若长度不同）
	mut diff := a.len ^ b.len
	// 取最大长度确保循环次数一致
	max_len := if a.len > b.len { a.len } else { b.len }

	for i in 0 .. max_len {
		// 安全获取字符（若索引越界则返回0）
		a_char := if i < a.len { a[i] } else { u8(0) }
		b_char := if i < b.len { b[i] } else { u8(0) }
		// 累积差异：任何不匹配的字节会将diff变为非零
		diff |= int(a_char) ^ int(b_char)
	}
	// 只有长度和所有字节完全相同时diff才为0
	return diff == 0
}

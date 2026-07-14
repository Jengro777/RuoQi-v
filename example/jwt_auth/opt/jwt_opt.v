module opt

// JWT标准声明 (Standard Claims) https://datatracker.ietf.org/doc/html/rfc7519#section-4.1
import crypto.hmac
import crypto.sha256
import encoding.base64
import json2 as json
import time
import rand

// JWT 头部固定使用HS256算法 [使用这种方式，编译器会产生c错误]
const header_opt = base64.url_encode_str(json.encode(JwtHeader{
	alg: 'HS256'
	typ: 'JWT'
}))

//*>>>>>>>>>>>>>captcha_jwt>>>>>>>>>>>>>*/
const opt_secret = 'd8a3b1f0-6e7b-4c9a-9f2d-1c3e5f7a8b4c' //固定值，JWT有效性验证时使用

fn random_num() string {
	gen_random := fn () int {
		mut r := rand.new_default()
		return r.int_in_range(10000, 100000) or { 0 }
	}()
	return gen_random.str()
}

//生成captcha_opt令牌
pub fn opt_generate() (string, string) {
	opt_num := random_num().str()

	payload_captcha := JwtPayload{
		iss: 'ruoqi-v' // 签发者 (Issuer) your-app-name
		sub: 'captcha' // captcha唯一标识 (Subject)
		// aud: ['api-service', 'client'] // 接收方 (Audience)，可以是数组或字符串
		exp: time.now().add_seconds(120).unix() // 过期时间 (Expiration Time) 120秒后
		nbf: time.now().unix() // 生效时间 (Not Before)，立即生效
		iat: time.now().unix() // 签发时间 (Issued At)
		jti: rand.uuid_v4() // JWT唯一标识 (JWT ID)，防重防攻击
		// 自定义业务字段 (Custom Claims)
		opt_text: opt_num // 验证码
	}

	playload_64 := base64.url_encode_str(json.encode(payload_captcha))

	message := '${header_opt}.${playload_64}'
	signature := hmac.new(opt_secret.bytes(), message.bytes(), sha256.sum, 64)
	base64_signature := base64.url_encode_str(signature.bytestr())

	return '${header_opt}.${playload_64}.${base64_signature}', opt_num
}

// 验证opt令牌
pub fn opt_verify(token string, opt_num string) bool {
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
	real_sig := hmac.new(opt_secret.bytes(), message.bytes(), sha256.sum, 64)
	expected_sig := base64.url_encode_str(real_sig.bytestr())
	if !constant_time_compare(parts[2], expected_sig) {
		return false
	}
	// 解码payload
	// c := base64.url_decode_str(parts[1]) // or { return false }
	payload := json.decode[JwtPayload](base64.url_decode_str(parts[1])) or { return false }

	// 4. 时间验证
	now := time.now().unix()
	// 检查exp（过期时间）和nbf（生效时间）
	if now >= payload.exp || now < payload.nbf {
		return false
	}
	// 验证 opt
	if opt_num != payload.opt_text {
		return false
	}
	return true
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

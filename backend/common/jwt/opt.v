// ==============================================================================
// opt.v — 一次性验证码（OTP）JWT 模块（替代 common/opt）
//
// 对外 API 与原 common/opt 完全一致：
//   OptPayload                      — OTP token 的 payload
//   opt_generate() (string, string) — 签发，返回 (token, opt_num)
//   opt_verify(token, opt_num)      — 验证
// ==============================================================================
module jwt

import time
import rand

// OptPayload  嵌入 BasePayload（标准声明），再追加 OTP 业务字段。
pub struct OptPayload {
	BasePayload
pub:
	opt_text string
}

// opt_generate 生成有效期 120 秒的 OTP JWT token。
pub fn opt_generate() (string, string) {
	opt_num := random_num().str()
	now := time.now()
	payload := OptPayload{
		BasePayload: BasePayload{
			iss: 'ruoqi-v'
			sub: 'opt'
			exp: now.add_seconds(120).unix()
			nbf: now.unix()
			iat: now.unix()
			jti: rand.uuid_v4()
		}
		opt_text:    opt_num
	}
	token := sign_payload[OptPayload](jwt_secret, payload)
	return token, opt_num
}

// opt_verify 验证 OTP JWT token 并比对验证码值。
pub fn opt_verify(token string, opt_num string) bool {
	payload := verify_and_decode[OptPayload](jwt_secret, token) or { return false }
	return payload.opt_text == opt_num
}

// ---- internal helpers ----------------------------------------------------------

fn random_num() int {
	mut r := rand.new_default()
	for _ in 0 .. 100 {
		num := r.int_in_range(10000, 100000) or { continue }
		return num
	}
	// Fallback — should never reach here under normal conditions
	return 10000 + int(time.now().unix() % 90000)
}

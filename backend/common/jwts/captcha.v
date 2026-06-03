// ==============================================================================
// captcha.v — 图形验证码 JWT 模块（替代 common/captcha）
//
// 对外 API 与原 common/captcha 完全一致：
//   CaptchaPayload                           — captcha token 的 payload
//   generate_captcha() Captcha               — 生成验证码图片
//   captcha_generate() !(string, string, string) — 签发，返回 (token, image, text)
//   captcha_verify(token, captcha_text)        — 验证
// ==============================================================================
module jwts

import time
import rand
import encoding.base64

// CaptchaPayload  嵌入 BasePayload（标准声明），再追加 captcha 业务字段。
pub struct CaptchaPayload {
	BasePayload
pub:
	captcha_text  string
	captcha_image string
}

// captcha_generate 生成有效期 120 秒的图形验证码 JWT token。
pub fn captcha_generate() !(string, string, string) {
	captch_obj := generate_captcha()
	now := time.now()
	payload := CaptchaPayload{
		BasePayload:  BasePayload{
			iss: 'ruoqi-v'
			sub: 'captcha'
			exp: now.add_seconds(120).unix()
			nbf: now.unix()
			iat: now.unix()
			jti: rand.uuid_v4()
		}
		captcha_text: captch_obj.text
	}
	token := sign_payload[CaptchaPayload](jwt_secret, payload)
	return token, captch_obj.image, captch_obj.text
}

// captcha_verify 验证 captcha JWT token 并比对用户输入。
pub fn captcha_verify(token string, captcha_text string) bool {
	payload := verify_and_decode[CaptchaPayload](jwt_secret, token) or { return false }
	return payload.captcha_text == captcha_text
}

// ---- Captcha 图片生成 ----------------------------------------------------------

// Captcha holds the text and base64-encoded SVG image of a captcha.
pub struct Captcha {
pub:
	text  string
	image string
}

// generate_captcha creates a random 4-character captcha image.
pub fn generate_captcha() Captcha {
	width := 120
	height := 40
	char_count := 4

	chars := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789@#%*'
	mut text := ''
	mut r := rand.new_default()
	for _ in 0 .. char_count {
		mut idx := 0
		for _ in 0 .. 10 {
			idx = r.int_in_range(0, chars.len) or { continue }
			break
		}
		text += chars[idx..idx + 1]
	}

	mut svg := '<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${height}" viewBox="0,0,${width},${height}">\n'

	// Background gradient
	svg += '<defs><linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
              <stop offset="0%" stop-color="#f8f9fa" />
              <stop offset="100%" stop-color="#e9ecef" />
            </linearGradient></defs>
            <rect width="100%" height="100%" fill="url(#bg)" />\n'

	// Interference lines
	for _ in 0 .. 5 {
		x1 := r.int_in_range(0, width) or { 0 }
		y1 := r.int_in_range(0, height) or { 0 }
		x2 := r.int_in_range(0, width) or { 0 }
		y2 := r.int_in_range(0, height) or { 0 }
		stroke := '#' + hex_color(mut r)
		svg += '<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="${stroke}" stroke-width="1" />\n'
	}

	// Noise dots
	for _ in 0 .. 50 {
		x := r.int_in_range(0, width) or { 0 }
		y := r.int_in_range(0, height) or { 0 }
		svg += '<circle cx="${x}" cy="${y}" r="1" fill="#495057" />\n'
	}

	// Text
	font_size := 24
	total_text_width := font_size * text.len
	start_x := (width - total_text_width) / 2 + 10
	start_y := height / 2 + font_size / 3

	for i in 0 .. text.len {
		ch := text[i..i + 1]
		char_x := start_x + i * (font_size - 2)
		char_y := start_y + r.int_in_range(0, 8) or { 0 } - 4
		rotate := r.int_in_range(0, 20) or { 0 } - 10
		fill := '#' + hex_color(mut r)

		svg += '<text x="${char_x}" y="${char_y}" font-family="Arial" font-size="${font_size}"
                fill="${fill}" transform="rotate(${rotate},${char_x},${char_y})"
                font-weight="bold" text-anchor="middle" dominant-baseline="middle">${ch}</text>\n'
	}

	svg += '</svg>'

	return Captcha{
		text:  text
		image: 'data:image/svg+xml;base64,' + base64.encode_str(svg)
	}
}

// hex_color generates a random 6-character hex colour string.
fn hex_color(mut r rand.PRNG) string {
	mut color := ''
	for _ in 0 .. 6 {
		idx := r.int_in_range(0, 16) or { 0 }
		color += '0123456789ABCDEF'[idx..idx + 1]
	}
	return color
}

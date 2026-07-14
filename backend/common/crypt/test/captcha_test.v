// ==============================================================================
// captcha_test.v — 图形验证码测试
// 对应 captcha.v：CaptchaPayload / captcha_generate / captcha_verify / generate_captcha
// ==============================================================================
module test

import common.crypt

const test_jwt_secret = 'test-jwt-secret'

// ---- captcha_generate -------------------------------------------------------

fn test_captcha_generate() {
	token, captcha_image, captcha_text := crypt.captcha_generate(test_jwt_secret)!
	dump(token)
	dump('${captcha_image[..50]}...')
	dump(captcha_text)
	// 类型断言
	assert typeof(token).name == 'string'
	assert typeof(captcha_image).name == 'string'
	assert typeof(captcha_text).name == 'string'
	// 内容断言
	assert token != ''
	assert captcha_text.len == 4
}

// ---- captcha_verify ---------------------------------------------------------

fn test_captcha_verify() {
	token, _, captcha_text := crypt.captcha_generate(test_jwt_secret)!
	verify := crypt.captcha_verify(test_jwt_secret, token, captcha_text)
	assert verify == true
}

fn test_captcha_verify_wrong_text() {
	token, _, _ := crypt.captcha_generate(test_jwt_secret)!
	assert crypt.captcha_verify(test_jwt_secret, token, 'XXXX') == false
}

fn test_captcha_verify_tampered_header() {
	token, _, text := crypt.captcha_generate(test_jwt_secret)!
	parts := token.split('.')
	tampered := 'BADHEADER.${parts[1]}.${parts[2]}'
	assert crypt.captcha_verify(test_jwt_secret, tampered, text) == false
}

// ---- generate_captcha ------------------------------------------------------

fn test_generate_captcha() {
	c := crypt.generate_captcha()
	dump('验证码文本: ${c.text}')
	dump('图像数据: ${c.image[..50]}...')
	assert c.text.len == 4
	assert typeof(c.image).name == 'string'
	assert c.image.starts_with('data:image/svg+xml;base64,')
	assert c.image.len > 100
}

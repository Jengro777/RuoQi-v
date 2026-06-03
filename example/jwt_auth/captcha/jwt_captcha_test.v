module captcha

fn test_captcha_generate() {
	token, captcha_image, captcha_text := captcha_generate()!
	dump(token)
	dump('${captcha_image[..50]}...')
	dump(captcha_text)
	assert token != ''
	assert typeof(token).name == 'string'
	assert typeof(token).name.len > 0
	assert typeof(captcha_image).name == 'string'
	assert typeof(captcha_text).name == 'string'
	assert captcha_text.len == 4
}

fn test_captcha_verify() {
	token, _, captcha_text := captcha_generate()!
	dump(token)
	dump(captcha_text)
	verify := captcha_verify(token, captcha_text)
	assert verify == true
}

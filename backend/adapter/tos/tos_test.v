module tos

import encoding.base64
import net.http

fn test_encrypt_password_not_empty() {
	encrypted := encrypt_password('123456')
	assert encrypted.len > 0

	decoded := base64.decode(encrypted)
	assert decoded.len % 16 == 0
}

fn test_encrypt_password_empty() {
	encrypted := encrypt_password('')
	assert encrypted.len > 0

	decoded := base64.decode(encrypted)
	assert decoded.len % 16 == 0
}

fn test_encrypt_password_long() {
	encrypted := encrypt_password('this is a very long password that exceeds sixteen bytes')
	assert encrypted.len > 0

	decoded := base64.decode(encrypted)
	assert decoded.len % 16 == 0
}

fn test_encrypt_deterministic() {
	r1 := encrypt_password('testpass')
	r2 := encrypt_password('testpass')
	assert r1 == r2
}

fn test_encrypt_different_inputs() {
	r1 := encrypt_password('password1')
	r2 := encrypt_password('password2')
	assert r1 != r2
}

fn test_new_client() {
	client := new_client('testuser', 'testpass')
	assert client.username == 'testuser'
	assert client.password == 'testpass'
	assert client.base_url == 'https://oauthapi-test.tospinomall.com'
}

fn test_new_client_defaults() {
	client := new_client('', '')
	assert client.username == 'apm001'
	assert client.password == '123456'
	assert client.base_url == 'https://oauthapi-test.tospinomall.com'
}

fn test_new_client_partial_defaults() {
	client := new_client('custom_user', '')
	assert client.username == 'custom_user'
	assert client.password == '123456'
}

fn test_build_login_request_url_method() {
	client := new_client('apm001', '123456')
	req := client.build_login_request()

	assert req.url == 'https://oauthapi-test.tospinomall.com/auth/oauth/token?grant_type=password'
	assert req.method == .post
}

fn test_build_login_request_headers() {
	client := new_client('apm001', '123456')
	req := client.build_login_request()

	assert req.header.get(.authorization) or { '' } == 'Basic b3BlcmF0b3I6b3BlcmF0b3I='
	assert req.header.get(.content_type) or { '' } == 'application/x-www-form-urlencoded'
	assert req.header.get_custom('ClientType', http.HeaderQueryConfig{}) or { '' } == 'web'
	assert req.header.get_custom('Language', http.HeaderQueryConfig{}) or { '' } == 'zh-CN'
	assert req.header.get_custom('Site', http.HeaderQueryConfig{}) or { '' } == 'ghana'
}

fn test_build_login_request_body() {
	client := new_client('apm001', '123456')
	req := client.build_login_request()
	body := req.data

	assert body.contains('username=apm001')
	assert body.contains('password=')
	assert body.len > 'username=apm001&password='.len
}

fn test_login_and_print_token() {
	client := new_client('', '')
	encrypted := encrypt_password(client.password)
	println('账号：${client.username}')
	println('原始密码：${client.password}')
	println('加密后：${encrypted}')

	token := client.login() or {
		println('login failed: ${err}')
		assert false
		return
	}
	println('')
	println('获取到 access token: ${token}')
	assert token.len > 0
}

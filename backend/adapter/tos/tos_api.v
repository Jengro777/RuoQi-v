// ==================== adapter/tos - Tospino Mall 外部认证客户端 ====================
// 底层依赖: crypto.aes / crypto.cipher / encoding.base64 / net.http / x.json2 / common.api
// 职责: 封装与 Tospino OAuth2 服务的 HTTP 通信，提供登录接口

module tos

import common.api
import crypto.aes
import crypto.cipher
import encoding.base64
import net.http
import x.json2 as json

// ----------------- 常量 -----------------

const aes_key = 'tospinomallkeyiv'
const aes_iv = 'tospinomallkeyiv'
const auth_token = 'b3BlcmF0b3I6b3BlcmF0b3I='

// ----------------- DTO - 外部接口数据结构 -----------------

// TokenData 外部认证接口返回的令牌数据
pub struct TokenData {
	access_token string @[json: 'access_token']
}

// LoginResponse 外部认证接口的完整响应结构
pub struct LoginResponse {
	code int       @[json: 'code']
	msg  string    @[json: 'msg']
	data TokenData @[json: 'data']
}

// ----------------- 加密工具 -----------------

// pad_pkcs7 对数据进行 PKCS7 填充，补齐至 16 字节（AES 块大小）
fn pad_pkcs7(data []u8) []u8 {
	mut result := data.clone()
	padding := 16 - (result.len % 16)
	for _ in 0 .. padding {
		result << u8(padding)
	}
	return result
}

// encrypt_password 使用 AES-CBC 加密密码，返回 Base64 编码密文
pub fn encrypt_password(password string) string {
	mut fixed_key := []u8{len: 16, init: 0}
	mut fixed_iv := []u8{len: 16, init: 0}
	for i in 0 .. 16 {
		if i < aes_key.len {
			fixed_key[i] = aes_key[i]
		}
		if i < aes_iv.len {
			fixed_iv[i] = aes_iv[i]
		}
	}

	block := aes.new_cipher(fixed_key)
	mut cbc := cipher.new_cbc(block, fixed_iv)

	plaintext := pad_pkcs7(password.bytes())
	mut encrypted := []u8{len: plaintext.len}
	cbc.encrypt_blocks(mut encrypted, plaintext)

	return base64.encode(encrypted)
}

// ----------------- API 客户端 -----------------

// TosClient 外部认证服务 HTTP 客户端
pub struct TosClient {
	base_url string
	username string
	password string
}

// new_client 创建 TosClient 实例，未提供账号密码时使用默认值
pub fn new_client(username string, password string) TosClient {
	return TosClient{
		base_url: 'https://oauthapi-test.tospinomall.com'
		username: if username != '' { username } else { 'apm001' }
		password: if password != '' { password } else { '123456' }
	}
}

// build_login_request 构造登录 HTTP 请求（可独立单元测试）
pub fn (c TosClient) build_login_request() http.Request {
	encrypted_password := encrypt_password(c.password)
	data := 'username=${c.username}&password=${encrypted_password}'

	mut req := http.new_request(.post, '${c.base_url}/auth/oauth/token?grant_type=password', data)

	req.add_custom_header('Authorization', 'Basic ${auth_token}') or {}
	req.add_custom_header('Content-Type', 'application/x-www-form-urlencoded') or {}
	req.add_custom_header('ClientType', 'web') or {}
	req.add_custom_header('Language', 'zh-CN') or {}
	req.add_custom_header('Site', 'ghana') or {}

	return req
}

// login 使用密码模式获取 access_token
// 返回: token 字符串，或标准化错误
pub fn (c TosClient) login() !string {
	req := c.build_login_request()

	resp := req.do() or { return error(api.json_error_500('请求失败：${err}').error) }

	if resp.status_code != 200 {
		return error(api.json_error_400('HTTP 错误：${resp.status_code}').error)
	}

	result := json.decode[LoginResponse](resp.body) or {
		return error(api.json_error_500('解析响应失败：${err}').error)
	}

	if result.code != 0 {
		return error(api.json_error_422(result.msg).error)
	}

	return result.data.access_token
}

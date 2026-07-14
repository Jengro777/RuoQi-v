// ==============================================================================
// auth.v — 认证会话 JWT 模块（替代 common/jwt）
//
// 对外 API 与原 common/jwt 完全一致：
//   AuthPayload                       — 认证 token 的 payload
//   auth_generate(secret, payload)    — 签发
//   auth_verify(secret, token)        — 验证（含时间校验）
//   auth_decode(token)                — 解析 payload（不验证签名）
// ==============================================================================
module crypt

// AuthPayload  嵌入 BasePayload（标准声明），追加认证业务字段。
pub struct AuthPayload {
	BasePayload
pub:
	role_ids  []string // 角色数组
	client_ip string   // 客户端 IP
	device_id string   // 设备 ID
}

// auth_generate 签发认证 JWT token。
pub fn auth_generate(secret string, payload AuthPayload) string {
	return sign_payload[AuthPayload](secret, payload)
}

// auth_verify 完整校验认证 JWT token（header / 签名 / 有效期）。
pub fn auth_verify(secret string, token string) bool {
	_ := verify_and_decode[AuthPayload](secret, token) or { return false }
	return true
}

// auth_decode 解析认证 JWT payload（不验证签名）。
// 调用方应先使用 auth_verify 或 verify_and_decode 完成签名和时间校验。
pub fn auth_decode(token string) !AuthPayload {
	return decode_payload[AuthPayload](token)
}

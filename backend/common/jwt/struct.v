// ==============================================================================
// struct.v — jwts 模块的共享类型与常量
//
//   JwtHeader        — JWT 头部（RFC 7515 §4.1）
//   BasePayload      — JWT 注册声明（RFC 7519 §4.1）
//   JwtTimeBounded   — 时间校验接口（供 verify_and_decode 泛型使用）
//   jwt_secret       — opt / captcha 签名密钥
// ==============================================================================
module jwt

pub struct JwtHeader {
pub:
	alg string @[required] // 签名算法，固定 'HS256'
	typ string @[required] // token 类型，固定 'JWT'
	cty string // 嵌套内容的 MIME 类型，可选
}

pub struct BasePayload {
pub:
	iss string   @[default: 'ruoqi-v'] // Issuer         签发方
	sub string   @[required]           // Subject        用户唯一标识
	aud []string @[omitempty]          // Audience       目标接收方['app.mall.com']
	exp i64      @[required]           // Expires        过期时刻 (unix)
	nbf i64      @[required]           // Not Before     生效时刻 (unix)
	iat i64      @[required]           // Issued At      签发时刻 (unix)
	jti string   @[required]           // JWT ID         防重放唯一标识
}

// ---- JwtTimeBounded -----------------------------------------------------------
// 任何嵌入 BasePayload 的 struct 都自动满足此接口，
// verify_and_decode 通过它将泛型的 payload 转型后做时间校验。

pub interface JwtTimeBounded {
	exp i64
	nbf i64
}

// ---- 密钥 --------------------------------------------------------------------
// TODO: 后续从配置读取。

pub const jwt_secret = 'd8a3b1f0-6e7b-4c9a-9f2d-1c3e5f7a8b4c'

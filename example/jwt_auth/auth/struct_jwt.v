module auth

pub struct JwtHeader {
pub:
	alg string // 加密(algorithm)：'HS256'，"none"
	typ string // (Type) Header Parameter
	cty string // (Content Type) Header Parameter
}

pub struct JwtPayload {
pub:
	// 标准声明
	iss string   @[default: 'ruoqi-v'; required] // 签发者 (Issuer) App名称
	sub string   @[required]                     // 接收方-用户唯一标识 (Subject)  用户id
	aud []string @[omitempty]                    // ['app.mall.com'] 接收方 (Audience)，可以是数组或字符串. 该令牌预期被哪些服务或应用使用
	nbf i64      @[required]                     // 生效时间 (Not Before)，立即生效
	exp i64      @[required]                     // 过期时间 (Expiration Time) 7天后
	iat i64      @[required]                     // 签发时间 (Issued At)
	jti string   @[required]                     // JWT唯一标识 (JWT ID)，防重防攻击

	// 自定义声明
	// ^^^^^^ 角色数组 ^^^^^^
	role_ids []string
	//^^^^^^ API开放平台独立鉴权必须 ^^^^^^^^^^^^
	client_ip string // 客户端 IP
	device_id string // 设备 ID
}

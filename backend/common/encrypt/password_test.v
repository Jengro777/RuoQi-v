module encrypt

// ==========================================================
// 测试 bcrypt + SHA256 模块
// ==========================================================

fn test_bcrypt_hash() {
	// 测试生成 bcrypt hash
	raw := '123456'
	client_sha := sha256_hex(client_salt + raw) // 生成 SHA256 hex

	hash := bcrypt_hash(client_sha) or { panic(err) } // 生成 bcrypt hash

	// 打印 SHA256 和 bcrypt hash
	println('Raw password: ${raw}')
	println('SHA256(client_salt + raw): ${client_sha}')
	println('Bcrypt hash: ${hash}')

	assert hash.len > 0 // 确保 hash 不为空
	assert hash != raw // hash 与原始密码不同
}

fn test_bcrypt_verify() {
	// 测试 bcrypt 验证
	raw := '123456'
	client_sha := sha256_hex('${client_salt}${raw}')
	stored_hash := bcrypt_hash(client_sha) or { panic(err) }

	// 打印信息
	println('Raw password: ${raw}')
	println('SHA256(client_salt + raw): ${client_sha}')
	println('Stored bcrypt hash: ${stored_hash}')

	// ✅ 正确密码验证成功
	assert bcrypt_verify(client_sha, stored_hash)

	// ❌ 错误密码验证失败
	wrong := sha256_hex('${client_salt}wrongpass')
	assert !bcrypt_verify(wrong, stored_hash)

	// ❌ 非 SHA256 格式输入
	assert !bcrypt_verify('zzzz', stored_hash)

	// ❌ 空字符串输入
	assert !bcrypt_verify(client_sha, '')
	assert !bcrypt_verify('', stored_hash)
}

fn test_bcrypt_hash_empty_password() {
	// 测试空密码会报错
	_ := bcrypt_hash('') or {
		assert err.msg() == 'empty password hash'
		return
	}
	assert false // 如果没有报错，测试失败
}

fn test_invalid_sha_format() {
	// 测试 SHA256 hex 格式检查
	assert !is_sha256('abc123') // 长度不够
	assert !is_sha256('FFFF') // 长度不够
	assert is_sha256(sha256_hex('test')) // 正确格式
}

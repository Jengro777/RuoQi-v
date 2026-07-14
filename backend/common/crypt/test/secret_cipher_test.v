// ==============================================================================
// secret_cipher_test.v — SecretKey 加解密测试
// 对应 secret_cipher.v：aes_encrypt / aes_decrypt
// ==============================================================================
module test

import common.crypt

// ---- roundtrip --------------------------------------------------------------

fn test_secret_cipher_roundtrip() {
	sk := 'sk-0123456789abcdef'
	master_key := 'test-master-key'
	encrypted := crypt.aes_encrypt(sk, master_key)!
	assert encrypted != ''
	assert encrypted != sk
	assert crypt.aes_decrypt(encrypted, master_key)! == sk
}

fn test_secret_cipher_long_sk() {
	sk := 'sk-${`A`.repeat(128)}'
	master_key := 'long-key-test'
	encrypted := crypt.aes_encrypt(sk, master_key)!
	assert crypt.aes_decrypt(encrypted, master_key)! == sk
}

// ---- error paths ------------------------------------------------------------

fn test_secret_cipher_wrong_key() {
	sk := 'sk-secret-value-12345'
	encrypted := crypt.aes_encrypt(sk, 'key-a')!
	// 用错误密钥解密，结果不应匹配
	result := crypt.aes_decrypt(encrypted, 'key-b')!
	assert result != sk
}

fn test_secret_cipher_too_short() {
	_ := crypt.aes_decrypt('short', 'any-key') or {
		assert true
		return
	}
	assert false, 'aes_decrypt should fail for too-short ciphertext'
}

fn test_secret_cipher_invalid_base64() {
	_ := crypt.aes_decrypt('!!!not-valid-base64!!!', 'key') or {
		assert true
		return
	}
	assert false, 'aes_decrypt should fail for invalid base64'
}

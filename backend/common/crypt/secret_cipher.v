// ==============================================================================
// secret_cipher.v — API Key SK 可逆存储加密
//
// API 请求签名验证需要取回原始 SK，因此数据库中保存 SK 的加密密文。
// 当前实现使用 AES-256-CTR，master_key 经 SHA-256 派生为 32 字节密钥。
// ==============================================================================
module crypt

import crypto.aes
import crypto.cipher
import crypto.rand
import crypto.sha256
import encoding.base64

// aes_encrypt 使用 master_key 加密 SecretKey，返回 Base64 密文（AES-256-CTR）
pub fn aes_encrypt(sk string, master_key string) !string {
	key_bytes := sha256.sum(master_key.bytes())
	block := aes.new_cipher(key_bytes)
	iv := rand.bytes(aes.block_size)!
	mut ctr := cipher.new_ctr(block, iv)
	mut plaintext := sk.bytes()
	mut ciphertext := []u8{len: plaintext.len}
	ctr.xor_key_stream(mut ciphertext, plaintext)

	mut out := []u8{len: aes.block_size + ciphertext.len}
	for i := 0; i < aes.block_size; i++ {
		out[i] = u8(iv[i])
	}
	for i := 0; i < ciphertext.len; i++ {
		out[aes.block_size + i] = ciphertext[i]
	}
	return base64.encode(out)
}

// aes_decrypt 解密 aes_encrypt 的输出，返回 SecretKey 明文
pub fn aes_decrypt(encrypted string, master_key string) !string {
	key_bytes := sha256.sum(master_key.bytes())
	block := aes.new_cipher(key_bytes)
	data := base64.decode(encrypted)
	if data.len < aes.block_size {
		return error('invalid ciphertext: too short')
	}

	iv := data[..aes.block_size]
	ciphertext := data[aes.block_size..]
	mut ctr := cipher.new_ctr(block, iv)
	mut plaintext := []u8{len: ciphertext.len}
	ctr.xor_key_stream(mut plaintext, ciphertext)
	return plaintext.bytestr()
}

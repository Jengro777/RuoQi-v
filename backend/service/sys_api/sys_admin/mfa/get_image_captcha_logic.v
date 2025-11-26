/*
无状态验证码（Stateless CAPTCHA）
核心思路:
  1、不存储验证码答案，而是将答案加密后发送给客户端
  2、客户端提交时，服务器解密并验证
方案:
1、JWT
2、哈希挑战
*/

//使用JWT生成无状态图片验证码
// 用户认证模块 auth: authentication
module mfa

import veb
import log
import common.api
import structs { Context }
import common.captcha

// ----------------- Handler 层 -----------------
@['/captcha'; get; post]
pub fn (app &MFA) get_captcha_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	result := get_captcha_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success(code: 200, data: result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_captcha_usecase(mut ctx Context) !GetCaptchaResp {
	// Domain 层校验（这里可以扩展）
	get_captcha_domain()!

	// 调用 Repository / Adapter 层生成验证码
	return get_captcha(mut ctx)
}

// ----------------- Domain 层 -----------------
fn get_captcha_domain() ! {
	// 目前无复杂校验，保留扩展点
}

// ----------------- DTO 层 -----------------
pub struct GetCaptchaResp {
	captcha_token string @[json: 'captchaToken']
	captcha_image string @[json: 'captchaImage']
}

// ----------------- Repository / Adapter 层 -----------------
fn get_captcha(mut ctx Context) !GetCaptchaResp {
	captcha_token, captcha_image, captcha_text := captcha.captcha_generate() or {
		return error('Failed to generate captcha')
	}

	log.debug('Generated captcha text: ${captcha_text}')

	return GetCaptchaResp{
		captcha_token: captcha_token
		captcha_image: captcha_image
	}
}

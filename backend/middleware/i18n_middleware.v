module middleware

import veb
import log
import structs { Context }
import i18n

pub fn i18n_middleware(i18n_app &i18n.I18nStore) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [i18n_app] (mut ctx Context) bool {
			// 绑定 i18n
			ctx.i18n = i18n_app
			i18n.maybe_reload(mut ctx.i18n)

			// 获取语言头部信息
			lang_header := ctx.req.header.get(.accept_language) or { ctx.i18n.default_lang }

			// 解析并标准化语言代码（如 en-US -> en）
			mut lang := parse_accept_language(lang_header, ctx.i18n)

			// 实际设置语言
			ctx.i18n.set_language(lang)

			// 设置语言到 extra_i18n 中
			ctx.extra_i18n['lang'] = lang

			return true // 继续处理请求
		}
	}
}

fn parse_accept_language(header string, s &i18n.I18nStore) string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	for part in header.split(',') {
		code := part.split(';')[0].trim_space().split('-')[0] // 提取 en-US -> en
		if code in s.translations.keys() {
			return code
		}
	}
	return s.default_lang // 如果没有找到匹配的语言，使用默认语言
}

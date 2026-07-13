module middleware

import veb
import log
import structs { Context }
import locale

pub fn locale_middleware(locale_app &locale.LocaleStore) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [locale_app] (mut ctx Context) bool {
			// 绑定 locale
			ctx.locale = locale_app
			locale.maybe_reload(mut ctx.locale)

			// 获取语言头部信息
			lang_header := ctx.req.header.get(.accept_language) or { ctx.locale.default_lang }

			// 解析并标准化语言代码（如 en-US -> en）
			mut lang := parse_accept_language(lang_header, ctx.locale)

			// 实际设置语言
			ctx.locale.set_language(lang)

			// 设置语言到 extra_locale 中
			ctx.extra_locale['lang'] = lang

			return true // 继续处理请求
		}
	}
}

fn parse_accept_language(header string, s &locale.LocaleStore) string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	for part in header.split(',') {
		code := part.split(';')[0].trim_space().split('-')[0] // 提取 en-US -> en
		if code in s.translations.keys() {
			return code
		}
	}
	return s.default_lang // 如果没有找到匹配的语言，使用默认语言
}

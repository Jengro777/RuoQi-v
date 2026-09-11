module model

import locale

fn test_ctx_t_delegates_to_locale() {
	locale_app := &locale.LocaleStore{
		default_lang: 'en'
		current_lang: 'zh'
		translations: {
			'en': {
				'hello': 'Hello'
			}
			'zh': {
				'hello': '你好'
			}
		}
	}
	ctx := &Context{
		dbpool: unsafe { nil }
		config: unsafe { nil }
		locale: locale_app
	}

	// 命中当前语言
	assert ctx.t('hello') or { '' } == '你好'
	// 未命中时走调用方的静态文案兜底
	assert ctx.t('not_exist') or { '成功' } == '成功'
	// 未命中且没有兜底时是 none
	assert ctx.t('not_exist') == none
	// 与 ctx.locale.t 行为一致
	assert ctx.locale.t('hello') or { '' } == '你好'
}

fn test_ctx_t_without_locale_middleware() {
	// locale 中间件未生效时不能 panic，直接返回 none
	ctx := &Context{
		dbpool: unsafe { nil }
		config: unsafe { nil }
		locale: unsafe { nil }
	}
	assert ctx.t('hello') == none
	assert ctx.t('hello') or { 'hello' } == 'hello'
}

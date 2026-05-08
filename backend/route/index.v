module route

import veb
import log
import common.api
import structs { Context }
import os

@['/get'; get]
pub fn (mut app AliasApp) get(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	dump(ctx.config)
	dump(ctx.config.web.port)
	return ctx.json(api.json_success(code: 200, data: 'req success'))
}

@['/static/403'; get; post]
fn (mut app AliasApp) index_403(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'static/403.html')
	html_content := os.read_file(file_path) or {
		return ctx.html('<h1>403 Forbidden</h1><p>错误页面未找到</p>')
	}

	// 读取CSS文件并内联
	css_path := os.join_path(os.getwd(), 'static/styles.css')
	css_content := os.read_file(css_path) or { '' }

	// 将CSS内联到HTML中
	final_html := html_content.replace('</head>', '<style>${css_content}</style></head>')

	return ctx.html(final_html)
}

@['/static/404'; get; post]
fn (mut app AliasApp) index_404(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'static/404.html')
	html_content := os.read_file(file_path) or {
		return ctx.html('<h1>404 Not Found</h1><p>错误页面未找到</p>')
	}

	// 读取CSS文件并内联
	css_path := os.join_path(os.getwd(), 'static/styles.css')
	css_content := os.read_file(css_path) or { '' }

	// 将CSS内联到HTML中
	final_html := html_content.replace('</head>', '<style>${css_content}</style></head>')

	return ctx.html(final_html)
}

@['/static/500'; get; post]
fn (mut app AliasApp) index_500(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'static/500.html')
	html_content := os.read_file(file_path) or {
		return ctx.html('<h1>500 Internal Server Error</h1><p>服务器内部错误</p>')
	}

	// 读取CSS文件并内联
	css_path := os.join_path(os.getwd(), 'static/styles.css')
	css_content := os.read_file(css_path) or { '' }

	// 将CSS内联到HTML中
	final_html := html_content.replace('</head>', '<style>${css_content}</style></head>')

	return ctx.html(final_html)
}

@['/index'; get; post]
fn (mut app AliasApp) index(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'static/index.html')
	html_content := os.read_file(file_path) or {
		return ctx.html('<h1>index Not Found</h1><p>index页面未找到</p>')
	}

	// 读取CSS文件并内联
	css_path := os.join_path(os.getwd(), 'static/styles.css')
	css_content := os.read_file(css_path) or { '' }

	// 将CSS内联到HTML中
	final_html := html_content.replace('</head>', '<style>${css_content}</style></head>')

	return ctx.html(final_html)
}

// curl -H "Accept-Language: en" --compressed http://localhost:9009/i18n
// curl -H "Accept-Language: zh" --compressed http://localhost:9009/i18n
@['/i18n'; get]
pub fn (app &AliasApp) i18n(mut ctx Context) veb.Result {
	result := {
		'success':        ctx.i18n.t('common.success')
		'create_success': ctx.i18n.t('common.createSuccess')
		'init':           ctx.i18n.t('init.alreadyInit')
	}
	return ctx.json(result)
}

// http://localhost:9009/rapidoc 打开 RapiDoc API 文档
@['/rapidoc'; get]
fn (mut app AliasApp) rapidoc(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'openapi/rapidoc.html')
	html_content := os.read_file(file_path) or {
		return ctx.html('<h1>OpenAPI 文档未生成</h1><p>请先运行: v run openapi/openapi_generate.vsh</p>')
	}
	return ctx.html(html_content)
}

// http://localhost:9009/redoc 打开 Redoc API 文档
@['/redoc'; get]
fn (mut app AliasApp) redoc(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'openapi/redoc.html')
	html_content := os.read_file(file_path) or { return ctx.html('<h1>Redoc 页面未找到</h1>') }
	return ctx.html(html_content)
}

// http://localhost:9009/elements 打开 Stoplight Elements API 文档
@['/sleapidoc'; get]
fn (mut app AliasApp) stoplight_elements(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'openapi/stoplight_elements.html')
	html_content := os.read_file(file_path) or {
		return ctx.html('<h1>Elements 页面未找到</h1>')
	}
	return ctx.html(html_content)
}

// http://localhost:9009/openapi.json 获取 OpenAPI JSON 数据
@['/openapi.json'; get]
fn (mut app AliasApp) openapi_json(mut ctx Context) veb.Result {
	file_path := os.join_path(os.getwd(), 'etc/openapi.json')
	content := os.read_file(file_path) or {
		return ctx.json(api.json_error(
			code:   404
			status: 404
			error:  'OpenAPI spec not found. Run: v run openapi/openapi_generate.vsh'
		))
	}
	ctx.set_content_type('application/json')
	return ctx.text(content)
}

// curl -H "Accept-Language: zh" --compressed http://localhost:9009/i18n/debug
@['/i18n/debug'; get]
pub fn (app &AliasApp) i18n_debug(mut ctx Context) veb.Result {
	// 获取语言，如果请求头中没有语言，则回退到默认语言
	lang := ctx.extra_i18n['lang'] or { ctx.i18n.default_lang }

	// 获取当前语言的翻译数据，如果语言不存在则回退到默认语言
	translations := if lang in ctx.i18n.translations {
		ctx.i18n.translations[lang]
	} else {
		ctx.i18n.translations[ctx.i18n.default_lang]
	}

	// 构造结果并返回
	mut result := map[string]string{}
	for k, v in translations {
		result[k] = v
	}

	return ctx.json(result)
}

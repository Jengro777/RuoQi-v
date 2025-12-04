module main

import os
import x.json2 as json
import veb
import time

// ------------------------- Context -------------------------
pub struct Context {
	veb.Context
pub mut:
	extra_i18n map[string]string = map[string]string{}
	i18n       &I18nStore        = unsafe { nil }
}

// ------------------------- I18n -------------------------
@[heap]
pub struct I18nStore {
pub:
	default_lang string
	dir          string
pub mut:
	translations   map[string]map[string]string
	lang_cache     map[string]string
	mod_times      map[string]int
	last_check     i64
	check_interval i64 = 2000 // 毫秒
}

// 创建 I18nStore
pub fn new_i18n(dir string, default_lang string) !&I18nStore {
	mut s := &I18nStore{
		dir:          dir
		default_lang: default_lang
		translations: map[string]map[string]string{}
		lang_cache:   map[string]string{}
		mod_times:    map[string]int{}
		last_check:   0
	}
	load_translations(mut s)!
	return s
}

// ------------------------- 动态加载 + JSON 校验 + 日志 -------------------------
pub fn maybe_reload(mut s I18nStore) {
	now := time.now().unix()
	if now - s.last_check < s.check_interval / 1000 {
		return
	}
	s.last_check = now
	load_translations(mut s) or { eprintln('i18n load failed: ${err}') }
}

pub fn load_translations(mut s I18nStore) ! {
	if !os.exists(s.dir) {
		return
	}
	for file in os.ls(s.dir)! {
		if !file.ends_with('.json') {
			continue
		}
		full_path := os.join_path(s.dir, file)
		mod_time := int(os.file_last_mod_unix(full_path))

		if file in s.mod_times && s.mod_times[file] == mod_time {
			continue
		}

		content := os.read_file(full_path)!

		// JSON 解码，失败则跳过文件
		data := json.decode[map[string]json.Any](content) or {
			eprintln('i18n load failed for ${file}: ${err}')
			continue
		}

		lang := file.replace('.json', '')

		mut is_new := false
		if lang !in s.translations {
			s.translations[lang] = map[string]string{}
			is_new = true
		}

		flat := flatten_map(data, '')
		for k, v in flat {
			s.translations[lang][k] = v
		}

		s.mod_times[file] = mod_time

		// 打印加载日志
		println('i18n loaded: ${lang}, keys: ${s.translations[lang].len}, new: ${is_new}')
	}
}

// 查询翻译，支持 fallback
pub fn (s &I18nStore) t(lang string, key string) string {
	selected := if lang in s.translations.keys() { lang } else { s.default_lang }

	if key in s.translations[selected] {
		return s.translations[selected][key]
	}
	if key in s.translations[s.default_lang] {
		return s.translations[s.default_lang][key]
	}
	return key
}

// 展平成点号路径
fn flatten_map(data map[string]json.Any, prefix string) map[string]string {
	mut result := map[string]string{}
	for k, v in data {
		full_key := if prefix == '' { k } else { '${prefix}.${k}' }
		match v {
			string {
				result[full_key] = v
			}
			map[string]json.Any {
				sub := flatten_map(v, full_key)
				for sk, sv in sub {
					result[sk] = sv
				}
			}
			else {}
		}
	}
	return result
}

// ------------------------- Middleware -------------------------
pub fn i18n_middleware(i18n &I18nStore) veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: fn [i18n] (mut ctx Context) bool {
			// 绑定 i18n
			ctx.i18n = i18n
			maybe_reload(mut ctx.i18n)

			// 获取语言
			lang_header := ctx.req.header.get(.accept_language) or { ctx.i18n.default_lang }

			if lang := ctx.i18n.lang_cache[lang_header] {
				ctx.extra_i18n['lang'] = lang
			} else {
				lang := parse_accept_language(lang_header, ctx.i18n)
				ctx.extra_i18n['lang'] = lang
				ctx.i18n.lang_cache[lang_header] = lang
			}

			return true // 允许继续处理
		}
	}
}

fn parse_accept_language(header string, s &I18nStore) string {
	for part in header.split(',') {
		code := part.split(';')[0].trim_space()
		if code in s.translations.keys() {
			return code
		}
	}
	return s.default_lang
}

// ------------------------- App -------------------------
pub struct App {
	veb.Middleware[Context]
}

// ------------------------- 路由 -------------------------
@['/'; get]
pub fn (app &App) index(mut ctx Context) veb.Result {
	lang := ctx.extra_i18n['lang'] or { ctx.i18n.default_lang }
	hello := ctx.i18n.t(lang, 'hello')
	welcome := ctx.i18n.t(lang, 'welcome')
	success := ctx.i18n.t(lang, 'common.success')
	msg := ctx.i18n.t(lang, 'common.msg.Failed')
	return ctx.text('i18n: ${hello}\n${welcome}\n${success}\n${msg}')
}

@['/i18n/debug'; get]
pub fn (app &App) debug_i18n(mut ctx Context) veb.Result {
	lang := ctx.extra_i18n['lang'] or { ctx.i18n.default_lang }

	translations := if lang in ctx.i18n.translations.keys() {
		ctx.i18n.translations[lang].clone()
	} else {
		map[string]string{}
	}

	mut lines := []string{}
	for k, v in translations {
		lines << '${k} = ${v}'
	}
	return ctx.text(lines.join('\n'))
}

// ------------------------- Main -------------------------
fn main() {
	i18n_app := new_i18n('locales', 'en') or { panic(err) }

	mut app := &App{}

	// 通过 closure 捕获 i18n
	app.use(i18n_middleware(i18n_app))

	veb.run[App, Context](mut app, 9006)
}

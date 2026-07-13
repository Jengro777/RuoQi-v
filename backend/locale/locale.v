module locale

import time
import os
import log
import x.json2 as json

// ------------------------- Locale -------------------------
@[heap]
pub struct LocaleStore {
pub:
	default_lang string
	dir          string
pub mut:
	translations   map[string]map[string]string
	current_lang   string // 当前语言缓存
	mod_times      map[string]int
	last_check     i64
	check_interval i64 = 2000 // 毫秒
}

// 创建 LocaleStore
pub fn new_locale(dir string, default_lang string) !&LocaleStore {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut s := &LocaleStore{
		dir:          dir
		default_lang: default_lang
		translations: map[string]map[string]string{}
		current_lang: default_lang
		mod_times:    map[string]int{}
		last_check:   0
	}
	load_translations(mut s)!
	return s
}

// ------------------------- 动态加载 + JSON 校验 + 日志 -------------------------
pub fn maybe_reload(mut s LocaleStore) {
	// log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	now := time.now().unix()
	if now - s.last_check < s.check_interval / 1000 {
		return
	}
	s.last_check = now
	load_translations(mut s) or { eprintln('locale load failed: ${err}') }
}

pub fn load_translations(mut s LocaleStore) ! {
	// log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

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
			log.warn('locale load failed for ${file}: ${err}')
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
		log.debug('locale loaded: ${lang}, keys: ${s.translations[lang].len}, new: ${is_new}')
	}
}

// 查询翻译，支持 fallback，只传入 key 参数
pub fn (s &LocaleStore) t(key string) string {
	// log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 使用当前缓存语言或默认语言
	selected := if s.current_lang != '' { s.current_lang } else { s.default_lang }

	// 查找翻译，首先检查当前语言，如果没有再回退到默认语言
	if key in s.translations[selected] {
		return s.translations[selected][key]
	}
	if key in s.translations[s.default_lang] {
		return s.translations[s.default_lang][key]
	}

	// 如果都没有找到，则返回 key 本身
	return key
}

// 设置当前语言
// 当语言切换时更新 current_lang
pub fn (mut s LocaleStore) set_language(lang string) {
	// log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 检查语言是否已经加载
	if lang in s.translations {
		// 设置当前语言
		s.current_lang = lang
		log.debug('Language set to: ${lang}')
	} else {
		// 如果指定的语言未加载，则回退到默认语言
		log.debug('Language ${lang} not found. Falling back to default language: ${s.default_lang}')
		s.current_lang = s.default_lang
	}
}

// 展平成点号路径
fn flatten_map(data map[string]json.Any, prefix string) map[string]string {
	// log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

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

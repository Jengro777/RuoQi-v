module i18n

import os
import time
import x.json2 as json

// ------------------------- 测试 new_i18n -------------------------
fn test_new_i18n() {
	tmpdir := os.temp_dir()
	mut dir := os.join_path(tmpdir, 'i18n_test')
	os.mkdir_all(dir) or {}

	// 写入一个示例翻译文件
	os.write_file(os.join_path(dir, 'en.json'), '{"hello": "Hello"}') or {}

	// 创建 I18nStore
	i18n_info := new_i18n(dir, 'en') or {
		assert false, 'failed to create i18n store: ${err}'
		return
	}
	// 验证默认语言和翻译内容
	assert i18n_info.default_lang == 'en'
	assert 'hello' in i18n_info.translations['en']
	assert i18n_info.translations['en']['hello'] == 'Hello'
}

// ------------------------- 测试 maybe_reload -------------------------
fn test_maybe_reload() {
	tmpdir := os.temp_dir()
	mut dir := os.join_path(tmpdir, 'i18n_reload')
	os.mkdir_all(dir) or {}

	// 写入初始翻译文件
	os.write_file(os.join_path(dir, 'en.json'), '{"hi": "Hi"}') or {}
	mut store := new_i18n(dir, 'en') or { panic(err) }

	// 等待一段时间后修改翻译文件
	time.sleep(1001 * time.millisecond)
	os.write_file(os.join_path(dir, 'en.json'), '{"hi": "Hello again"}') or {}

	// 触发重新加载
	store.last_check = 0
	store.check_interval = 500
	maybe_reload(mut store)

	// 验证翻译文件是否重新加载
	assert store.translations['en']['hi'] == 'Hello again'
}

// ------------------------- 测试 load_translations -------------------------
fn test_load_translations() {
	tmpdir := os.temp_dir()
	mut dir := os.join_path(tmpdir, 'i18n_load')
	os.mkdir_all(dir) or {}

	// 写入中文翻译文件
	os.write_file(os.join_path(dir, 'zh.json'), '{"a": "你好"}') or {}
	mut store := &I18nStore{
		dir:          dir
		default_lang: 'zh'
	}
	load_translations(mut store) or { assert false, 'load_translations failed: ${err}' }

	// 验证翻译是否加载成功
	assert 'a' in store.translations['zh']
	assert store.translations['zh']['a'] == '你好'
}

// ------------------------- 测试 t (翻译查询) -------------------------
fn test_t() {
	mut store := &I18nStore{
		default_lang: 'en'
		translations: {
			'en': {
				'hello': 'Hello'
			}
			'zh': {
				'hello': '你好'
			}
		}
	}

	// 验证翻译查询
	assert store.t('hello') == 'Hello' // 默认语言 'en'
	store.set_language('zh') // 设置为中文
	assert store.t('hello') == '你好' // 查询中文翻译
	store.set_language('nolang') // 设置不存在的语言
	assert store.t('hello') == 'Hello' // fallback 到默认语言 'en'
	assert store.t('not_exist') == 'not_exist' // 未找到的翻译返回 key 本身
}

// ------------------------- 测试 flatten_map -------------------------
fn test_flatten_map() {
	// 测试 JSON 扁平化
	raw := {
		'greeting': json.Any({
			'morning': json.Any('Good morning')
			'nested':  json.Any({
				'deep': json.Any('Deep value')
			})
		})
	}
	result := flatten_map(raw, '')
	// 验证扁平化后的结果
	assert result['greeting.morning'] == 'Good morning'
	assert result['greeting.nested.deep'] == 'Deep value'
	assert result.len == 2
}

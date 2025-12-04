#!/usr/bin/env -S v run

import toml
import sync

// 嵌套配置结构体
struct WebConfig {
pub:
	port    int
	timeout int
}

struct DBConfig {
pub:
	type string
	host string
}

struct Config {
pub:
	web    WebConfig
	dbconf DBConfig
}

@[heap]
struct ConfigLoader {
mut:
	config   &Config = unsafe { nil }
	load_err IError  = none
	once     &sync.Once
}

__global g_conf ConfigLoader

pub fn new_config_loader() &ConfigLoader {
	mut g_conf_loader := &g_conf
	g_conf_loader.once = sync.new_once()
	return g_conf_loader
}

pub fn (mut l ConfigLoader) get_config() !&Config {
	l.once.do(l.load_config)
	if l.load_err is none {
		return l.config
	}
	return l.load_err
}

fn (mut l ConfigLoader) load_config() {
	doc := toml.parse_file('config.toml') or {
		l.load_err = error('配置加载失败: ${err.msg()}')
		return
	}

	// 解析web配置
	web_config := WebConfig{
		port:    doc.value('web.port').int()
		timeout: doc.value('web.timeout').int()
	}

	// 解析dbconf配置
	db_config := DBConfig{
		type: doc.value('dbconf.type').string()
		host: doc.value('dbconf.host').string()
	}

	l.config = &Config{
		web:    web_config
		dbconf: db_config
	}
}

fn main() {
	// 验证单例
	mut loader1 := new_config_loader()
	mut loader2 := new_config_loader()
	dump('实例相等性验证: ${loader1 == loader2}') // 输出 true

	cf := g_conf.get_config()!
	println('Web端口: ${cf.web.port}')
	println('数据库类型: ${cf.web.timeout}')
}

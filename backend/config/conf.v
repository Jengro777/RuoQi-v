/*
配置加载器
在main文件引用，APP启动时初始化
避免频繁进行 IO
*/

module config

import toml
import sync
import log
import os

@[heap]
pub struct ConfigLoader {
pub mut:
	globalconfig &GlobalConfig = unsafe { nil } // 存储配置对象的指针
	initialized  bool      // 标记是否已初始化
	once         sync.Once // 保证线程安全的单次加载
}

// 创建新的配置加载器实例
pub fn new_config_loader() &ConfigLoader {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	return &ConfigLoader{}
}

// 获取配置（带错误处理）
pub fn (mut cl ConfigLoader) get_config() !&GlobalConfig {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	cl.once.do(fn [mut cl] () {
		global_config := parse_data() or {
			log.error('配置解析失败')
			return
		}
		cl.globalconfig = &global_config
		cl.initialized = true
		log.debug('配置初始化完成')
	})

	if !cl.initialized {
		return error('配置尚未初始化')
	}
	return cl.globalconfig
}

// 解析toml文件
pub fn parse_data() !GlobalConfig {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	doc := read_toml() or {
		log.error('无法读取配置文档')
		return error('无法读取配置文档')
	}
	// 解析web配置节
	web_config := WebConf{
		port:    doc.value('web.port').int()
		timeout: doc.value('web.timeout').int()
	}
	//解析logging配置节
	log_config := LogConf{
		log_level: doc.value('logging.log_level').string()
	}
	// // 解析dbconf配置节
	db_config := DBConf{
		type:       doc.value('dbconf.type').string()
		host:       doc.value('dbconf.host').string()
		port:       doc.value('dbconf.port').string()
		username:   doc.value('dbconf.username').string()
		password:   doc.value('dbconf.password').string()
		dbname:     doc.value('dbconf.dbname').string()
		ssl_verify: doc.value('dbconf.ssl_verify').bool()
		ssl_key:    doc.value('dbconf.ssl_key').string()
		ssl_cert:   doc.value('dbconf.ssl_cert').string()
		ssl_ca:     doc.value('dbconf.ssl_ca').string()
		ssl_capath: doc.value('dbconf.ssl_capath').string()
		ssl_cipher: doc.value('dbconf.ssl_cipher').string()
		// 连接池配置
		max_conns:      doc.value('dbconf.max_conns').int() // 默认 100 个
		min_idle_conns: doc.value('dbconf.min_idle_conns').int() // 默认 10个
		max_lifetime:   doc.value('dbconf.max_lifetime').int() // 默认 60 minute
		idle_timeout:   doc.value('dbconf.idle_timeout').int() // 默认 30 minute
		get_timeout:    doc.value('dbconf.get_timeout').int() // 默认 3 second
	}
	// 解析 redis 配置节
	redis_config := RedisConf{
		host:        doc.value('redisconf.host').string()
		port:        doc.value('redisconf.port').int()
		password:    doc.value('redisconf.password').string()
		get_timeout: doc.value('redisconf.get_timeout').int()
	}

	// 构建完整配置对象
	cfg := GlobalConfig{
		web:     web_config
		logging: log_config
		dbconf:  db_config
		redis:   redis_config
	}
	return cfg
}

pub fn read_toml() !toml.Doc {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 提供默认路径和备用路径
	mut path := find_toml() or {
		log.error('配置文件不存在，无法加载配置')
		return error('配置文件不存在，无法加载配置')
	}

	doc := toml.parse_file(path) or {
		log.error('配置文件解析失败: ${path}')
		return error('配置文件解析失败: ${path}')
	}

	log.debug('配置文件加载成功: ${path}')
	return doc
}

// 需找配置文件
pub fn find_toml() !string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// 1. 首先处理通过 -f 参数指定的配置文件
	custom_path := config_toml()
	if custom_path != '' {
		// 处理用户指定的路径
		resolved_path := if os.is_abs_path(custom_path) {
			custom_path
		} else {
			os.join_path(@VMODROOT, custom_path)
		}

		if os.exists(resolved_path) {
			log.debug('找到自定义配置文件: ${resolved_path}')
			return resolved_path
		}
		log.error('指定的配置文件不存在: ${resolved_path}')
	}

	// 2. 默认搜索路径
	mut paths := $if test {
		[
			os.join_path(@VMODROOT, 'etc', 'config_dev.toml'),
			os.join_path(@VMODROOT, 'etc', 'config_test.toml'),
			os.join_path(@VMODROOT, 'etc', 'config.toml'),
		]
	} $else {
		[
			os.join_path(@VMODROOT, 'config.toml'),
			os.join_path(@VMODROOT, 'etc', 'config.toml'),
		]
	}

	// 3. 搜索默认路径
	for path in paths {
		if os.exists(path) {
			log.debug('找到配置文件: ${path}')
			return path
		}
		log.debug('配置文件未找到，继续搜索: ${path}')
	}
	// 4. 所有路径都尝试失败
	log.error('无法找到任何配置文件，所有路径都已尝试')
	return error('无法找到任何配置文件，所有路径都已尝试')
}

//指定配置文件 [v run . -f etc/config_dev.toml]
pub fn config_toml() string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut cf_toml := os.join_path('')
	args := os.args[1..]
	for i in 0 .. args.len {
		if args[i] == '-f' {
			if i + 1 >= args.len {
				log.fatal('错误：-f 参数后缺少文件名; ${@METHOD} ${@MOD}.${@FILE_LINE}') // 直接终止并报错
			}
			cf_toml = args[i + 1]
			break
		}
	}
	log.debug('toml配置文件路径：${cf_toml}')
	return cf_toml
}

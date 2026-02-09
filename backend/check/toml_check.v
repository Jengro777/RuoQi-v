module check

import os
import log
import toml
import config

pub fn check_all() ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	check_config_toml()! //检查配置文件是否存在
	doc := config.read_toml() or { return }
	set_log_sevel(doc) or { return } //设置全局日志级别
	check_config_toml_data(doc) //检查配置文件内必要数据是否配置
}

//检查配置文件是否存在
fn check_config_toml() ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	default_path := os.join_path(@VMODROOT, 'config_template.toml')

	// 只调用一次 find_toml()
	config_path := config.find_toml() or {
		// 当找不到配置文件时，使用指定路径
		log.warn('未找到配置文件，将使用默认路径: ${default_path}')
		'etc/config.toml'
	}

	log.info('检查配置文件是否存在')
	if !os.exists(config_path) {
		log.warn('配置文件不存在，生成新配置文件模板: ${default_path}')
		mut f := os.create(default_path) or {
			log.fatal('配置文件创建失败')
			return
		}
		log.info('配置文件已创建')

		log.info('初始化配置数据文件模板: ${default_path}')
		os.write_file(default_path, data) or {
			log.error('${default_path} 配置数据模板写入错误')
			return
		}
		log.info('${default_path} 配置数据模板写入成功,请参考模板配置')

		defer {
			f.close()
		} // 记得关闭文件句柄
		log.info('正在退出程序...')
		exit(0) // 生产配置模板后，退出程序
	} else {
		log.info('配置文件加载完成: ${config.find_toml() or { return }}')
	}
}

//检查配置文件内必要数据是否配置
fn check_config_toml_data(doc toml.Doc) {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	log.info('开始检测必要配置')

	doc.value_opt('web.port') or {
		log.warn('配置数据：web.port 键无效或键没有值，请检查配置数据')
	}
	web_port := doc.value('web.port').int()
	if web_port < 1000 || web_port > 65535 {
		log.error('web.port监听端口: 1000 < port < 65535')
	}

	doc.value_opt('web.timeout') or {
		log.warn('配置数据：web.timeout 键无效或键没有值，请检查配置数据')
	}
	web_timeout := doc.value('web.timeout').int()
	if web_timeout < 3 || web_timeout > 1000 {
		log.error('web.timeout监听端口: 3 < port < 1000')
	}

	doc.value_opt('dbconf.type') or {
		log.fatal('必要配置数据：dbconf.type 键无效或键没有值，请检查配置数据,应为mysql或tidb')
	}
	dbconf_type := doc.value('dbconf.type').string()
	if dbconf_type != 'mysql' && dbconf_type != 'tidb' {
		log.fatal('必要配置数据：dbconf.type 的值无效，应为mysql或tidb')
	}

	doc.value_opt('dbconf.host') or {
		log.fatal('必要配置数据：dbconf.host 键无效或键没有值，请检查配置数据')
	}
	doc.value_opt('dbconf.port') or {
		log.fatal('必要配置数据：dbconf.port 键无效或键没有值，请检查配置数据')
	}
	doc.value_opt('dbconf.username') or {
		log.fatal('必要配置数据：dbconf.username 键无效或键没有值，请检查配置数据')
	}
	doc.value_opt('dbconf.password') or {
		log.fatal('必要配置数据：dbconf.password 键无效或键没有值，请检查配置数据')
	}
	doc.value_opt('dbconf.dbname') or {
		log.fatal('必要配置数据：dbconf.dbname 键无效或键没有值，请检查配置数据')
	}
	doc.value_opt('dbconf.ssl_verify') or {
		log.warn('配置数据：dbconf.ssl_verify 键无效或键没有值')
	}
	ssl_verify := doc.value('dbconf.ssl_verify').bool()
	if ssl_verify != true && ssl_verify != false {
		log.warn('配置数据：dbconf.ssl_verify 的值无效，应为true或false')
	}

	log.info('必要配置检测完毕')
}

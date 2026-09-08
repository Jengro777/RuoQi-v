module check

import os
import log
import toml
import config

pub fn check_all() ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	check_config_toml()! // 检查配置文件是否存在
	doc := config.read_toml() or { return }
	set_log_sevel(doc) or { return } // 设置全局日志级别
	check_config_toml_data(doc) // 检查配置文件内必要数据是否配置
}

// 检查配置文件是否存在，若不存在则自动生成模板并继续启动
fn check_config_toml() !string {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	config_path := config.find_toml() or {
		// 未找到任何配置文件，自动生成配置模板（直接覆盖）
		template_path := os.join_path(@VMODROOT, 'config_template.toml')
		log.warn('未找到配置文件，自动生成配置模板: ${template_path}')
		os.write_file(template_path, data) or {
			log.fatal('无法写入配置模板: ${template_path}')
			return err
		}
		log.info('配置模板已生成: ${template_path}')
		log.warn('>>> 请参考模板配置，复制为 etc/config.toml 后修改参数重新启动 <<<')
		return template_path
	}

	log.info('配置文件加载完成: ${config_path}')
	return config_path
}

// 检查配置文件内必要数据是否配置
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

	doc.value_opt('web.request_timeout') or {
		log.warn('配置数据：web.request_timeout 键无效或键没有值，请检查配置数据')
	}
	web_request_timeout := doc.value('web.request_timeout').int()
	if web_request_timeout < 3 || web_request_timeout > 1000 {
		log.error('web.request_timeout请求超时: 3 < timeout < 1000')
	}

	doc.value_opt('dbconf.type') or {
		log.fatal('必要配置数据：dbconf.type 键无效或键没有值，请检查配置数据,应为mysql、tidb或pgsql')
	}
	dbconf_type := doc.value('dbconf.type').string()
	if dbconf_type != 'mysql' && dbconf_type != 'tidb' && dbconf_type != 'pgsql' {
		log.fatal('必要配置数据：dbconf.type 的值无效，应为mysql、tidb或pgsql')
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

	doc.value_opt('crypt.aksk_encrypt') or {
		log.fatal('必要配置数据：crypt.aksk_encrypt 键无效或键没有值，请检查配置数据')
	}
	aksk_encrypt := doc.value('crypt.aksk_encrypt').string()
	if aksk_encrypt.len == 0 {
		log.fatal('必要配置数据：crypt.aksk_encrypt 不能为空，API Key SK 加密必须配置')
	}

	log.info('必要配置检测完毕')
}

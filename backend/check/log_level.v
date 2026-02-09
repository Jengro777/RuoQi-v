module check

import log
import toml

// 配置文件设置日志级别
pub fn set_log_sevel(doc toml.Doc) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	log_level_str := doc.value('logging.log_level').string()
	log.warn(log_level_str)
	// 将字符串转换为log.Level枚举值
	level := match log_level_str.to_lower() {
		'debug' { log.Level.debug }
		'info' { log.Level.info }
		'warn' { log.Level.warn }
		'error' { log.Level.error }
		'fatal' { log.Level.fatal }
		else { log.Level.debug } // 设置默认值
	}
	log.set_level(level)
}

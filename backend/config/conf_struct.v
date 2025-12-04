module config

// 嵌套配置结构体
@[heap]
pub struct GlobalConfig {
pub:
	web     WebConf
	logging LogConf
	dbconf  DBConf
}

//[veb]
pub struct WebConf {
pub:
	port    int
	timeout int
}

//[logging]
pub struct LogConf {
	log_level string
}

//[dbconf]
pub struct DBConf {
pub:
	type       string
	host       string
	port       string
	username   string
	password   string
	dbname     string
	ssl_verify bool @[default: false] // #设置为true时，验证ssl证书
	ssl_key    string
	ssl_cert   string
	ssl_ca     string
	ssl_capath string
	ssl_cipher string
	// 连接池配置
	max_conns      int = 100 // 默认 100 个
	min_idle_conns int = 10  // 默认 10个
	max_lifetime   i64 = 60  // 默认 60 minute
	idle_timeout   i64 = 30  // 默认 30 minute
	get_timeout    i64 = 3   // 默认 3 second
}

// MiddlewaresConf is the config of middlewares.
// pub struct MddlewaresConf {
// pub:
// 	trace      bool @[default: true; json: 'Trace']      // Enable trace middleware
// 	log        bool @[default: true; json: 'Log']        // 日志中间件
// 	prometheus bool @[default: true; json: 'Prometheus'] // Enable prometheus middleware
// 	max_conns  bool @[default: true; json: 'MaxConns']   // Enable max connections middleware
// 	breaker    bool @[default: true; json: 'Breaker']    // Enable circuit breaker middleware
// 	shedding   bool @[default: true; json: 'Shedding']   // Enable shedding middleware
// 	timeout    bool @[default: true; json: 'Timeout']    // 超时中间件
// 	recover    bool @[default: true; json: 'Recover']    // Enable recover middleware
// 	metrics    bool @[default: true; json: 'Metrics']    // Enable metrics middleware
// 	max_bytes  bool @[default: true; json: 'MaxBytes']   // Enable max bytes middleware
// 	gunzip     bool @[default: true; json: 'Gunzip']     // Enable gunzip middleware
// 	i18n       bool @[default: true; json: 'I18n']       // Enable i18n middleware
// 	tenant     bool @[default: false; json: 'Tenant']    // Enable tenant middleware
// 	client_ip  bool @[default: false; json: 'ClientIP']  // Enable client IP middleware
// }

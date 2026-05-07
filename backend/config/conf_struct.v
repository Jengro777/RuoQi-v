module config

// 嵌套配置结构体
@[heap]
pub struct GlobalConfig {
pub:
	web     WebConf
	logging LogConf
	dbconf  DBConf
	redis   RedisConf
}

//[veb]
pub struct WebConf {
pub:
	port             int
	request_timeout  int
	startup_timeout  int = 5
	shutdown_timeout int = 30
	shutdown_token   string
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

// Redis 配置
pub struct RedisConf {
pub:
	host        string
	port        i64 = 6379
	password    string
	get_timeout i64 = 3
}

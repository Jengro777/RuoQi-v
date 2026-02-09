module redis

import db.redis
import time

// Redis 连接配置
pub struct RedisConfig {
pub mut:
	host        string
	port        u16
	password    string
	get_timeout time.Duration = 3 * time.second
}

// 初始化 Redis 连接
pub fn new_redis(config RedisConfig) !&redis.DB {
	mut db := redis.connect(redis.Config{
		host:     config.host
		password: config.password
		port:     config.port
	}) or { panic(err) }

	return &db
}

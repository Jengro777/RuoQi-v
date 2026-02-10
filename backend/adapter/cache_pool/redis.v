module cache_pool

import db.redis
import time

// 缓存连接配置
pub struct CacheConfig {
pub mut:
	host        string
	port        u16
	password    string
	get_timeout time.Duration = 3 * time.second
}

pub struct CachePool {
	redis.DB
}

// 初始化缓存连接
pub fn new_cache_pool(config CacheConfig) !&CachePool {
	mut redisdb := redis.connect(redis.Config{
		host:     config.host
		password: config.password
		port:     config.port
	}) or { panic(err) }

	return &CachePool{redisdb}
}

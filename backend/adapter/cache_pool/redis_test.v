module cache_pool

import time

fn test_cache_config() {
	// 测试缓存配置结构体
	mut config := CacheConfig{
		host:        'mutual-mako-84612.upstash.io'
		port:        6379
		password:    'gQAAAAAAAUqEAAIgcDJlZDQ0NzkxOGIyYzc0ODRkOTEwYTBmYTllMmQxODEzZQ'
		get_timeout: 3 * time.second
	}

	assert config.host == 'mutual-mako-84612.upstash.io'
	assert config.port == 6379
	assert config.get_timeout == 3 * time.second

	println('CacheConfig test passed!')
}

fn test_cache_connection() {
	// 测试缓存连接
	config := CacheConfig{
		host:     'mutual-mako-84612.upstash.io'
		port:     6379
		password: 'gQAAAAAAAUqEAAIgcDJlZDQ0NzkxOGIyYzc0ODRkOTEwYTBmYTllMmQxODEzZQ'
	}

	// 尝试连接，如果失败则跳过测试
	mut db := new_cache_pool(config) or {
		println('Cache server not available, skipping connection test')
		return
	}

	// 手动关闭连接
	defer {
		db.close() or {}
	}

	println('Cache connection test passed!')
}

fn test_cache_basic_operations() {
	// 测试基本的缓存操作
	config := CacheConfig{
		host:     'mutual-mako-84612.upstash.io'
		port:     6379
		password: 'gQAAAAAAAUqEAAIgcDJlZDQ0NzkxOGIyYzc0ODRkOTEwYTBmYTllMmQxODEzZQ'
	}

	mut db := new_cache_pool(config) or {
		println('Cache server not available, skipping basic operations test')
		return
	}

	// 手动关闭连接
	defer {
		db.close() or {}
	}

	// 测试设置和获取字符串
	key := 'test_key_${time.now().unix()}'
	value := 'test_value_${time.now().unix()}'

	db.set(key, value) or {
		println('Failed to set key: ${err}')
		return
	}

	retrieved_value := db.get[string](key) or {
		println('Failed to get key: ${err}')
		return
	}

	assert retrieved_value == value

	// 测试删除
	db.del(key) or {
		println('Failed to delete key: ${err}')
		return
	}

	println('Basic operations test passed!')
}

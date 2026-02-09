module redis_test

import redis
import time

fn test_redis_config() {
	// 测试 Redis 配置结构体
	mut config := redis.RedisConfig{
		host:        'localhost'
		port:        6379
		password:    ''
		get_timeout: 3 * time.second
	}

	assert config.host == 'localhost'
	assert config.port == 6379
	assert config.get_timeout == 3 * time.second

	println('RedisConfig test passed!')
}

// fn test_redis_connection() {
// 	// 测试 Redis 连接
// 	config := redis.RedisConfig{
// 		host: 'localhost'
// 		port: 6379
// 	}

// 	// 尝试连接，如果失败则跳过测试
// 	mut db := redis.new_redis(config) or {
// 		println('Redis server not available, skipping connection test')
// 		return
// 	}

// 	// 手动关闭连接
// 	defer{
// 	  db.close() or { }
// 	}

// 	println('Redis connection test passed!')
// }

// fn test_redis_basic_operations() {
// 	// 测试基本的 Redis 操作
// 	config := redis.RedisConfig{
// 		host: 'localhost'
// 		port: 6379
// 	}

// 	mut db := redis.new_redis(config) or {
// 		println('Redis server not available, skipping basic operations test')
// 		return
// 	}

// 	// 手动关闭连接
// 	defer {
// 		db.close() or { }
// 	}

// 	// 测试设置和获取字符串
// 	key := 'test_key_${time.now().unix()}'
// 	value := 'test_value_${time.now().unix()}'

// 	db.set(key, value) or {
// 		println('Failed to set key: ${err}')
// 		return
// 	}

// 	retrieved_value := db.get[string](key) or {
// 		println('Failed to get key: ${err}')
// 		return
// 	}

// 	assert retrieved_value == value

// 	// 测试删除
// 	db.del(key) or {
// 		println('Failed to delete key: ${err}')
// 		return
// 	}

// 	println('Basic operations test passed!')
// }

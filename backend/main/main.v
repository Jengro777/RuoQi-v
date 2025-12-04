module main

import check

fn main() {
	banner()
	check.check_all()!

	server_thread := go new_app() // 启动服务器并处理错误, http服务使用go比spawn更好
	//* 这里主线程可以做一些其他事情 */
	server_thread.wait() // 等待服务器线程完成并处理错误
}

// lsof -i :9009
// sudo kill -9 $(lsof -t -i :9009)

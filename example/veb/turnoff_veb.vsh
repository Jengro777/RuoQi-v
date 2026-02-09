#!/usr/bin/env -S v run

import veb
import sync
import os
import time

// ------------------ 上下文结构体 / Context Struct ------------------
pub struct Context {
	veb.Context
}

// ------------------ 优雅关闭管理器 / Graceful Shutdown Manager ------------------
pub struct GracefulShutdownManager {
mut:
	mu                 sync.Mutex // 互斥锁，保护共享状态 / Mutex to protect shared state
	inflight           int        // 当前正在处理的请求数 / Number of requests currently being processed
	shutting_down      bool       // 是否正在关闭 / Whether the server is shutting down
	shutdown_ch        chan bool  // 用于接收关闭信号 / Channel to receive shutdown signals
	inflight_zero      chan bool  // inflight 为 0 时通知 / Notifies when inflight reaches 0
	shutdown_wait_secs int        // 等待请求完成的最大秒数 / Maximum seconds to wait for requests to complete
}

// 创建优雅关闭管理器 / Create a Graceful Shutdown Manager
pub fn new_graceful_shutdown_manager(shutdown_wait_secs int) GracefulShutdownManager {
	return GracefulShutdownManager{
		shutdown_ch:        chan bool{cap: 1}
		inflight_zero:      chan bool{cap: 1}
		shutdown_wait_secs: shutdown_wait_secs
	}
}

// ------------------ 中间件处理函数 / Middleware Handler ------------------
pub fn (mut manager GracefulShutdownManager) shutdown_middleware(mut ctx Context) bool {
	manager.mu.lock()
	if manager.shutting_down {
		manager.mu.unlock()
		ctx.res.set_status(.service_unavailable)
		ctx.text('server is shutting down')
		eprintln('[middleware] 请求拒绝：服务器正在关闭 / Request rejected: server is shutting down')
		return false
	}
	manager.inflight++
	eprintln('[middleware] 请求开始，inflight=${manager.inflight} / Request started, inflight=${manager.inflight}')
	manager.mu.unlock()

	defer {
		manager.mu.lock()
		manager.inflight--
		eprintln('[middleware] 请求结束，inflight=${manager.inflight} / Request ended, inflight=${manager.inflight}')
		// 如果正在关闭且没有请求，通知 shutdown_listener / Notify listener if shutting down and inflight is 0
		if manager.shutting_down && manager.inflight == 0 {
			eprintln('[middleware] inflight 为 0，通知关闭监听器 / inflight is 0, notify shutdown listener')
			manager.inflight_zero <- true
		}
		manager.mu.unlock()
	}

	return true
}

// ------------------ 发起关闭信号 / Initiate Shutdown Signal ------------------
pub fn (manager &GracefulShutdownManager) initiate_shutdown() {
	eprintln('[shutdown] initiate_shutdown() called')
	select {
		manager.shutdown_ch <- true {
			eprintln('[shutdown] signal sent to shutdown_ch')
		}
		else {
			// 防止阻塞 / Prevent blocking
			go fn (ch chan bool) {
				select {
					ch <- true {}
					else {}
				}
			}(manager.shutdown_ch)
		}
	}
}

// ------------------ 开始关闭流程 / Start Shutdown Process ------------------
pub fn (mut manager GracefulShutdownManager) start_shutdown() {
	eprintln('[shutdown] starting shutdown process')
	manager.mu.lock()
	manager.shutting_down = true
	eprintln('[shutdown] 当前 inflight 请求数: ${manager.inflight} / Current inflight requests: ${manager.inflight}')

	if manager.inflight == 0 {
		manager.mu.unlock()
		eprintln('[shutdown] 没有 inflight 请求，直接退出 / No inflight requests, exiting directly')
		perform_graceful_exit()
		return
	}
	manager.mu.unlock()

	mut wait_secs := manager.shutdown_wait_secs
	if wait_secs <= 0 {
		wait_secs = 30
	}

	eprintln('[shutdown] 等待最多 ${wait_secs}s，等待 ${manager.inflight} 个请求完成 / Waiting up to ${wait_secs}s for ${manager.inflight} requests to complete')

	start := time.now()
	for {
		manager.mu.lock()
		if manager.inflight == 0 {
			manager.mu.unlock()
			eprintln('[shutdown] 所有 inflight 请求完成 / All inflight requests completed')
			perform_graceful_exit()
			return
		}
		manager.mu.unlock()

		select {
			val := <-manager.inflight_zero {
				_ := val
				eprintln('[shutdown] 收到 inflight_zero 信号 / Received inflight_zero signal')
				perform_graceful_exit()
				return
			}
			else {}
		}

		if time.now() - start > time.Duration(wait_secs) * time.second {
			eprintln('[shutdown] 等待请求超时，强制退出 / Wait timed out, forcing exit')
			perform_graceful_exit()
			return
		}

		time.sleep(100 * time.millisecond)
	}
}

// ------------------ 应用结构体 / Application Struct ------------------
pub struct App {
	veb.Middleware[Context]
	veb.Controller
	veb.StaticHandler
pub mut:
	shutdown_manager GracefulShutdownManager
}

// ------------------ 路由 / Routes ------------------
@['/slow'; get; post]
pub fn (mut app App) slow(mut ctx Context) veb.Result {
	eprintln('[slow] 业务开始（将睡 100s） / Business logic starts (sleep 100s)')
	time.sleep(100 * time.second)
	eprintln('[slow] 业务结束 / Business logic ends')
	return ctx.text('slow response done')
}

// ------------------ 辅助函数 / Helper Functions ------------------
fn perform_graceful_exit() {
	eprintln('[shutdown] 执行优雅退出 / Performing graceful exit')
	exit(0)
}

// ------------------ 关闭监听协程 / Shutdown Listener Goroutine ------------------
fn shutdown_listener(mut manager GracefulShutdownManager) {
	eprintln('[listener] 等待关闭信号... / Waiting for shutdown signal...')
	_ = <-manager.shutdown_ch
	eprintln('[listener] 收到 shutdown_ch 信号，开始关闭... / Received shutdown_ch signal, starting shutdown...')
	manager.start_shutdown()
}

fn main() {
	mut shutdown_manager := new_graceful_shutdown_manager(30) // 秒 / seconds

	mut app := &App{
		shutdown_manager: shutdown_manager
	}

	// 添加优雅关闭中间件 / Add graceful shutdown middleware
	app.use(handler: app.shutdown_manager.shutdown_middleware)

	// Ctrl+C / SIGTERM 信号触发关闭 / Ctrl+C / SIGTERM triggers shutdown
	os.signal_opt(.int, fn [mut shutdown_manager] (_ os.Signal) {
		eprintln('[signal] 收到 SIGINT / Received SIGINT')
		shutdown_manager.initiate_shutdown()
	}) or { panic(err) }

	os.signal_opt(.term, fn [mut shutdown_manager] (_ os.Signal) {
		eprintln('[signal] 收到 SIGTERM / Received SIGTERM')
		shutdown_manager.initiate_shutdown()
	}) or { panic(err) }

	// 启动 shutdown listener / Start shutdown listener
	go shutdown_listener(mut &shutdown_manager)

	eprintln('Server 启动在端口 9008 / Server started on port 9008')
	eprintln('curl http://localhost:9008/slow')

	// 阻塞运行 HTTP server / Run HTTP server blocking
	veb.run[App, Context](mut app, 9008)
}

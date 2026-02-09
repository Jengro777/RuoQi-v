#!/usr/bin/env -S v run

import sync
import time

fn main() {
	mut wg := sync.new_waitgroup()
	for i := 0; i < 10; i++ {
		wg.add(1) //递增计数
		go fn (i int, mut w sync.WaitGroup) {
			time.sleep(1 * time.second)
			println('goroutine ${i} done')
			defer {
				w.done()
			} //完成后递减计数
		}(i, mut wg)
	}
	println('main start...')
	wg.wait() //阻塞等待，直到计数器归零
	println('main end...')
}

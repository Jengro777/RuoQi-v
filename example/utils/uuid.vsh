#!/usr/bin/env -S v run

import rand
import benchmark

println(rand.uuid_v4())
println(rand.uuid_v7())

mut b := benchmark.start()

for _ in 0 .. 10000 {
	mut u := rand.new_uuid_v7_session()
	u.next()
	dump(u.next())
}
b.measure('new_uuid_v7_session')

#!/usr/bin/env -S v run

import x.json2
import time

struct TestResp {
	created_at ?time.Time @[json: 'created_at'; raw: '.format_ss()']
	updated_at ?time.Time @[json: 'updated_at'; raw: '.format_ss()']
}

fn main() {
	data := '{"created_at": "2023-10-01", "updated_at": "2023-10-02"}'

	// 这个解码操作应该会触发编译器错误
	result := json2.decode[TestResp](data) or {
		println('Decode failed: ${err}')
		return
	}
	println(result)
}

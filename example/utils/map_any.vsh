#!/usr/bin/env -S v run

type Any0 = string | int | f64 | bool | []map[string]Any0

// fn main() {
// 创建 map[string]any 的切片
mut data_list := []map[string]Any0{}

mut item := map[string]Any0{}
item['name'] = 'name'
item['age'] = 1
data_list << item
dump(data_list)

mut result := map[string]Any0{}
result['account'] = 123
result['data'] = data_list

dump(result)
// }

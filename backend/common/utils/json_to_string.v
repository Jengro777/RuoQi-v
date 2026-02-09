module utils

import x.json2 as json

// json 转换为 string(处理嵌套的 map[string]json2.Any 结构，并将其转换为字符串)
pub fn json_to_string_nesting(data map[string]json.Any) string {
	mut result := ''
	for key, value in data {
		match value {
			map[string]json.Any {
				result += '${key}{${json_to_string(value)}}'
			}
			int {
				result += '${key}${value}'
			}
			string {
				result += '${key}${value}'
			}
			else {
				result += '${key}${value.str()}'
			}
		}
	}
	return result
}

//单层map转字符串(1688签名因子使用)
pub fn json_to_string(data map[string]json.Any) string {
	mut result := ''
	for key, value in data {
		match value {
			int {
				result += '${key}${value}'
			}
			string {
				result += '${key}${value}'
			}
			else {
				result += '${key}${value.str()}'
			}
		}
	}
	return result
}

module utils

import x.json2 as json
import log

pub type Any = []Any
	| []bool
	| []f32
	| []f64
	| []i16
	| []i64
	| []i8
	| []int
	| []string
	| []u16
	| []u32
	| []u64
	| []u8
	| bool
	| f32
	| f64
	| i16
	| i64
	| i8
	| int
	| map[int]int
	| map[string]Any
	| map[string]string
	| string
	| u16
	| u32
	| u64
	| u8

pub fn encode_any(a Any) json.Any {
	log.info('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	match a {
		string {
			return json.Any(a as string)
		}
		i8 {
			return json.Any(a as i8)
		}
		i16 {
			return json.Any(a as i16)
		}
		int {
			return json.Any(a as int)
		}
		i64 {
			return json.Any(a as i64)
		}
		u8 {
			return json.Any(a as u8)
		}
		u16 {
			return json.Any(a as u16)
		}
		u32 {
			return json.Any(a as u32)
		}
		u64 {
			return json.Any(a as u64)
		}
		f32 {
			return json.Any(a as f32)
		}
		f64 {
			return json.Any(a as f64)
		}
		bool {
			return json.Any(a as bool)
		}
		[]string {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]i8 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]i16 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]int {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]i64 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]u8 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]u16 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]u32 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]u64 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]f32 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]f64 {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]bool {
			mut result := []json.Any{}
			for value in a {
				result << json.Any(value)
			}
			return json.Any(result)
		}
		[]Any {
			mut result := []json.Any{}
			for value in a {
				result << encode_any(value)
			}
			return json.Any(result)
		}
		map[string]string {
			mut result := map[string]json.Any{}
			for key, value in a {
				result[key] = json.Any(value)
			}
			return json.Any(result)
		}
		map[int]int {
			mut result := map[string]json.Any{}
			for key, value in a {
				result[key.str()] = json.Any(value)
			}
			return json.Any(result)
		}
		map[string]Any {
			mut result := map[string]json.Any{}
			for key, value in a {
				result[key] = encode_any(value)
			}
			return json.Any(result)
		}
	}
}

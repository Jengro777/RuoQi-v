module token

import time
import structs { App }

type F64 = f64
type Any = string
	| []string
	| int
	| []int
	| []f64
	| F64
	| bool
	| time.Time
	| map[string]int
	| []map[string]string
	| []map[string]Any

pub struct Token {
	App
}

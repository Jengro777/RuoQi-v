module api

pub struct ValidationError {
pub:
	field string
	msg   string // 使用 message 更符合RESTful 接口规范
	rule  string
	meta  map[string]string // 扩展参数（如 { "min": ’8‘, "max": 20 }）
}

// 业务失败响应体 —— code 为具体业务错误码，msg 用于展示
@[params]
pub struct ApiErrorResponse {
pub:
	code       int = 1
	request_id string
	msg        string
}

// 业务成功响应体 —— code 恒为 0，data 为业务数据（泛型）
@[params]
pub struct ApiSuccessResponse[T] {
pub:
	code       int
	request_id string
	data       T
	msg        string = 'success'
}

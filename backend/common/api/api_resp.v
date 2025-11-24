module api

import rand

pub struct ValidationError {
pub:
	field string
	msg   string //使用 message 更符合RESTful 接口规范
	rule  string
	meta  map[string]string // 扩展参数（如 { "min": ’8‘, "max": 20 }）
}

@[params]
pub struct ApiErrorResponse {
pub:
	code       int
	status     bool
	request_id string
	error      string
	details    ?[]ValidationError //暂时未使用，待未来扩展
}

@[params]
pub struct ApiSuccessResponse[T] {
pub:
	code       int
	status     bool
	request_id string
	data       T
	msg        ?string
}

pub fn json_success[T](input ApiSuccessResponse[T]) ApiSuccessResponse[T] {
	mut uuid := rand.uuid_v7()
	response := ApiSuccessResponse[T]{
		code:       input.code
		status:     true
		request_id: uuid
		data:       input.data
		msg:        input.msg
	}
	return response
}

pub fn json_error(input ApiErrorResponse) ApiErrorResponse {
	mut uuid := rand.uuid_v7()
	response := ApiErrorResponse{
		code:       input.code
		status:     false
		request_id: uuid
		error:      input.error
	}
	return response
}

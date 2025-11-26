module api

// 200 OK - 成功响应
// 适用场景：GET请求成功、非创建型操作（如更新/删除）成功
pub fn json_success_200[T](data T) ApiSuccessResponse[T] {
	return json_success[T](code: 200, data: data, msg: 'Successful 200')
}

// 201 Created - 资源创建成功
// 适用场景：POST/PUT请求后返回新创建/更新的资源URL
pub fn json_success_201[T](data T) ApiSuccessResponse[T] {
	return json_success[T](code: 201, data: data, msg: 'Successful 201')
}

// 202 Accepted - 请求已接受处理
// 适用场景：异步任务已排队（如邮件发送、后台计算）
pub fn json_success_202[T](data T) ApiSuccessResponse[T] {
	return json_success[T](code: 202, data: data, msg: 'Successful 202')
}

// 400 Bad Request - 客户端请求错误
// 适用场景：请求参数格式错误/非法输入
pub fn json_error_400(err string) ApiErrorResponse {
	return json_error(code: 400, error: 'There was a problem with your request: {${err}}')
}

// 401 Unauthorized - 未授权访问
// 适用场景：缺少身份凭证（Token/JWT）或凭证无效
pub fn json_error_401() ApiErrorResponse {
	return json_error(code: 401, error: 'Authentication required to access this resource')
}

// 403 Forbidden - 禁止访问
// 适用场景：认证成功但无权操作资源（如普通用户访问管理员接口）
pub fn json_error_403() ApiErrorResponse {
	return json_error(code: 403, error: "You don't have permission to perform this action")
}

// 404 Not Found - 资源不存在
// 适用场景：请求URL无效或资源已被删除
pub fn json_error_404() ApiErrorResponse {
	return json_error(code: 404, error: 'The requested resource was not found')
}

// 422 Unprocessable Entity - 语义错误
// 适用场景：请求格式正确但内容无效（字段验证失败/必填项缺失）
pub fn json_error_422(msg string) ApiErrorResponse {
	return json_error(code: 422, error: msg)
}

// 500 Internal Server Error - 服务端内部错误
// 适用场景：未捕获异常/代码崩溃（应尽量避免）
pub fn json_error_500(err string) ApiErrorResponse {
	return json_error(
		code:  500
		error: 'Something went wrong on our end. Please try again later: ${err}'
	)
}

module api

import rand

// ═══════════════════════════════════════════════════════════════════════════════
// 统一响应构造器（只保留两个）
//   成功：json_success(data: x, msg: '...')  —— code 恒为 0，msg 可选（默认 'success'）
//   失败：json_error(code: x, msg: '...')  —— code 为具体业务错误码（可省略，默认 1）
// 业务层不设 HTTP 状态码；仅协议层（缺凭证/签名无效等）才 set_status
// ═══════════════════════════════════════════════════════════════════════════════

// 业务成功
pub fn json_success[T](input ApiSuccessResponse[T]) ApiSuccessResponse[T] {
	return ApiSuccessResponse[T]{
		code: success
		request_id: rand.uuid_v7()
		data: input.data
		msg: input.msg
	}
}

// 业务失败
pub fn json_error(input ApiErrorResponse) ApiErrorResponse {
	mut msg := input.msg
	// 非用户行为类错误（系统/下游/依赖，category != 1）在生产构建统一隐藏具体信息，
	// 避免泄露内部实现细节（DB / 堆栈 / 内部异常等）；非生产构建仍返回原始 msg 便于排障。
	if category(input.code) != 1 {
		$if !prod {
			msg = input.msg
		} $else {
			msg = 'Something went wrong on our end. Please try again later.'
		}
	}
	return ApiErrorResponse{
		code: input.code
		request_id: rand.uuid_v7()
		msg: msg
	}
}

// ═══════════════════════════════════════════════════════════════════════════════
// 【状态码语义参考 —— 仅注释说明】便于对照"各个状态码的作用"。
//   注意：业务层失败一律 HTTP 200 + code 区分；函数名里的 HTTP 状态
//   已不再决定实际 HTTP 状态码。以下只是"原 HTTP 状态码 → 业务码"的对照。
// ═══════════════════════════════════════════════════════════════════════════════
// 200 OK        - 成功响应      适用：GET请求成功、非创建型操作（更新/删除）成功        → code=0 (success)
// 201 Created   - 资源创建成功   适用：POST/PUT请求后返回新创建/更新的资源URL            → code=0 (success)
// 202 Accepted  - 请求已接受处理 适用：异步任务已排队（邮件发送、后台计算）              → code=0 (success)
// 400 Bad Request      - 客户端请求错误  适用：请求参数格式错误/非法输入                   → err_common_param_invalid (100001)
// 401 Unauthorized     - 未授权访问     适用：缺少身份凭证（Token/JWT）或凭证无效          → err_common_auth (100101)
// 403 Forbidden        - 禁止访问       适用：认证成功但无权操作资源                      → err_common_permission (100103)
// 404 Not Found        - 资源不存在     适用：请求URL无效或资源已被删除                    → err_common_not_found (100201)
// 422 Unprocessable Entity - 语义错误   适用：请求格式正确但内容无效（验证失败/必填缺失）    → err_common_param_invalid (100001)
// 500 Internal Server Error - 服务端内部错误  适用：未捕获异常/代码崩溃（生产隐藏详情）     → err_common_server (200001)

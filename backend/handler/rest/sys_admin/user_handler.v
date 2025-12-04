// ===========================
// module: handler.sys_admin
// ===========================
/*
repo
依赖 usecase（调用业务）
依赖 dto（解析输入、生成输出）
*/
module sys_admin

import veb
import log
import x.json2 as json
import structs { App, Context }
import dto.sys_admin.user { UserByIdReq }
import usecase.sys_api.sys_admin.user as usecase
import common.api

pub struct User {
	App
}

// ===== Handler 层 =====
// 负责接收 HTTP 请求，调用应用服务层，返回 JSON 响应
@['/id'; post]
pub fn (mut app User) find_user_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD} ${@MOD}.${@FILE_LINE}')

	// 解析请求参数
	req := json.decode[UserByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	if req.user_id.trim_space() == '' {
		return ctx.json(api.json_error_400('user_id cannot be empty'))
	}

	// 调用应用服务层获取数据
	result := usecase.find_user_by_id_usecase(mut ctx, req.user_id) or {
		return ctx.json(api.json_error_500(err.msg()))
	}

	// 返回标准 JSON 响应
	return ctx.json(api.json_success_200(result))
}

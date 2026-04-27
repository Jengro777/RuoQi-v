module user

import veb
import log
import x.json2 as json
import structs.schema_sys { SysUser }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/change_password'; post]
pub fn (app &User) change_password_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[ChangePasswordReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	resp := change_password_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}

	return ctx.json(api.json_success_200(resp))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn change_password_usecase(mut ctx Context, req ChangePasswordReq) !ChangePasswordResp {
	// 1️⃣ 调用 Repository 层更新密码
	update_password(mut ctx, req)!

	// 2️⃣ 返回成功提示或空结构体
	return ChangePasswordResp{}
}

// ----------------- Domain 层 -----------------
fn verify_old_password_domain(old_password string, current_password string) ! {
	if old_password != current_password {
		return error('Incorrect old password | 旧密码不正确')
	}
}

// ----------------- DTO 层 | 请求/返回结构 -----------------
pub struct ChangePasswordReq {
	user_id      string @[json: 'userId']
	old_password string @[json: 'oldPassword']
	new_password string @[json: 'newPassword']
}

pub struct ChangePasswordResp {
	// 可扩展字段，例如 success: bool
}

// ----------------- AdapterRepository 层 -----------------
fn update_password(mut ctx Context, req ChangePasswordReq) ! {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release DB connection: ${err}') }
	}

	// 查询当前密码
	mut user_rows := sql db {
		select password from SysUser where id == req.user_id limit 1
	}!

	if user_rows.len == 0 {
		return error('User not found')
	}
	current_password := user_rows[0].password

	// 核心业务逻辑校验
	verify_old_password_domain(req.old_password, current_password)!

	// 更新新密码
	sql db {
		update SysUser set password = req.new_password where id == req.user_id
	}!
}

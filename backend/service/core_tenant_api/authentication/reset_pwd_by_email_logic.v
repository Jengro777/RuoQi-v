module authentication

// import veb
// import log
// import orm
// import x.json2 as json
// import structs.schema_sys
// import common.api
// import structs { Context }

// // Change Password | 修改密码
// @['/change_password'; post]
// fn (app &User) change_password(mut ctx Context) veb.Result {
// 	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

// 	req := json.decode[json.Any](ctx.req.data) or { return ctx.json(api.json_error_400(err.msg())) }
// 	mut result := change_password_resp(mut ctx, req) or {
// 		return ctx.json(api.json_error_500(err.msg()))
// 	}

// 	return ctx.json(api.json_success_200(result))
// }

// fn change_password_resp(mut ctx Context, req json.Any) !map[string]Any {
// 	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

// 	user_id := req.as_map()['user_id'] or { '' }.str()
// 	new_password := req.as_map()['new_password'] or { '' }.str()
// 	old_password := req.as_map()['old_password'] or { '' }.str()

// 	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire connection: ${err}') }
// 	defer {
// 		ctx.dbpool.release(conn) or {
// 			log.warn('Failed to release connection ${@LOCATION}: ${err}')
// 		}
// 	}

// 	mut sys_user := orm.new_query[schema_sys.SysUser](db)
// 	pwd := sys_user.select('password')!.where('id = ?', user_id)!.query()!

// 	if pwd[0].password != old_password {
// 		return error('Incorrect old password | 旧密码不正确')
// 	}

// 	sys_user.reset()

// 	sys_user.set('password = ?', new_password)!
// 		.where('id = ?', user_id)!
// 		.update()!

// 	return map[string]Any{}
// }

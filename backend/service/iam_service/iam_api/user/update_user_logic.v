module user

import veb
import log
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamUser, IamUserRole }
import common.api
import common.encrypt

// ═══ Handler ═══
@['/update_user'; post]
pub fn (app &User) update_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[UpdateUserReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := update_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_user_usecase(mut ctx Context, req UpdateUserReq) !UpdateUserResp {
	update_user_domain(req)!
	password_hash := if pwd := req.password {
		encrypt.bcrypt_hash(pwd) or { return error('Failed to hash password') }
	} else {
		''
	}
	update_user_repo(mut ctx, req, password_hash)!
	return UpdateUserResp{
		msg: 'User updated'
	}
}

// ═══ Domain ═══
fn update_user_domain(req UpdateUserReq) ! {
	if req.user_id == '' {
		return error('user_id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateUserReq {
	user_id     string   @[json: 'id']
	role_ids    []string @[json: 'roleIds']
	avatar      ?string  @[json: 'avatar']
	description ?string  @[json: 'description']
	email       ?string  @[json: 'email']
	home_path   ?string  @[json: 'homePath']
	mobile      ?string  @[json: 'mobile']
	nickname    ?string  @[json: 'nickname']
	password    ?string  @[json: 'password']
	status      ?u8      @[json: 'status']
	username    ?string  @[json: 'username']
}

pub struct UpdateUserResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_user_repo(mut ctx Context, req UpdateUserReq, password_hash string) ! {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	up_expr := {
		if nickname := req.nickname { nickname == nickname },
		if email := req.email { email == email },
		if mobile := req.mobile { mobile == mobile },
		if description := req.description { description == description },
		if home_path := req.home_path { home_path == home_path },
		if avatar := req.avatar { avatar == avatar },
		if username := req.username { username == username },
		if status := req.status { status == status },
		if req.password != none { password == password_hash }
	}
	sql db {
		dynamic update IamUser set up_expr where id == req.user_id
	}!
	if req.role_ids.len > 0 {
		sql db {
			delete from IamUserRole where user_id == req.user_id
		}!
		for role_id in req.role_ids {
			ur := IamUserRole{
				user_id: req.user_id
				role_id: role_id
			}
			sql db {
				insert ur into IamUserRole
			}!
		}
	}
}

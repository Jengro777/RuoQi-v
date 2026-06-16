module user

import veb
import log
import time
import rand
import x.json2 as json
import structs { Context }
import structs.schema_iam { IamUser, IamUserRole }
import common.api
import common.encrypt

// ═══ Handler ═══
@['/create_user'; post]
pub fn (app &User) create_user_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[CreateUserReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}
	result := create_user_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500(err.msg()))
	}
	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn create_user_usecase(mut ctx Context, req CreateUserReq) !CreateUserResp {
	create_user_domain(req)!
	user_id := rand.uuid_v7()
	password_hash := encrypt.bcrypt_hash(req.password) or {
		return error('Failed to hash password')
	}
	create_user_repo(mut ctx, req, user_id, password_hash)!
	return CreateUserResp{
		msg: 'User created successfully'
	}
}

// ═══ Domain ═══
fn create_user_domain(req CreateUserReq) ! {
	if req.username == '' || req.password == '' {
		return error('username and password cannot be empty')
	}
}

// ═══ DTO ═══
pub struct CreateUserReq {
	avatar       string    @[json: 'avatar']
	description  string    @[json: 'description']
	mobile       string    @[json: 'mobile']
	email        string    @[json: 'email']
	home_path    string    @[json: 'homePath']
	nickname     string    @[json: 'nickname']
	password     string    @[json: 'password']
	status       u8        @[json: 'status']
	username     string    @[json: 'username']
	position_ids []string  @[json: 'positionIds']
	role_ids     []string  @[json: 'roleIds']
	created_at   time.Time @[json: 'createdAt']
	updated_at   time.Time @[json: 'updatedAt']
}

pub struct CreateUserResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_user_repo(mut ctx Context, req CreateUserReq, user_id string, password_hash string) ! {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
	user := IamUser{
		id:          user_id
		username:    req.username
		password:    password_hash
		nickname:    req.nickname
		description: req.description
		email:       req.email
		mobile:      req.mobile
		avatar:      req.avatar
		home_path:   req.home_path
		status:      req.status
		created_at:  req.created_at
		updated_at:  req.updated_at
		creator_id:  ctx.svc_iam.user_id
	}
	sql db {
		insert user into IamUser
	}!
	for role_id in req.role_ids {
		ur := IamUserRole{
			user_id: user_id
			role_id: role_id
		}
		sql db {
			insert ur into IamUserRole
		}!
	}
}

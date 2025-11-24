module configuration

import veb
import log
import orm
import x.json2 as json
import structs.schema_sys { SysConfiguration }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/configuration/delete'; post]
pub fn(app &Configuration)configuration_delete_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[DeleteConfigurationReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := delete_configuration_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn delete_configuration_usecase(mut ctx Context, req DeleteConfigurationReq) !DeleteConfigurationResp {
	// Domain 校验
	delete_configuration_domain(req)!

	// Repository 删除数据
	return delete_configuration_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn delete_configuration_domain(req DeleteConfigurationReq) ! {
	if req.id == '' {
		return error('configuration id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct DeleteConfigurationReq {
	id string @[json: 'id']
}

pub struct DeleteConfigurationResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn delete_configuration_repo(mut ctx Context, req DeleteConfigurationReq) !DeleteConfigurationResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB connection: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release connection: ${err}') }
	}

	mut q := orm.new_query[SysConfiguration](db)
	q.delete()!.where('id = ?', req.id)!.update()!

	return DeleteConfigurationResp{
		msg: 'Configuration deleted successfully'
	}
}

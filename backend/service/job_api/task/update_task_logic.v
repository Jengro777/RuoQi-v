module task

import veb
import log
import time
import json2 as json
import model.schema_job { JobTask }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Task) update_task_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateTaskReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_task_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_task_usecase(mut ctx Context, req UpdateTaskReq) !UpdateTaskResp {
	update_task_domain(req)!
	return update_task_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_task_domain(req UpdateTaskReq) ! {
	if req.id == '' {
		return error('task id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateTaskReq {
	id              string @[json: 'id']
	name            ?string @[json: 'name']
	task_group      ?string @[json: 'taskGroup']
	cron_expression ?string @[json: 'cronExpression']
	pattern         ?string @[json: 'pattern']
	payload         ?string @[json: 'payload']
	status          ?u8 @[json: 'status']
}

pub struct UpdateTaskResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_task_repo(mut ctx Context, req UpdateTaskReq) !UpdateTaskResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr :=
		sql {
		}

	sql db {
		dynamic update JobTask set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateTaskResp{
		msg: 'Task updated successfully'
	}
}

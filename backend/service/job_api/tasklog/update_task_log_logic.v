module tasklog

import veb
import log
import time
import json2 as json
import model.schema_job { JobTaskLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &TaskLog) update_task_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateTaskLogReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_task_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_task_log_usecase(mut ctx Context, req UpdateTaskLogReq) !UpdateTaskLogResp {
	update_task_log_domain(req)!
	return update_task_log_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_task_log_domain(req UpdateTaskLogReq) ! {
	if req.id == '' {
		return error('task log id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateTaskLogReq {
	id             string @[json: 'id']
	finished_at    ?time.Time @[json: 'finishedAt']
	result         ?u8 @[json: 'result']
	task_task_logs ?string @[json: 'taskTaskLogs']
}

pub struct UpdateTaskLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_task_log_repo(mut ctx Context, req UpdateTaskLogReq) !UpdateTaskLogResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	time_now := time.now()
	up_expr :=
		sql {
		}

	sql db {
		dynamic update JobTaskLog set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateTaskLogResp{
		msg: 'TaskLog updated successfully'
	}
}

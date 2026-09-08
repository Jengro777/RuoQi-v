module tasklog

import veb
import log
import json2 as json
import model.schema_job { JobTaskLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/find_task_log_by_id'; post]
pub fn (app &TaskLog) find_task_log_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[TaskLogByIdReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_task_log_by_id_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_task_log_by_id_usecase(mut ctx Context, req TaskLogByIdReq) !JobTaskLog {
	find_task_log_by_id_domain(req)!
	return find_task_log_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_task_log_by_id_domain(req TaskLogByIdReq) ! {
	if req.id == '' {
		return error('task log id is required')
	}
}

// ═══ DTO ═══
pub struct TaskLogByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_task_log_by_id_repo(mut ctx Context, req TaskLogByIdReq) !JobTaskLog {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	task_logs := sql db {
		select from JobTaskLog where id == req.id limit 1
	} or { return error('Failed: ${err}') }

	if task_logs.len == 0 {
		return error('TaskLog not found')
	}

	return task_logs[0]
}

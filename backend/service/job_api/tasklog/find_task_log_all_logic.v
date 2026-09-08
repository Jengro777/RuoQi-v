module tasklog

import veb
import log
import model.schema_job { JobTaskLog }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &TaskLog) find_task_log_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[TaskLogListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_task_log_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_task_log_all_usecase(mut ctx Context, req TaskLogListReq) !TaskLogListResp {
	find_task_log_all_domain(req)!
	return find_task_log_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_task_log_all_domain(req TaskLogListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct TaskLogListReq {
	page      int @[json: 'page']
	page_size int @[json: 'pageSize']
	result    []u8 @[json: 'result']
}

pub struct TaskLogData {
	id             string @[json: 'id']
	started_at     string @[json: 'startedAt']
	finished_at    string @[json: 'finishedAt']
	result         u8 @[json: 'result']
	task_task_logs ?string @[json: 'taskTaskLogs']
}

pub struct TaskLogListResp {
	total int
	data  []TaskLogData
}

// ═══ Repository ═══
fn find_task_log_all_repo(mut ctx Context, req TaskLogListReq) !TaskLogListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from JobTaskLog where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.result.len > 0 {result in req.result}
	}
	// vfmt on
	rows := sql db {
		dynamic select from JobTaskLog where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []TaskLogData{}
	for row in rows {
		datalist << TaskLogData{
			id: row.id
			started_at: row.started_at.format_ss()
			finished_at: row.finished_at.format_ss()
			result: row.result
			task_task_logs: row.task_task_logs
		}
	}

	return TaskLogListResp{
		total: count
		data: datalist
	}
}

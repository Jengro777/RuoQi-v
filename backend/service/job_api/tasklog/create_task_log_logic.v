module tasklog

import veb
import log
import time
import rand
import json2 as json
import model.schema_job { JobTask, JobTaskLog }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &TaskLog) create_task_log_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateTaskLogReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_task_log_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_task_log_usecase(mut ctx Context, req CreateTaskLogReq) !CreateTaskLogResp {
	create_task_log_domain(req)!
	return create_task_log_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_task_log_domain(req CreateTaskLogReq) ! {
	if req.task_task_logs == '' {
		return error('task reference (taskTaskLogs) is required')
	}
	if !req.started_at.is_zero() && !req.finished_at.is_zero() && req.finished_at < req.started_at {
		return error('finished_at must be on or after started_at')
	}
}

// ═══ DTO ═══
pub struct CreateTaskLogReq {
	started_at     time.Time @[json: 'startedAt']
	finished_at    time.Time @[json: 'finishedAt']
	result         u8 @[json: 'result']
	task_task_logs string @[json: 'taskTaskLogs']
}

pub struct CreateTaskLogResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_task_log_repo(mut ctx Context, req CreateTaskLogReq) !CreateTaskLogResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// Verify parent task exists
	parent_count := sql db {
		select count from JobTask where id == req.task_task_logs && del_flag == 0
	} or { return error('Failed to verify parent task: ${err}') }
	if parent_count == 0 {
		return error('parent task not found')
	}

	time_now := time.now()
	task_log := JobTaskLog{
		id: rand.uuid_v7()
		started_at: req.started_at
		finished_at: req.finished_at
		result: req.result
		task_task_logs: req.task_task_logs
		creator_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}

	sql db {
		insert task_log into JobTaskLog
	} or { return error('Failed to create TaskLog: ${err}') }

	return CreateTaskLogResp{
		msg: 'TaskLog created successfully'
	}
}

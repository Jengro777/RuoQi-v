module task

import veb
import log
import time
import rand
import json2 as json
import model.schema_job { JobTask }
import common.api
import model { Context }

// ═══ Handler ═══
@['/create'; post]
pub fn (app &Task) create_task_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateTaskReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := create_task_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn create_task_usecase(mut ctx Context, req CreateTaskReq) !CreateTaskResp {
	create_task_domain(req)!
	return create_task_repo(mut ctx, req)
}

// ═══ Domain ═══
fn create_task_domain(req CreateTaskReq) ! {
	if req.name == '' {
		return error('task name is required')
	}
	if req.cron_expression == '' {
		return error('cron expression is required')
	}
	validate_cron_expression(req.cron_expression)!
	if req.pattern == '' {
		return error('task pattern is required')
	}
}

// validate_cron_expression performs basic cron syntax validation.
fn validate_cron_expression(expr string) ! {
	fields := expr.split(' ')
	if fields.len != 5 {
		return error('cron expression must have exactly 5 space-separated fields')
	}
	for field in fields {
		if field == '' {
			return error('cron expression contains empty field')
		}
		if field == '*' {
			continue
		}
		if field.contains('*/') {
			parts := field.split('*/')
			if parts.len != 2 || parts[0] != '' {
				return error('invalid cron step syntax: ${field}')
			}
			// validate the step number
			parts[1].int()
			continue
		}
		if field.contains(',') {
			for sub in field.split(',') {
				if !is_valid_cron_atom(sub) {
					return error('invalid cron field value: ${sub}')
				}
			}
			continue
		}
		if !is_valid_cron_atom(field) {
			return error('invalid cron field value: ${field}')
		}
	}
}

fn is_valid_cron_atom(s string) bool {
	if s == '' {
		return false
	}
	// Allow ranges like 1-5
	if s.contains('-') {
		parts := s.split('-')
		if parts.len != 2 {
			return false
		}
		return is_valid_cron_number(parts[0]) && is_valid_cron_number(parts[1])
	}
	return is_valid_cron_number(s)
}

fn is_valid_cron_number(s string) bool {
	return s.is_int()
}

// ═══ DTO ═══
pub struct CreateTaskReq {
	name            string @[json: 'name']
	task_group      string @[json: 'taskGroup']
	cron_expression string @[json: 'cronExpression']
	pattern         string @[json: 'pattern']
	payload         string @[json: 'payload']
	status          u8 @[json: 'status']
}

pub struct CreateTaskResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn create_task_repo(mut ctx Context, req CreateTaskReq) !CreateTaskResp {
	time_now := time.now()
	task := JobTask{
		id: rand.uuid_v7()
		name: req.name
		task_group: req.task_group
		cron_expression: req.cron_expression
		pattern: req.pattern
		payload: req.payload
		status: req.status
		creator_id: ctx.svc_iam.user_id
		updater_id: ctx.svc_iam.user_id
		created_at: time_now
		updated_at: time_now
	}

	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert task into JobTask
	} or { return error('Failed to create Task: ${err}') }

	return CreateTaskResp{
		msg: 'Task created successfully'
	}
}

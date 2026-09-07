module task

import veb
import log
import time
import model.schema_job { JobTask }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &Task) find_task_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[TaskListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_task_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_task_all_usecase(mut ctx Context, req TaskListReq) !TaskListResp {
	find_task_all_domain(req)!
	return find_task_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_task_all_domain(req TaskListReq) ! {
	if req.page <= 0 {
		return error('page must be greater than 0')
	}
	if req.page_size <= 0 {
		return error('page_size must be greater than 0')
	}
}

// ═══ DTO ═══
pub struct TaskListReq {
	page       int @[json: 'page']
	page_size  int @[json: 'pageSize']
	name       string @[json: 'name']
	task_group string @[json: 'taskGroup']
	status     []u8 @[json: 'status']
}

pub struct TaskData {
	id              string @[json: 'id']
	name            string @[json: 'name']
	task_group      string @[json: 'taskGroup']
	cron_expression string @[json: 'cronExpression']
	pattern         string @[json: 'pattern']
	payload         string @[json: 'payload']
	status          u8 @[json: 'status']
	updater_id      ?string @[json: 'updaterId']
	creator_id      ?string @[json: 'creatorId']
	created_at      string @[json: 'createdAt']
	updated_at      string @[json: 'updatedAt']
	deleted_at      string @[json: 'deletedAt']
}

pub struct TaskListResp {
	total int
	data  []TaskData
}

// ═══ Repository ═══
fn find_task_all_repo(mut ctx Context, req TaskListReq) !TaskListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from JobTask where del_flag == 0
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		del_flag == 0,
		if req.name != '' {name == req.name},
		if req.task_group != '' {task_group == req.task_group},
		if req.status.len > 0 {status in req.status}
	}
	// vfmt on
	result := sql db {
		dynamic select from JobTask where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []TaskData{}
	for row in result {
		datalist << TaskData{
			id: row.id
			name: row.name
			task_group: row.task_group
			cron_expression: row.cron_expression
			pattern: row.pattern
			payload: row.payload
			status: row.status
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return TaskListResp{
		total: count
		data: datalist
	}
}

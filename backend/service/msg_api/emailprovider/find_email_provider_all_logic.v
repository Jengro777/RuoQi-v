module emailprovider

import veb
import log
import time
import model.schema_msg { MsgEmailProvider }
import common.api
import model { Context }
import json2 as json

// ═══ Handler ═══
@['/all'; get]
pub fn (app &EmailProvider) find_email_provider_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[EmailProviderListReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := find_email_provider_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_email_provider_all_usecase(mut ctx Context, req EmailProviderListReq) !EmailProviderListResp {
	find_email_provider_all_domain()
	return find_email_provider_all_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_email_provider_all_domain() {
}

// ═══ DTO ═══
pub struct EmailProviderListReq {
	page       int @[json: 'page']
	page_size  int @[json: 'pageSize']
	name       string @[json: 'name']
	email_addr string @[json: 'emailAddr']
}

pub struct EmailProviderData {
	id         string @[json: 'id']
	name       string @[json: 'name']
	auth_type  u8 @[json: 'authType']
	email_addr string @[json: 'emailAddr']
	host_name  string @[json: 'hostName']
	port       ?u32 @[json: 'port']
	tls        u8 @[json: 'tls']
	is_default u8 @[json: 'isDefault']
	updater_id ?string @[json: 'updaterId']
	creator_id ?string @[json: 'creatorId']
	created_at string @[json: 'createdAt']
	updated_at string @[json: 'updatedAt']
	deleted_at string @[json: 'deletedAt']
}

pub struct EmailProviderListResp {
	total int
	data  []EmailProviderData
}

// ═══ Repository ═══
fn find_email_provider_all_repo(mut ctx Context, req EmailProviderListReq) !EmailProviderListResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	mut count := sql db {
		select count from MsgEmailProvider
	} or { return error('Failed to execute SQL query: ${err}') }

	offset_num := (req.page - 1) * req.page_size
	// vfmt off
	where_expr := {
		if req.name != '' {name == req.name},
		if req.email_addr != '' {email_addr == req.email_addr}
	}
	// vfmt on
	result := sql db {
		dynamic select from MsgEmailProvider where where_expr limit req.page_size offset offset_num
	} or { return error('Failed to execute SQL query: ${err}') }

	mut datalist := []EmailProviderData{}
	for row in result {
		datalist << EmailProviderData{
			id: row.id
			name: row.name
			auth_type: row.auth_type
			email_addr: row.email_addr
			host_name: row.host_name
			port: row.port
			tls: row.tls
			is_default: row.is_default
			creator_id: row.creator_id
			updater_id: row.updater_id
			created_at: row.created_at.format_ss()
			updated_at: row.updated_at.format_ss()
			deleted_at: (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return EmailProviderListResp{
		total: count
		data: datalist
	}
}

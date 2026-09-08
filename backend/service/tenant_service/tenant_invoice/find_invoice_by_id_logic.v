module tenant_invoice

import veb
import log
import json2 as json
import model { Context }
import model.schema_tenant { TnInvoice }
import common.api as capi

// ═══ Handler ═══
@['/find_invoice_by_id'; post]
pub fn (app &TenantInvoice) find_invoice_by_id_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	req := json.decode[FindInvoiceByIdReq](ctx.req.data) or {
		return ctx.json(capi.json_error(code: capi.err_common_param_invalid, msg: err.msg()))
	}
	result := find_invoice_by_id_usecase(mut ctx, req) or {
		return ctx.json(capi.json_error(
			code: capi.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_invoice_by_id_usecase(mut ctx Context, req FindInvoiceByIdReq) !TnInvoice {
	find_invoice_by_id_domain(req)!
	return find_invoice_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_invoice_by_id_domain(req FindInvoiceByIdReq) ! {
	if req.id == '' {
		return error('id is required')
	}
}

// ═══ DTO ═══
pub struct FindInvoiceByIdReq {
	id string @[json: 'id']
}

// ═══ Repository ═══
fn find_invoice_by_id_repo(mut ctx Context, req FindInvoiceByIdReq) !TnInvoice {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	result := sql db {
		select from TnInvoice where id == req.id && del_flag == 0 limit 1
	} or { return error('Failed to query invoice: ${err}') }
	if result.len == 0 {
		return error('invoice not found')
	}
	return result[0]
}

module tenant_invoice

import veb
import log
import model { Context }
import model.schema_tenant { TnInvoice }
import common.api as capi

// ═══ Handler ═══
@['/find_invoice_all'; get]
pub fn (app &TenantInvoice) find_invoice_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	result := find_invoice_all_usecase(mut ctx) or {
		return ctx.json(capi.json_error(
			code: capi.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}
	return ctx.json(capi.json_success(data: result))
}

// ═══ Use Case ═══
pub fn find_invoice_all_usecase(mut ctx Context) ![]TnInvoice {
	return find_invoice_all_repo(mut ctx)
}

// ═══ Repository ═══
fn find_invoice_all_repo(mut ctx Context) ![]TnInvoice {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire scoped DB: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	items := sql db {
		select from TnInvoice where del_flag == 0
	} or { return error('Failed to query invoices: ${err}') }
	return items
}

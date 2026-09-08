module db_api

import veb
import log
import common.api
import model { Context }
import model.schema_tenant
import adapter.dbpool

fn (app &Database) init_tenant_tables(mut pool dbpool.DatabasePoolable) ! {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	mut db, conn := pool.acquire() or { return error('Failed to acquire connection: ${err}') }
	defer {
		pool.release(conn) or { log.warn('Failed to release connection ${@LOCATION}: ${err}') }
	}

	sql db {
		create table schema_tenant.TnTenant
		create table schema_tenant.TnSubProduct
		create table schema_tenant.TnSubPortal
		create table schema_tenant.TnMember
		create table schema_tenant.TnInvoice
		create table schema_tenant.TnConfig
	} or {
		if !err.msg().contains('already exists') {
			return error('error creating table: ${err}')
		}
	}
	log.info('schema_tenant init success')
	tenant_upsert(db) or { return error('Failed to upsert seed data: ${err}') }
	log.info('schema_tenant seed data success')

	return
}

@['/init/init_tenant'; get]
pub fn (app &Database) init_tenant(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')
	app.init_tenant_tables(mut ctx.dbpool) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'init_tenant failed: ${err}'
		))
	}
	return ctx.json(api.json_success(data: 'Tenant database init Successfull'))
}

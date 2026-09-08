module region_adm_div

import veb
import log
import time
import json2 as json
import model.schema_base { BaseRegionAdmDiv }
import common.api
import model { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &RegionAdmDiv) update_adm_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateAdmReq](ctx.req.data) or {
		return ctx.json(api.json_error(code: api.err_common_param_invalid, msg: err.msg()))
	}

	result := update_adm_usecase(mut ctx, req) or {
		return ctx.json(api.json_error(
			code: api.err_common_server
			msg: 'Internal Server Error: ${err}'
		))
	}

	return ctx.json(api.json_success(data: result))
}

// ═══ Use Case ═══
pub fn update_adm_usecase(mut ctx Context, req UpdateAdmReq) !UpdateAdmResp {
	// Domain 校验
	update_adm_domain(req)!

	// Repository 更新
	return update_adm_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_adm_domain(req UpdateAdmReq) ! {
	if req.id == '' {
		return error('Adm id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateAdmReq {
	id              string @[json: 'id']
	parent_id       ?string @[json: 'parentId']
	region_id       ?string @[json: 'regionId']
	sys_adm_code    ?string @[json: 'sysAdmCode']
	sys_adm_name    ?string @[json: 'sysAdmName']
	name_local      ?string @[json: 'nameLocal']
	govt_code       ?string @[json: 'govtCode']
	gid_zero        ?string @[json: 'gidZero']
	hasc            ?string @[json: 'hasc']
	iso_two         ?string @[json: 'isoTwo']
	iso_three       ?string @[json: 'isoThree']
	numeric         ?string @[json: 'numeric']
	postal_code     ?string @[json: 'postalCode']
	level           ?u8 @[json: 'level']
	tree_id         ?string @[json: 'treeId']
	coord_bounds    ?string @[json: 'coordBounds']
	sort            ?u64 @[json: 'sort']
	status          ?u8 @[json: 'status']
	adm_merger_name ?string @[json: 'admMergerName']
	adm_short_name  ?string @[json: 'admShortName']
	pinyin          ?string @[json: 'pinyin']
	first           ?string @[json: 'first']
	name_en         ?string @[json: 'nameEn']
	name_zh         ?string @[json: 'nameZh']
}

pub struct UpdateAdmResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_adm_repo(mut ctx Context, req UpdateAdmReq) !UpdateAdmResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr :=
		sql {
		}

	sql db {
		dynamic update BaseRegionAdmDiv set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateAdmResp{
		msg: 'Adm updated successfully'
	}
}

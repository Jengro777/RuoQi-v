module region_adm_div

import veb
import log
import time
import x.json2 as json
import structs.schema_base { BaseRegionAdmDiv }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/update'; post]
pub fn (app &RegionAdmDiv) update_adm_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateAdmReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_adm_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Usecase 层 -----------------
pub fn update_adm_usecase(mut ctx Context, req UpdateAdmReq) !UpdateAdmResp {
	// Domain 校验
	update_adm_domain(req)!

	// Repository 更新
	return update_adm(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn update_adm_domain(req UpdateAdmReq) ! {
	if req.id == '' {
		return error('Adm id is required')
	}
}

// ----------------- DTO 层 -----------------
pub struct UpdateAdmReq {
	id              string  @[json: 'id']
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
	level           ?u8     @[json: 'level']
	tree_id         ?string @[json: 'treeId']
	coord_bounds    ?string @[json: 'coordBounds']
	sort            ?u64    @[json: 'sort']
	status          ?u8     @[json: 'status']
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

// ----------------- Repository 层 -----------------
fn update_adm(mut ctx Context, req UpdateAdmReq) !UpdateAdmResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if parent_id := req.parent_id { parent_id == parent_id },
		if region_id := req.region_id { region_id == region_id },
		if sys_adm_code := req.sys_adm_code { sys_adm_code == sys_adm_code },
		if sys_adm_name := req.sys_adm_name { sys_adm_name == sys_adm_name },
		if name_local := req.name_local { name_local == name_local },
		if govt_code := req.govt_code { govt_code == govt_code },
		if gid_zero := req.gid_zero { gid_zero == gid_zero },
		if hasc := req.hasc { hasc == hasc },
		if iso_two := req.iso_two { iso_two == iso_two },
		if iso_three := req.iso_three { iso_three == iso_three },
		if numeric := req.numeric { numeric == numeric },
		if postal_code := req.postal_code { postal_code == postal_code },
		if level := req.level { level == level },
		if tree_id := req.tree_id { tree_id == tree_id },
		if coord_bounds := req.coord_bounds { coord_bounds == coord_bounds },
		if adm_merger_name := req.adm_merger_name { adm_merger_name == adm_merger_name },
		if adm_short_name := req.adm_short_name { adm_short_name == adm_short_name },
		if pinyin := req.pinyin { pinyin == pinyin },
		if first := req.first { first == first },
		if name_en := req.name_en { name_en == name_en },
		if name_zh := req.name_zh { name_zh == name_zh },
		if sort := req.sort { sort == sort },
		if status := req.status { status == status },
		updated_at == time.now()
	}

	sql db {
		dynamic update BaseRegionAdmDiv set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateAdmResp{
		msg: 'Adm updated successfully'
	}
}

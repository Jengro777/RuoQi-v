module region

import veb
import log
import time
import x.json2 as json
import structs.schema_base { BaseRegion }
import common.api
import structs { Context }

// ═══ Handler ═══
@['/update'; post]
pub fn (app &Region) update_region_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[UpdateRegionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := update_region_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn update_region_usecase(mut ctx Context, req UpdateRegionReq) !UpdateRegionResp {
	// Domain 校验
	update_region_domain(req)!

	// Repository 更新
	return update_region_repo(mut ctx, req)
}

// ═══ Domain ═══
fn update_region_domain(req UpdateRegionReq) ! {
	if req.id == '' {
		return error('region id is required')
	}
}

// ═══ DTO ═══
pub struct UpdateRegionReq {
	id                   string  @[json: 'id']
	sys_region_code      ?string @[json: 'sysRegionCode']
	sys_region_name      ?string @[json: 'sysRegionName']
	name_local           ?string @[json: 'nameLocal']
	langcode_local       ?string @[json: 'langcodeLocal']
	govt_code            ?string @[json: 'govtCode']
	gid_zero             ?string @[json: 'gidZero']
	hasc                 ?string @[json: 'hasc']
	iso_two              ?string @[json: 'isoTwo']
	iso_three            ?string @[json: 'isoThree']
	numeric              ?string @[json: 'numeric']
	international_prefix ?string @[json: 'internationalPrefix']
	phone_area_code      ?string @[json: 'phoneAreaCode']
	postal_code          ?string @[json: 'postalCode']
	domain_name          ?string @[json: 'domainName']
	continent_code       ?string @[json: 'continentCode']
	coord_bounds         ?string @[json: 'coordBounds']
	sort                 ?int    @[json: 'sort']
	status               ?u8     @[json: 'status']
	name_en              ?string @[json: 'nameEn']
	name_zh              ?string @[json: 'nameZh']
}

pub struct UpdateRegionResp {
	msg string @[json: 'msg']
}

// ═══ Repository ═══
fn update_region_repo(mut ctx Context, req UpdateRegionReq) !UpdateRegionResp {
	db, conn := ctx.acquire_scoped() or { return error('Failed to acquire DB conn: ${err}') }
	defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

	up_expr := {
		if sys_region_code := req.sys_region_code { sys_region_code == sys_region_code },
		if sys_region_name := req.sys_region_name { sys_region_name == sys_region_name },
		if name_local := req.name_local { name_local == name_local },
		if langcode_local := req.langcode_local { langcode_local == langcode_local },
		if govt_code := req.govt_code { govt_code == govt_code },
		if gid_zero := req.gid_zero { gid_zero == gid_zero },
		if hasc := req.hasc { hasc == hasc },
		if iso_two := req.iso_two { iso_two == iso_two },
		if iso_three := req.iso_three { iso_three == iso_three },
		if numeric := req.numeric { numeric == numeric },
		if international_prefix := req.international_prefix {
			international_prefix == international_prefix
		},
		if phone_area_code := req.phone_area_code { phone_area_code == phone_area_code },
		if postal_code := req.postal_code { postal_code == postal_code },
		if domain_name := req.domain_name { domain_name == domain_name },
		if continent_code := req.continent_code { continent_code == continent_code },
		if coord_bounds := req.coord_bounds { coord_bounds == coord_bounds },
		if name_en := req.name_en { name_en == name_en },
		if name_zh := req.name_zh { name_zh == name_zh },
		if sort := req.sort { sort == sort },
		if status := req.status { status == status },
		updated_at == time.now()
	}

	sql db {
		dynamic update BaseRegion set up_expr where id == req.id
	} or { return error('Failed to execute SQL query: ${err}') }

	return UpdateRegionResp{
		msg: 'regiion updated successfully'
	}
}

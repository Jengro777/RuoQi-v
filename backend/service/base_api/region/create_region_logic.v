module region

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_base { BaseRegion }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &Region) create_region_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateRegionReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_region_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_region_usecase(mut ctx Context, req CreateRegionReq) !CreateRegionResp {
	create_region_domain(req)!
	return create_region(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn create_region_domain(req CreateRegionReq) ! {
	// if req.path == '' {
	// 	return error('path is required')
	// }
	// if req.method == '' {
	// 	return error('method is required')
	// }
	// if req.service_name == '' {
	// 	return error('service_name is required')
	// }
}

// ----------------- DTO 层 -----------------
pub struct CreateRegionReq {
	sys_region_code      string  @[json: 'sysRegionCode']
	sys_region_name      string  @[json: 'sysRegionName']
	name_local           string  @[json: 'nameLocal']
	langcode_local       string  @[json: 'langcodeLocal']
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
	status               u8      @[json: 'status']
	name_en              ?string @[json: 'nameEn']
	name_zh              ?string @[json: 'nameZh']
	updater_id           ?string @[json: 'updaterId']
	creator_id           ?string @[json: 'creatorId']
}

pub struct CreateRegionResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_region(mut ctx Context, req CreateRegionReq) !CreateRegionResp {
	time_now := time.now()
	base_region := BaseRegion{
		id:                   rand.uuid_v7()
		sys_region_code:      req.sys_region_code
		sys_region_name:      req.sys_region_name
		name_local:           req.name_local
		langcode_local:       req.langcode_local
		govt_code:            req.govt_code
		gid_zero:             req.gid_zero
		hasc:                 req.hasc
		iso_two:              req.iso_two
		iso_three:            req.iso_three
		numeric:              req.numeric
		international_prefix: req.international_prefix
		phone_area_code:      req.phone_area_code
		postal_code:          req.postal_code
		domain_name:          req.domain_name
		continent_code:       req.continent_code
		coord_bounds:         req.coord_bounds
		sort:                 req.sort
		status:               req.status
		name_en:              req.name_en
		name_zh:              req.name_zh
		updater_id:           req.updater_id
		creator_id:           req.creator_id
		created_at:           time_now
		updated_at:           time_now
	}

	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_region into BaseRegion
	} or { return error('Failed to create Region: ${err}') }

	return CreateRegionResp{
		msg: 'Region created successfully'
	}
}

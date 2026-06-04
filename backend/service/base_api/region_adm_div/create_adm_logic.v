module region_adm_div

import veb
import log
import time
import rand
import x.json2 as json
import structs.schema_base { BaseRegionAdmDiv }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/create'; post]
pub fn (app &RegionAdmDiv) create_adm_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[CreateAdmReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := create_adm_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn create_adm_usecase(mut ctx Context, req CreateAdmReq) !CreateAdmResp {
	// create_adm_domain(req)!
	return create_adm_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
// fn create_adm_domain(req CreateAdmReq) ! {
// if req.path == '' {
// 	return error('path is required')
// }
// if req.method == '' {
// 	return error('method is required')
// }
// if req.service_name == '' {
// 	return error('service_name is required')
// }
// }

// ----------------- DTO 层 -----------------
pub struct CreateAdmReq {
	parent_id       string  @[json: 'parentId']
	region_id       string  @[json: 'regionId']
	sys_adm_code    string  @[json: 'sysAdmCode']
	sys_adm_name    string  @[json: 'sysAdmName']
	name_local      ?string @[json: 'nameLocal']
	govt_code       ?string @[json: 'govtCode']
	gid_zero        ?string @[json: 'gidZero']
	hasc            ?string @[json: 'hasc']
	iso_two         ?string @[json: 'isoTwo']
	iso_three       ?string @[json: 'isoThree']
	numeric         ?string @[json: 'numeric']
	postal_code     ?string @[json: 'postalCode']
	level           u8      @[json: 'level']
	tree_id         string  @[json: 'treeId']
	coord_bounds    ?string @[json: 'coordBounds']
	sort            ?u64    @[json: 'sort']
	status          u8      @[json: 'status']
	adm_merger_name ?string @[json: 'admMergerName']
	adm_short_name  ?string @[json: 'admShortName']
	pinyin          ?string @[json: 'pinyin']
	first           string  @[json: 'first']
	name_en         ?string @[json: 'nameEn']
	name_zh         ?string @[json: 'nameZh']
	updater_id      ?string @[json: 'updaterId']
	creator_id      ?string @[json: 'creatorId']
}

pub struct CreateAdmResp {
	msg string @[json: 'msg']
}

// ----------------- Repository 层 -----------------
fn create_adm_repo(mut ctx Context, req CreateAdmReq) !CreateAdmResp {
	time_now := time.now()
	base_region := BaseRegionAdmDiv{
		id:              rand.uuid_v7()
		parent_id:       req.parent_id
		region_id:       req.region_id
		sys_adm_code:    req.sys_adm_code
		sys_adm_name:    req.sys_adm_name
		name_local:      req.name_local
		govt_code:       req.govt_code
		gid_zero:        req.gid_zero
		hasc:            req.hasc
		iso_two:         req.iso_two
		iso_three:       req.iso_three
		numeric:         req.numeric
		postal_code:     req.postal_code
		level:           req.level
		tree_id:         req.tree_id
		coord_bounds:    req.coord_bounds
		sort:            req.sort
		status:          req.status
		adm_merger_name: req.adm_merger_name
		adm_short_name:  req.adm_short_name
		pinyin:          req.pinyin
		first:           req.first
		name_en:         req.name_en
		name_zh:         req.name_zh
		updater_id:      req.updater_id
		creator_id:      req.creator_id
		created_at:      time_now
		updated_at:      time_now
	}

	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	sql db {
		insert base_region into BaseRegionAdmDiv
	} or { return error('Failed to create Region: ${err}') }

	return CreateAdmResp{
		msg: 'Adm created successfully'
	}
}

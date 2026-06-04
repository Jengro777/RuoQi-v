module region_adm_div

import veb
import log
import time
import x.json2 as json
import structs.schema_base { BaseRegionAdmDiv }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/all'; get]
pub fn (app &RegionAdmDiv) find_region_adm_all_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[RegionAdmListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := find_region_adm_all_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn find_region_adm_all_usecase(mut ctx Context, req RegionAdmListReq) !RegionAdmListResp {
	find_region_adm_all_domain()
	return find_region_adm_all_repo(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn find_region_adm_all_domain() {
}

// ----------------- DTO 层 -----------------
pub struct RegionAdmListReq {
	region_id string @[json: 'regionId']
}

pub struct RegionAdmData {
	id              string  @[json: 'id']
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
	created_at      string  @[json: 'createdAt']
	updated_at      string  @[json: 'updatedAt']
	deleted_at      string  @[json: 'deletedAt']
}

pub struct RegionAdmListResp {
	total int
	data  []RegionAdmData
}

// ----------------- Repository 层 -----------------
fn find_region_adm_all_repo(mut ctx Context, req RegionAdmListReq) !RegionAdmListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	result := sql db {
		select from BaseRegionAdmDiv where id == req.region_id
	} or { return error('Failed to execute SQL query: ${err}') }

	if result.len == 0 {
		return error('BaseRegionAdmDiv not found')
	}

	// 构造返回数据
	mut datalist := []RegionAdmData{}
	for row in result {
		datalist << RegionAdmData{
			id:              row.id
			parent_id:       row.parent_id
			region_id:       row.region_id
			sys_adm_code:    row.sys_adm_code
			sys_adm_name:    row.sys_adm_name
			name_local:      row.name_local
			govt_code:       row.govt_code
			gid_zero:        row.gid_zero
			hasc:            row.hasc
			iso_two:         row.iso_two
			iso_three:       row.iso_three
			numeric:         row.numeric
			postal_code:     row.postal_code
			level:           row.level
			tree_id:         row.tree_id
			coord_bounds:    row.coord_bounds
			sort:            row.sort
			status:          row.status
			adm_merger_name: row.adm_merger_name
			adm_short_name:  row.adm_short_name
			pinyin:          row.pinyin
			first:           row.first
			name_en:         row.name_en
			name_zh:         row.name_zh
			updater_id:      row.updater_id
			creator_id:      row.creator_id
			created_at:      row.created_at.format_ss()
			updated_at:      row.updated_at.format_ss()
			deleted_at:      (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return RegionAdmListResp{
		data: datalist
	}
}

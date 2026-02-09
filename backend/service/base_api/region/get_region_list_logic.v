module region

import veb
import log
import time
import orm
import structs.schema_base { BaseRegion }
import common.api
import structs { Context }
import x.json2 as json

// ----------------- Handler 层 -----------------
@['/list'; get]
pub fn (app &Region) get_region_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[RegionListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_region_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_region_list_usecase(mut ctx Context, req RegionListReq) !RegionListResp {
	get_region_list_domain()
	return get_region_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_region_list_domain() {
}

// ----------------- DTO 层 -----------------
pub struct RegionListReq {
	page                 int    @[json: 'page']
	page_size            int    @[json: 'pageSize']
	sys_region_code      string @[json: 'sysRegionCode']
	sys_region_name      string @[json: 'sysRegionName']
	name_local           string @[json: 'nameLocal']
	langcode_local       string @[json: 'langcodeLocal']
	govt_code            string @[json: 'govtCode']
	gid_zero             string @[json: 'gidZero']
	hasc                 string @[json: 'hasc']
	iso_two              string @[json: 'isoTwo']
	iso_three            string @[json: 'isoThree']
	numeric              string @[json: 'numeric']
	international_prefix string @[json: 'internationalPrefix']
	phone_area_code      string @[json: 'phoneAreaCode']
	postal_code          string @[json: 'postalCode']
	domain_name          string @[json: 'domainName']
	continent_code       string @[json: 'continentCode']
	coord_bounds         string @[json: 'coordBounds']
	status               []u8   @[json: 'status']
	name_en              string @[json: 'nameEn']
	name_zh              string @[json: 'nameZh']
}

pub struct RegionData {
	id                   string  @[json: 'id']
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
	created_at           string  @[json: 'createdAt']
	updated_at           string  @[json: 'updatedAt']
	deleted_at           string  @[json: 'deletedAt']
}

pub struct RegionListResp {
	total int
	data  []RegionData
}

// ----------------- Repository 层 -----------------
fn get_region_list(mut ctx Context, req RegionListReq) !RegionListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from BaseRegion
	}!

	offset_num := (req.page - 1) * req.page_size

	mut q := orm.new_query[BaseRegion](db).select()!

	if req.sys_region_code != '' {
		q = q.where('sys_region_code = ?', req.sys_region_code)!
	}
	if req.sys_region_name != '' {
		q = q.where('sys_region_name = ?', req.sys_region_name)!
	}
	if req.name_local != '' {
		q = q.where('name_local = ?', req.name_local)!
	}
	if req.langcode_local != '' {
		q = q.where('langcode_local = ?', req.langcode_local)!
	}
	if req.govt_code != '' {
		q = q.where('govt_code = ?', req.govt_code)!
	}
	if req.gid_zero != '' {
		q = q.where('gid_zero = ?', req.gid_zero)!
	}
	if req.hasc != '' {
		q = q.where('hasc = ?', req.hasc)!
	}
	if req.iso_two != '' {
		q = q.where('iso_two = ?', req.iso_two)!
	}
	if req.iso_three != '' {
		q = q.where('iso_three = ?', req.iso_three)!
	}
	if req.numeric != '' {
		q = q.where('numeric = ?', req.numeric)!
	}
	if req.international_prefix != '' {
		q = q.where('international_prefix = ?', req.international_prefix)!
	}
	if req.phone_area_code != '' {
		q = q.where('phone_area_code = ?', req.phone_area_code)!
	}
	if req.postal_code != '' {
		q = q.where('postal_code = ?', req.postal_code)!
	}
	if req.domain_name != '' {
		q = q.where('domain_name = ?', req.domain_name)!
	}
	if req.continent_code != '' {
		q = q.where('continent_code = ?', req.continent_code)!
	}
	if req.coord_bounds != '' {
		q = q.where('coord_bounds = ?', req.coord_bounds)!
	}
	if req.status.len > 0 {
		q = q.where('status in ?', req.status.map(orm.Primitive(it)))!
	}
	if req.name_en != '' {
		q = q.where('name_en = ?', req.name_en)!
	}
	if req.name_zh != '' {
		q = q.where('name_zh = ?', req.name_zh)!
	}

	result := q.order(.asc, 'sort')!.limit(req.page_size)!.offset(offset_num)!.query()!

	// 构造返回数据
	mut datalist := []RegionData{}
	for row in result {
		datalist << RegionData{
			id:                   row.id
			sys_region_code:      row.sys_region_code
			sys_region_name:      row.sys_region_name
			name_local:           row.name_local
			langcode_local:       row.langcode_local
			govt_code:            row.govt_code
			gid_zero:             row.gid_zero
			hasc:                 row.hasc
			iso_two:              row.iso_two
			iso_three:            row.iso_three
			numeric:              row.numeric
			international_prefix: row.international_prefix
			phone_area_code:      row.phone_area_code
			postal_code:          row.postal_code
			domain_name:          row.domain_name
			continent_code:       row.continent_code
			coord_bounds:         row.coord_bounds
			sort:                 row.sort
			status:               row.status
			name_en:              row.name_en
			name_zh:              row.name_zh
			updater_id:           row.updater_id
			creator_id:           row.creator_id
			created_at:           row.created_at.format_ss()
			updated_at:           row.updated_at.format_ss()
			deleted_at:           (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return RegionListResp{
		total: count
		data:  datalist
	}
}

module language

import veb
import log
import time
import orm
import structs.schema_base { BaseLanguage }
import common.api
import structs { Context }
import x.json2 as json

// ----------------- Handler 层 -----------------
@['/list'; get]
pub fn (app &Language) get_language_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	req := json.decode[LanguageListReq](ctx.req.data) or {
		return ctx.json(api.json_error_400(err.msg()))
	}

	result := get_language_list_usecase(mut ctx, req) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_language_list_usecase(mut ctx Context, req LanguageListReq) !LanguageListResp {
	get_language_list_domain()
	return get_language_list(mut ctx, req)
}

// ----------------- Domain 层 -----------------
fn get_language_list_domain() {
}

// ----------------- DTO 层 -----------------
pub struct LanguageListReq {
	page                     int    @[json: 'page']
	page_size                int    @[json: 'pageSize']
	language_self_proclaimed string @[json: 'languageSelfProclaimed']
	language_code            string @[json: 'languageCode']
	two_letter_code          string @[json: 'twoLetterCode']
	three_letter_code        string @[json: 'threeLetterCode']
	utf8_encoding            string @[json: 'utf8Encoding']
	status                   []u8   @[json: 'status']
	is_basic                 u8     @[json: 'isBasic']
}

pub struct LanguageData {
	id                       string  @[json: 'id']
	language_self_proclaimed string  @[json: 'languageSelfProclaimed']
	language_code            string  @[json: 'languageCode']
	two_letter_code          string  @[json: 'twoLetterCode']
	three_letter_code        string  @[json: 'threeLetterCode']
	utf8_encoding            string  @[json: 'utf8Encoding']
	sort                     ?int    @[json: 'sort']
	status                   u8      @[json: 'status']
	is_basic                 u8      @[json: 'isBasic']
	updater_id               ?string @[json: 'updaterId']
	creator_id               ?string @[json: 'creatorId']
	created_at               string  @[json: 'createdAt']
	updated_at               string  @[json: 'updatedAt']
	deleted_at               string  @[json: 'deletedAt']
}

pub struct LanguageListResp {
	total int
	data  []LanguageData
}

// ----------------- Repository 层 -----------------
fn get_language_list(mut ctx Context, req LanguageListReq) !LanguageListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from BaseLanguage
	}!

	offset_num := (req.page - 1) * req.page_size

	mut q := orm.new_query[BaseLanguage](db).select()!

	if req.language_self_proclaimed != '' {
		q = q.where('language_self_proclaimed = ?', req.language_self_proclaimed)!
	}
	if req.language_code != '' {
		q = q.where('language_code = ?', req.language_code)!
	}
	if req.two_letter_code != '' {
		q = q.where('two_letter_code = ?', req.two_letter_code)!
	}
	if req.three_letter_code != '' {
		q = q.where('three_letter_code = ?', req.three_letter_code)!
	}
	if req.utf8_encoding != '' {
		q = q.where('utf8_encoding = ?', req.utf8_encoding)!
	}
	if req.status.len > 0 {
		q = q.where('status in ?', req.status.map(orm.Primitive(it)))!
	}
	if req.is_basic != 0 {
		q = q.where('is_basic = ?', req.is_basic)!
	}

	result := q.order(.asc, 'sort')!.limit(req.page_size)!.offset(offset_num)!.query()!

	// 构造返回数据
	mut datalist := []LanguageData{}
	for row in result {
		datalist << LanguageData{
			id:                       row.id
			language_self_proclaimed: row.language_self_proclaimed
			language_code:            row.language_code
			two_letter_code:          row.two_letter_code
			three_letter_code:        row.three_letter_code
			utf8_encoding:            row.utf8_encoding
			sort:                     row.sort
			status:                   row.status
			is_basic:                 row.is_basic
			updater_id:               row.updater_id
			creator_id:               row.creator_id
			created_at:               row.created_at.format_ss()
			updated_at:               row.updated_at.format_ss()
			deleted_at:               (row.deleted_at or { time.Time{} }).format_ss()
		}
	}

	return LanguageListResp{
		total: count
		data:  datalist
	}
}

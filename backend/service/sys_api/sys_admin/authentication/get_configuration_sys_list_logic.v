module authentication

import veb
import log
import structs.schema_sys { SysConfiguration }
import common.api
import structs { Context }

// ----------------- Handler 层 -----------------
@['/system/list'; get]
pub fn (app &Authentication) configuration_system_list_handler(mut ctx Context) veb.Result {
	log.debug('${@METHOD}  ${@MOD}.${@FILE_LINE}')

	// Usecase 执行
	result := get_configuration_system_list_usecase(mut ctx) or {
		return ctx.json(api.json_error_500('Internal Server Error: ${err}'))
	}

	return ctx.json(api.json_success_200(result))
}

// ----------------- Application Service | Usecase 层 -----------------
pub fn get_configuration_system_list_usecase(mut ctx Context) !GetConfigurationSystemListResp {
	// Domain 校验
	get_configuration_system_list_domain()!

	// Repository 查询
	return get_configuration_system_list_repo(mut ctx)
}

// ----------------- Domain 层 -----------------
fn get_configuration_system_list_domain() ! {
	//
}

// ----------------- DTO 层 -----------------
pub struct GetConfigurationSystemListReq {
	//
}

pub struct ConfigurationSystemData {
	category   string  @[json: 'category'] // Configuration category | 配置的分类
	id         string  @[json: 'id']
	status     bool    @[json: 'status']    // tate true: normal false: ban | 状态 true 正常 false 禁用
	name       string  @[json: 'name']      // Configurarion name | 配置名称
	key        string  @[json: 'key']       // Configuration key | 配置的键名
	value      string  @[json: 'value']     // Configuraion value | 配置的值
	remark     ?string @[json: 'remark']    // Remark | 备注
	sort       u32     @[json: 'sort']      // Sort Number | 排序编号
	created_at u32     @[json: 'createdAt'] // Create date | 创建日期
	updated_at u32     @[json: 'updatedAt'] // Update date | 更新日期
}

pub struct GetConfigurationSystemListResp {
	total int
	data  ?[]ConfigurationSystemData @[json: 'data']
}

// ----------------- Repository 层 -----------------
fn get_configuration_system_list_repo(mut ctx Context) !GetConfigurationSystemListResp {
	db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
	defer {
		ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
	}

	// 总数统计
	mut count := sql db {
		select count from SysConfiguration
	}!

	mut result := sql db {
		select from SysConfiguration
	}!

	// 数据封装
	mut datalist := []ConfigurationSystemData{}
	for row in result {
		datalist << ConfigurationSystemData{
			id:         row.id
			status:     (row.status) == 0
			name:       row.name
			key:        row.key
			value:      row.value
			category:   row.category
			remark:     row.remark
			sort:       row.sort
			created_at: row.created_at.format_ss().u32()
			updated_at: row.updated_at.format_ss().u32()
		}
	}

	return GetConfigurationSystemListResp{
		total: count
		data:  if datalist.len > 0 { datalist } else { none }
	}
}

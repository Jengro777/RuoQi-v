module schema_base

import time

@[comment: '国家/地区下辖行政区域表: adm_div']
@[table: 'base_administrative_division']
pub struct BaseAdministrativeDivision {
pub:
	id                  string  @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	parent_country_id   string  @[comment: 'Country ID | 国家/地区 id'; required; sql: 'parent_country_id'; sql_type: 'CHAR(36)']
	parent_adm_id       string  @[comment: 'Parent adm area ID | 父级行政id'; required; sql: 'parent_adm_id'; sql_type: 'CHAR(36)']
	sys_adm_name        string  @[comment: 'System name local | 行政地区简称（系统字段）'; required; sql: 'sys_adm_name'; sql_type: 'VARCHAR(255)']
	sys_adm_code        string  @[comment: 'System adm code | 行政代码(系统字段)'; required; sql: 'sys_adm_code'; sql_type: 'VARCHAR(255)']
	parent_sys_adm_code string  @[comment: 'Parent administrative division code | 父级别行政编码(系统字段)'; required; sql: 'parent_sys_adm_code'; sql_type: 'VARCHAR(255)']
	sys_country_code    string  @[comment: 'System country code | 系统内部使用的国家代码（系统字段）'; required; sql: 'sys_country_code'; sql_type: 'VARCHAR(255)']
	name_local          ?string @[comment: 'Name local | 行政地区本地语简称'; sql_type: 'VARCHAR(255)']
	govt_code           ?string @[comment: 'Government code | 各国家本土标准行政代码'; sql_type: 'VARCHAR(255)']
	gid_zero            ?string @[comment: 'GID_0 | GADM数据库国家标识字段'; sql_type: 'VARCHAR(255)']
	hasc                ?string @[comment: 'HASC编码(如北京：CN.BJ)'; sql_type: 'VARCHAR(255)']
	iso_two             ?string @[comment: 'Alpha-2 code(ISO 3166-2)'; sql_type: 'VARCHAR(255)']
	iso_three           ?string @[comment: 'Alpha-3 code(ISO 3166-3)'; sql_type: 'VARCHAR(255)']
	numeric             ?string @[comment: 'ISO 3166-1 numeric | 数字代码'; sql_type: 'VARCHAR(255)']
	postal_code         ?string @[comment: 'zip/postal code | 邮政编码'; sql_type: 'VARCHAR(255)']
	level               u8      @[comment: 'ADM level | 行政区域等级（1-5级）'; default: 1; sql_type: 'TINYINT']
	tree_id             string  @[comment: 'Tree adm ID | 树行政id'; required; sql: 'tree_id'; sql_type: 'CHAR(36)']
	coord_bounds        ?string @[comment: 'Geographical Coordinate Boundaries | 地理坐标边界'; sql_type: 'LONGTEXT']
	sort                ?u64    @[comment: 'Sort number | 排序编号'; sql_type: 'BIGINT UNSIGNED']
	status              u8      @[comment: 'Status  0: normal 1: ban | 状态'; default: 0; sql_type: 'TINYINT UNSIGNED']
	adm_merger_name     ?string @[comment: 'ADM merger name | 行政区合并名称[数组]（本地语）'; sql_type: 'VARCHAR(255)']
	adm_short_name      ?string @[comment: 'ADM short name | 简称（本地语）'; sql_type: 'VARCHAR(255)']
	pinyin              ?string @[comment: 'ADM pinyin | 拼音'; sql_type: 'VARCHAR(255)']
	first               string  @[comment: '首字母'; default: '0'; sql_type: 'VARCHAR(50)']
	name_en             ?string @[comment: 'English short name(ISO) | 英文简称'; sql_type: 'VARCHAR(255)']
	name_zh             ?string @[comment: 'zh_CN short name(ISO) | 中文简称'; sql_type: 'VARCHAR(255)']

	updater_id ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '逻辑删除，0：未删除，1：已删除'; default: 0; sql_type: 'TINYINT UNSIGNED']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; sql_type: 'TIMESTAMP']
}

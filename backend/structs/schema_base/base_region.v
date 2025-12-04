module schema_base

import time

@[comment: '国家/地区表']
@[table: 'base_region']
pub struct BaseRegion {
pub:
	id                   string  @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	sys_name             string  @[comment: 'Name local | 地区&国家简称（系统实际使用字段）'; required; sql: 'sys_name'; sql_type: 'VARCHAR(255)']
	sys_country_code     string  @[comment: 'System country code | 系统内部使用的国家代码（系统字段）'; required; sql: 'sys_country_code'; sql_type: 'VARCHAR(255)']
	name_local           string  @[comment: 'Name local | 地区&国家本地语简称'; required; sql: 'name_local'; sql_type: 'VARCHAR(255)']
	langcode_local       string  @[comment: 'Local language code | 本地语代码'; required; sql: 'langcode_local'; sql_type: 'VARCHAR(255)']
	govt_code            ?string @[comment: 'Government code | 各国家本土标准代码(如GB/T 2260-2020)'; sql_type: 'VARCHAR(255)']
	gid_zero             ?string @[comment: 'GID_0 | GADM数据库中的字段，用于标识国家'; sql_type: 'VARCHAR(255)']
	hasc                 ?string @[comment: 'Hierarchical Administrative Subdivision Codes (HASC_0)'; sql_type: 'VARCHAR(255)']
	iso_two              ?string @[comment: 'Alpha-2 code(ISO 3166-2) | 两字母代码'; sql_type: 'VARCHAR(255)']
	iso_three            ?string @[comment: 'Alpha-3 code(ISO 3166-3) | 三字母代码'; sql_type: 'VARCHAR(255)']
	numeric              ?string @[comment: 'ISO 3166-1 numeric | 数字代码'; sql_type: 'VARCHAR(255)']
	international_prefix ?string @[comment: 'International dialing prefix | 国际冠码'; sql_type: 'VARCHAR(255)']
	phone_area_code      ?string @[comment: 'International phone area code | 国际电话区号'; sql_type: 'VARCHAR(255)']
	postal_code          ?string @[comment: 'International postal code | 国际邮编'; sql_type: 'VARCHAR(255)']
	domain_name          ?string @[comment: 'International domain names (IDN) | 国际域名'; sql_type: 'VARCHAR(255)']
	continent_code       ?string @[comment: 'Big week code | 所属大州字母代码'; sql_type: 'VARCHAR(255)']
	coord_bounds         ?string @[comment: 'Geographical Coordinate Boundaries | 地理坐标边界'; sql_type: 'LONGTEXT']
	sort                 ?int    @[comment: 'Sort Number | 排序编号'; sql_type: 'INT UNSIGNED']
	status               u8      @[comment: 'Status  0: normal 1: ban | 状态'; default: 0; sql_type: 'TINYINT UNSIGNED']
	name_en              ?string @[comment: 'English short name(ISO) | 地区&国家简称(英文)'; sql_type: 'VARCHAR(255)']
	name_zh              ?string @[comment: 'zh_CN short name(ISO) | 地区&国家简称(中文)'; sql_type: 'VARCHAR(255)']

	updater_id ?string    @[comment: '修改者ID'; sql_type: 'CHAR(36)']
	updated_at time.Time  @[comment: 'Update Time | 修改日期'; sql_type: 'TIMESTAMP']
	creator_id ?string    @[comment: '创建者ID'; immutable; sql_type: 'CHAR(36)']
	created_at time.Time  @[comment: 'Create Time | 创建日期'; immutable; sql_type: 'TIMESTAMP']
	del_flag   u8         @[comment: '逻辑删除，0：未删除，1：已删除'; default: 0; sql_type: 'TINYINT UNSIGNED']
	deleted_at ?time.Time @[comment: 'Delete Time | 删除日期'; sql_type: 'TIMESTAMP']
}

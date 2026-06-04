module schema_base

//未研究明白如何使用,这里仅做简单说明
/*
时区数据库（通常称为tz或zoneinfo）包含代表全球许多代表性地点的本地时间历史的代码和数据。
它会定期更新以反映政治机构对时区边界、UTC 偏移量和夏令时规则所做的更改。
数据来源：https://www.iana.org/time-zones
*/

@[table: 'base_time_zone']
@[comment: '时区表']
pub struct BaseTimeZone {
pub:
	id             string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	sort           ?int   @[comment: 'Sort Number | 排序编号'; sql_type: 'INT UNSIGNED']
	time_zone_city string @[comment: '时区ID'; sql_type: 'VARCHAR(255)']
	utc_offset     int    @[comment: 'UTC偏移量'; sql_type: 'INT']
	summer_start   int    @[comment: '夏令时开始时间'; sql_type: 'INT']
	summer_end     int    @[comment: '夏令时结束时间'; sql_type: 'INT']
}

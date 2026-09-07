module schema_base

import time

/*
1.协调世界时（UTC：Coordinated Universal Time)，又称：世界统一时间，世界标准时间；
2.计算的区时=已知区时－（已知区时的时区-要计算区时的时区（注：东时区为正，西时区为负）；
3.区时定义：本时区的中央经线的地方时。(区时是整数的)
*/

@[table: 'base_time_utc']
@[comment: '时区表']
pub struct BaseUtc {
pub:
	id              string @[comment: 'UUID'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	sort            ?int @[comment: 'Sort Number | 排序编号'; sql_type: 'integer']
	name            string @[comment: '时区名称'; sql_type: 'VARCHAR(255)']
	lng_range_start f64 @[comment: '经度范围:经度起始值,东正西负'; sql_type: 'FLOAT']
	lng_range_end   f64 @[comment: '经度范围:经度结束值,东正西负'; sql_type: 'FLOAT']
	lng_mid         f64 @[comment: '经度中值/时区中心线: 0和180 特殊值'; sql_type: 'FLOAT']
	updater_id      ?string @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at      time.Time @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id      ?string @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at      time.Time @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag        i8 @[comment: '删除标记，-1：已删除，0：未删除'; default: 0; omitempty; sql_type: 'smallint']
	deleted_at      ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}

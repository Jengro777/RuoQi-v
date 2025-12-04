module schema_sys

import time

@[table: 'sys_department']
@[unique_key: 'id,parent_id']
@[comment: '部门表']
pub struct SysDepartment {
pub:
	id               string     @[comment: 'UUID rand.uuid_v7()'; immutable; primary; sql: 'id'; sql_type: 'CHAR(36)']
	parent_id        string     @[comment: 'Parent department ID | 父级部门ID'; omitempty; sql_type: 'CHAR(36)']
	name             string     @[comment: 'Department name | 部门名称'; sql_type: 'VARCHAR(255)']
	leader           ?string    @[comment: 'Department leader | 部门负责人'; omitempty; sql_type: 'VARCHAR(255)']
	phone            ?string    @[comment: 'Leader`s phone number | 负责人电话'; omitempty; sql_type: 'VARCHAR(255)']
	email            ?string    @[comment: 'Leader`s email | 部门负责人电子邮箱'; omitempty; sql_type: 'VARCHAR(255)']
	remark           ?string    @[comment: 'Remark | 备注'; omitempty; sql_type: 'VARCHAR(255)']
	org_type         u32        @[comment: 'Department Type: 0->Regular | 组织类型: 0->普通机构'; default: 0; sql_type: 'int(32)']
	country          ?string    @[comment: 'country | 国家'; omitempty; sql_type: 'VARCHAR(255)']
	province_state   ?string    @[comment: 'Province/State | 省/州'; omitempty; sql_type: 'VARCHAR(255)']
	city             ?string    @[comment: 'City | 市'; omitempty; sql_type: 'VARCHAR(255)']
	district         ?string    @[comment: 'District | 区'; omitempty; sql_type: 'VARCHAR(255)']
	detail_address   ?string    @[comment: 'Detail Address | 详细地址'; omitempty; sql_type: 'VARCHAR(255)']
	longitude        ?f32       @[comment: 'Longitude coordinates | WGS84经度'; omitempty; sql_type: 'double(11,8)']
	latitude         ?f32       @[comment: 'Latitude coordinates | WGS84纬度'; omitempty; sql_type: 'double(10,8)']
	service_boundary ?string    @[comment: 'service_boundary/Electronic Fence coordinates | 服务边界/电子围栏坐标 (仅存储，不计算)'; omitempty; sql_type: 'TEXT'] // POLOGY 类型不兼容 TiDB
	sort             u32        @[comment: 'Sort Number | 排序编号'; default: 0; omitempty; sql_type: 'int']
	status           u8         @[comment: '状态，0：正常，1：禁用'; default: 0; omitempty; sql_type: 'tinyint']
	updater_id       ?string    @[comment: '修改者ID'; omitempty; sql_type: 'CHAR(36)']
	updated_at       time.Time  @[comment: 'Update Time | 修改日期'; omitempty; sql_type: 'TIMESTAMP']
	creator_id       ?string    @[comment: '创建者ID'; immutable; omitempty; sql_type: 'CHAR(36)']
	created_at       time.Time  @[comment: 'Create Time | 创建日期'; immutable; omitempty; sql_type: 'TIMESTAMP']
	del_flag         u8         @[comment: '删除标记，0：未删除，1：已删除'; default: 0; omitempty; sql_type: 'tinyint(1)']
	deleted_at       ?time.Time @[comment: 'Delete Time | 删除日期'; omitempty; sql_type: 'TIMESTAMP']
}

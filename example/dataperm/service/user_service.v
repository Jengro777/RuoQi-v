module service

import structs { Context }

// --------------------------- 模拟 ORM 查询 ---------------------------
pub struct Query {
mut:
	sql_str string
}

// 创建新的查询对象
pub fn new_query(table string) Query {
	return Query{
		sql_str: 'SELECT * FROM ${table}'
	}
}

// 在查询上增加 WHERE 条件
pub fn (mut q Query) where(cond string) {
	if q.sql_str.contains('WHERE') {
		q.sql_str += ' AND ' + cond
	} else {
		q.sql_str += ' WHERE ' + cond
	}
}

// 执行查询（模拟返回数据）
pub fn (q Query) all() []map[string]string {
	println('[ORM] 执行SQL: ${q.sql_str}')
	return [
		{
			'id':      '1'
			'name':    'Alice'
			'dept_id': '1'
		},
		{
			'id':      '2'
			'name':    'Bob'
			'dept_id': '2'
		},
	]
}

// --------------------------- 数据权限辅助函数 ---------------------------
pub fn apply_data_scope(mut query Query, ctx Context, table string) {
	if ctx.data_perm == none {
		return
	}
	perm := ctx.data_perm or { return }

	match perm.data_scope {
		'OWN_DEPT_AND_SUB' {
			query.where('${table}.dept_id in ("${perm.sub_dept}")')
		}
		'CUSTOM_DEPT' {
			query.where('${table}.dept_id in ("${perm.custom_dept}")')
		}
		'SELF_ONLY' {
			query.where('${table}.user_id = "${perm.user_id}"')
		}
		else {} // ALL 或未知权限，不加限制
	}
}

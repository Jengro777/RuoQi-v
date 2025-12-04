module middleware

import veb
import os
import structs { Context }
import data_perm { DataPermContext }

// --------------------------- 中间件实现 ---------------------------
pub fn data_perm_middleware() veb.MiddlewareOptions[Context] {
	return veb.MiddlewareOptions[Context]{
		handler: data_perm_handler
		after:   false
	}
}

// 核心逻辑：从 Header 模拟 JWT 解码
fn data_perm_handler(mut ctx Context) bool {
	if os.getenv('ENABLE_DATA_PERM') != 'true' {
		return true
	}

	// 模拟从 HTTP Header 获取信息
	role := ctx.req.header.get(.authorization) or { 'user' }
	dept_id := ctx.req.header.get_custom('X-Dept-ID') or { '1' }
	user_id := ctx.req.header.get_custom('X-User-ID') or { '0' }

	mut perm := DataPermContext{
		role:    role
		dept_id: dept_id
		user_id: user_id
	}

	match role {
		'admin' {
			perm.data_scope = 'ALL'
		}
		'manager' {
			perm.data_scope = 'OWN_DEPT_AND_SUB'
			perm.sub_dept = 'sub_of_${dept_id}'
		}
		'custom' {
			perm.data_scope = 'CUSTOM_DEPT'
			perm.custom_dept = 'group_A'
		}
		else {
			perm.data_scope = 'SELF_ONLY'
		}
	}

	ctx.data_perm = perm
	println('[data_perm] role=${role}, dept=${dept_id}, scope=${perm.data_scope}')
	return true
}

module middle

// import structs
// import structs.schema_sys
// import adapter.redis
// import time
// import log

/* =============================================
基于Redis的权限验证中间件
=============================================
功能：通过Redis缓存验证该 token 所属用户是否有访问指定 API 的权限

参数：
- ctx       : 上下文对象（包含 dbpool、请求信息等）
- req_token : 请求携带的 JWT Token（Redis中存储）
- req_path  : 当前请求路径（API 路由）

返回：
- true  -> 用户有访问权限
- false -> 用户无访问权限
- error -> 查询或验证异常

Redis缓存策略：
- 用户token映射：token -> user_id (30分钟过期)
- 用户角色缓存：user_id -> [role_id] (30分钟过期)
- 用户API权限缓存：user_id -> [api_path] (30分钟过期)
- 角色API权限缓存：role_id -> [api_path] (1小时过期)
=============================================
*/

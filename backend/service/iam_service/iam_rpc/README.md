# IAM RPC

服务间调用端点，其他服务通过 RPC 获取身份和权限信息。

## 接口

- `GetUser(user_id, realm)` — 获取用户信息
- `CheckPermission(user_id, realm, resource, action)` — 权限校验
- `GetUserRoles(user_id, realm)` — 获取用户角色列表
- `GetDeptUsers(dept_id, realm)` — 获取部门下用户

## 调用方

- `platform_service` / `tenant_service` / `workspace_service` — 用户身份查询
- 业务服务（mall、tms、wms 等）— 权限校验
- 中间件层 authority middleware — 用户-角色-权限关联查询

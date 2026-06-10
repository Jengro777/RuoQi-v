# IAM API

HTTP 端点，前端直接调用。

## 业务边界

| 模块 | 路径前缀 | 功能 |
|------|----------|------|
| `authentication` | `/iam/auth` | 登录、注册、重置密码、MFA（无需认证） |
| `user` | `/iam/user` | 用户 CRUD（管理员视角） |
| `profile` | `/iam/profile` | 用户自我管理（修改资料、改密） |
| `role` | `/iam/role` | 角色 CRUD |
| `permission` | `/iam/permission` | 角色-权限绑定 |
| `token` | `/iam/token` | Token 刷新、吊销 |
| `department` | `/iam/department` | 部门管理 |
| `position` | `/iam/position` | 职位管理 |

## realm 区分

所有接口通过 JWT payload 中的 realm 字段区分中台/外部，不接收请求参数传入。

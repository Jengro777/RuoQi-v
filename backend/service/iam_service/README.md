# IAM 服务

身份与访问管理服务（HTTP + RPC），统一平台账号体系。

## 设计动机

中台账号与外部账号当前分散在 `sys_admin_api` 和 `core_tenant_api` 中，认证流程、用户管理、角色权限存在重复。IAM 服务收敛为单一模块，共享流程逻辑，通过 realm 区分中台/外部，数据层保持物理隔离。

## 账户模型

- **中台账号**（realm=sys）：仅用于登录中台管理面，中台内部开通，与外部账号物理隔离，操作 `sys_user` 表
- **外部账号**（realm=external）：用户在各终端注册时创建，全平台唯一，通过工作区访问租户应用，操作 `core_user` 表

两套账号共享相同的认证流程（登录、JWT 签发、Token 刷新），realm 来自 JWT payload，不可伪造。

## 安全约束

- 中台和外部使用不同的 JWT secret
- realm 来自已签名 token，repository 层不接收外部传入的 realm 参数
- 部署时中台实例监听内网端口，外部实例监听公网端口，路由注册按实例区分

## 子模块

| 目录 | 协议 | 用途 |
|------|------|------|
| `iam_api` | HTTP | 前端调用：登录、注册、用户管理、角色、Token |
| `iam_rpc` | RPC | 服务间调用：GetUser、CheckPermission、GetUserRoles |

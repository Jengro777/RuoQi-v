instance > organize/tanent/team > project> app > client
实例 > 组织/租户/团队 > 项目> 应用 > 客户端

```
实例（Instance）
 └─ 组织（Organization）
      └─ 项目（Project）        ← 仅用于归类应用
           └─ 应用（Application / App）  ← 角色/权限绑定在这里, 应用和角色多对多关系
                └─ 客户端（Client）
```

```
                    租户1 (Tenant : 组织/个人/团队)
                      |
                      |
                      |
                    项目1 (Project) ← 仅用于归类应用  → 项目(Project) 或 系统 (System) 或 平台 (Platform)
                      |
                      |
        -----------------------------------
        |                                 |   → 应用 (Application) 或 子系统 (Subsystem) 或 业务域 (Business Domain)
      订阅应用1 (Application 1)                订阅应用2 (Application 2)      ← 团队角色1 (管理员) → 绑定应用X, 应用Y
        |                                 |
        |                                 |
-------------------               -------------------
|       |        |               |        |        |
Web    App    小程序            Web     API      ...
(客户端)  (客户端) (客户端)    (客户端)(终端客户端入口)       →客户端 (Client) 或 终端 (Terminal) 或 前端 (Frontend)
```

1. 用户可以属于多个团队（多对多）
2. 一个团队有可以订阅多个应用（多对多）
3. 一个应用可以被一个团队多次订阅（根据应用设置）
4. 一个角色可以关联多个同团队的订阅应用以及权限

---

应用（Application）：租户下的逻辑容器，用来归组那些“密切相关”的 client、角色与授权等。所有client在同一个应用下，共享这个应用定义的角色（Roles）、授权（Authorizations / Grants）等

客户端（Client） 是具体运行的客户端 / API 服务，它属于某一个应用，利用应用定义的角色与授权，同时有自己的 OAuth / OIDC / SAML 配置（重定向地址、令牌类型等）。

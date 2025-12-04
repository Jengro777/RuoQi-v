## 若栖 (RuoQi)

RuoQi-V 是基于 v 语言的 veb 框架开发的后端项目

---

## 项目结构

```text
v_admin/
├── main/                           # 程序入口层（Composition Root）
│   └── main.v                      # 程序启动、依赖注入、初始化模块
│
├── routes/                         # 路由注册层（HTTP / gRPC / CLI 映射）
│   ├── user_routes.v               # 用户模块路由
│   └── auth_routes.v               # 认证模块路由
│
├── structs/                        # 数据结构定义（Infra Schema）
│   ├── db/                         # 数据库结构体（ORM 映射）
│   │   └── user_db_struct.v
│   ├── request/                    # 外部请求载体（第三方 API 输入）
│   └── response/                   # 外部响应载体（第三方 API 输出）
│
├── dto/                            # Application DTO（用例输入/输出模型）,和 service 层对应
│   ├── user/                       # 用户模块 DTO
│   │   ├── create_user_dto.v       # 创建用户请求/响应
│   │   ├── update_user_dto.v       # 更新用户请求/响应
│   │   └── user_response_dto.v     # 用户查询响应 DTO
│   ├── product/                    # 商品模块 DTO
│   │   ├── create_product_dto.v
│   │   └── product_response_dto.v
│   └── tenant/                     # 租户模块 DTO
│       ├── create_tenant_dto.v
│       └── tenant_response_dto.v
│
├── handler/                        # 接口适配层（Interface Adapter）
│   ├── http/                       # HTTP Handler / Controller, 一个文件对应一个模块
│   │   ├── user_handler.v          # 用户模块所有 HTTP 接口
│   │   ├── product_handler.v       # 商品模块所有 HTTP 接口
│   │   └── tenant_handler.v        # 租户模块所有 HTTP 接口
│   └── grpc/                       # gRPC Handler
│
├── service/                        # Application Use Cases（应用服务层）
│   ├── user/                       # 用户业务用例协调器
│   │   ├── create_user_service.v
│   │   ├── update_user_service.v
│   │   └── user_response_service.v
│   ├── product/                    # 商品业务用例协调器
│   │   ├── create_product_service.v
│   │   └── product_response_service.v
│   └── tenant/                     # 租户业务用例协调器
│       ├── create_tenant_service.v
│       └── tenant_response_service.v
│
├── domain/                         # Domain Layer（核心领域层）
│   ├── user/
│   │   ├── user.v                  # 用户实体 / 值对象
│   │   └── user_domain.v           # 用户领域服务（纯业务规则）
│   ├── product/
│   │   ├── product.v
│   │   └── product_domain.v
│   ├── tenant/
│   │   ├── tenant.v
│   │   └── tenant_domain.v
│
├── ports/                          # Port（抽象接口 / 依赖反转）
│   ├── user/
│   │   └── user_parts.v            # 用户接口模型, 定义repository需要实现的接口方法
│   ├── product/
│   │   └── product_parts.v
│   ├── tenant/
│   │   └── tenant_parts.v
│
├── adapter/                       # Adapter（Infra 引入外部系统）
│   ├── repository/                 # Ports 的具体实现（Repository / Cache / MQ 等）,实现ports里面接口定义的方法(写实际的orm_sql函数)
│   │   ├── mysql_user_repo.v       # MySQL 实现 UserRepo
│   │   ├── pg_product_repo.v       # PostgreSQL 实现 ProductRepo
│   │   └── tenant_repo.v
│   ├── db/                         # 数据库适配器
│   │   ├── mysql_pool.v            # 实现mysql连接池
│   │   ├── pg_pool.v
│   │   └── tidb_pool.v
│   ├── cache/                      # Redis 缓存适配器
│   │   └── tenant_cache.v
│   ├── http/                       # 外部 HTTP 服务适配器
│   │   └── external_api.v
│   └── mq/                         # 消息队列适配器
│       └── tenant_channel.v
│
├── common/                         # 通用基础库（非业务）
│   ├── captcha/                    # 验证码模块
│   ├── encrypt/                    # 加密工具（hash, aes, rsa）
│   ├── jwt/                        # JWT 工具
│   ├── api/                        # API Response Builder
│   └── utils/                      # 基础工具函数
│
├── config/                         # 配置层
│   ├── loader.v                    # 配置文件加载
│   └── validator.v                 # 配置校验
│
└── i18n/                           # 国际化资源
│   ├── en.v
│   └── zh.v

```

---

## TODO

- [x] HTTP1 (HTTP2 and HTTP3 future)
- [x] Logging Middleware
- [x] Autherity Middleware(JWT)
- [x] Cores Middleware
- [ ] Data permission middleware
- [x] Config Middleware
- [x] Database connections pool Middleware(Mysql,Postgres)
- [x] i18n
- [x] Multitenancy (tenant resolution) [多租户、多团队、多应用]
- [ ] Support OpenAPI, generate OpenAPI data automatic (go-swagger)
- [x] Permission: RBAC permission control

---

## 特性

- web框架：使用v标准库的 veb
- ORM：使用v标准库的 orm
- Database Connection Pool：数据库线程池，支持mysql和pgsql

---

## 缓存路线

- 缓存技术路线：[readyset](https://github.com/readysettech/readyset)
- 缓存表：使用readyset缓存热点表
- 性能：略低于redis

  Tips: 百万级用户, 并发 5000- QPS, readyset完全可以支撑. 若用户量超过百万级, 高并发5000+ QPS, 相信也已经有足够资金去扩展系统了.

---

## 租户权限

关系图:[Mermaid Live Editor](https://www.mermaidchart.com/play?utm_source=mermaid_live_editor&utm_medium=toggle#pako:eNqVkEFLwzAcxb9KyGHMQ5Gk3QalFjvEs8hu1kPWZm5Qk5J0DBm7iifBgyhevAqC3vTix3GK38JkTeo21oG55b33f_9fMoUJTyn04SDjk2RIRAF6BzEDctw_EyQfAolOYhjInCituMjoXsIzLvxwQPwBcXIqJGfgiIuCZMABnx8P85v7n7unr6v3YFdPhTE8VX3mMNRWdWVqQvvO_PZy_nj9_fwa9EVYyhFLBR-lf5YpoCxd4cL_4dJlL2_buDqqrkxpLkNUCpZoRRxx6azDqdNtxjDKc4BiuAMcJ1T_BxoKtnSZ_kxtYzW3sA-VsAkZ6UADMFzj4wqfuSrSo-S86mTIU9Ixz-hyzDOr3SrW2rLb8qKmCo0lFQu1fFJkFlaQrk3jKo2rtHUjw-ZatuU17sLs2qtnsrrci5mV2_tTIIckpz4QfMxSms6s1VmyaFIYXeKNMkO1RTUDbk2Pt1n3avtbNUXrC-DsF_G8OEo)

---

## Git 贡献提交规范

- 参考 [vue](https://github.com/vuejs/vue/blob/dev/.github/COMMIT_CONVENTION.md) 规范 ([Angular](https://github.com/conventional-changelog/conventional-changelog/tree/master/packages/conventional-changelog-angular))
  - feat 增加新功能
  - fix 修复问题/BUG
  - style 代码风格相关无影响运行结果的
  - perf 优化/性能提升
  - refactor 重构
  - revert 撤销修改
  - test 测试相关
  - docs 文档/注释
  - chore 依赖更新/脚手架配置修改等
  - workflow 工作流改进
  - ci 持续集成
  - types 类型定义文件更改
  - wip 开发中

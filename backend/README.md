Hexagonal 风格的 DDD

命名后缀

```
*_handler:
*_dto :
*_domian:
*_repo:
*_parts:
*_service:
```

```
┌─────────────────────────────────────┐
│          Handler                    │
│  - 接收请求 / 返回响应                 │
│  - 校验参数 / 鉴权                    │
│  - 调用 Application Service          │
│  - 不包含业务逻辑                      │
└───────────────┬─────────────────────┘
                │ 调用
                ▼
┌─────────────────────────────────────┐
│   Application Service               │
│  - 协调业务流程                       │
│  - 调用 Domain（核心业务逻辑）         │
│  - 处理事务 / 日志 / 异常              │
│  - 调用基础设施服务（MQ、外部 API）     │──────────┐
└───────────────┬─────────────────────┘          │
                │ 调用                            │
                ▼                                │
┌─────────────────────────────────────┐          │
│          Domain                     │          │
│  - 核心业务逻辑                       │          │
│    • 实体 / 值对象                    │         │
│    • 聚合根 / 聚合边界                 │         │
│    • 领域服务（复杂逻辑）               │         │
│  - 定义 Repository 接口               │         │
│  - 只依赖接口，不关心实现               │         │
│  - 完全专注业务规则                    │         │
└───────────────┬─────────────────────┘         │
                │ 实现依赖                        │
                ▼                               │
┌─────────────────────────────────────┐         │
│          Infra/Adapters             │◀────────┘
│  - 实现 Repository 接口              │
│  - 实际操作 DB / 缓存 / MQ            │
│  - 提供 Application/Domain 调用      │
│  - 对领域逻辑透明                     │
│  - 提供非业务相关服务（邮件、外部 API）  │
└─────────────────────────────────────┘

```

```
v_project/
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

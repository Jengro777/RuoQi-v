# DDD 编码规范

## 分层架构

```
┌──────────────────────────────────────┐
│  Interfaces (接口层)                  │  ← HTTP / gRPC / CLI 适配
│    Controller / Handler              │     请求解析、响应组装、路由映射
├──────────────────────────────────────┤
│  Application (应用层)                 │  ← 用例编排
│    Use Case / Application Service    │     事务管理、权限检查、调用 Domain + Infra
├──────────────────────────────────────┤
│  Domain (领域层)                      │  ← 纯业务逻辑，框架无关
│    Entity / Aggregate Root           │     业务规则、不变量、领域事件
│    Value Object                      │
│    Domain Service                    │
│    Repository Interface              │
├──────────────────────────────────────┤
│  Infrastructure (基础设施层)           │  ← 技术实现
│    Repository Implementation         │     ORM、DB、消息队列、外部 API
│    External Service Adapter          │
└──────────────────────────────────────┘
```

**依赖方向:** Interfaces → Application → Domain ← Infrastructure

Domain 是核心，不依赖任何外层。Infrastructure 实现 Domain 定义的接口。

---

## 一、Domain 层

### Entity / Aggregate Root

Entity 有唯一标识（ID），可变。Aggregate Root 是一组 Entity 和 Value Object 的入口，外部只能通过它访问聚合内部对象。

**命名:** 名词，PascalCase（V struct 名支持大驼峰）

```
User
Order
Product
Tenant
```

### Value Object

无唯一标识，不可变，通过值相等比较。

**命名:** 名词，PascalCase

```
EmailAddress
Money
Address
OrderId
```

### Repository Interface

定义在 Domain 层，实现在 Infrastructure 层。**模拟内存集合的语义**。

**方法命名:** 蛇形命名（V 函数名必须蛇形）

| 方法 | 含义 | 返回值 |
|------|------|--------|
| `find_by_id(id)` | 按 ID 查找 | 可选/空 |
| `find_all()` | 全部 | 列表 |
| `find_by_xxx(v)` | 按条件查找 | 列表 |
| `find_one_by_xxx(v)` | 按条件查单条 | 可选/空 |
| `exists_by_xxx(v)` | 存在性判断 | bool |
| `save(entity)` | 保存（新增或更新） | void |
| `save_all(entities)` | 批量保存 | void |
| `delete(entity)` | 删除 | void |
| `delete_by_id(id)` | 按 ID 删 | void |
| `count()` | 计数 | int |

> Repository **永远不用** `get` / `create` / `update`。
> `get` 暗示必定存在，`create`/`update` 是持久化细节，不属于领域语言。
> V 中 Repository 实现为**同模块私有函数**（`fn xxx_repo`），而非独立类。

### Domain Service

当业务操作不属于单个 Entity 或 Value Object 时使用。**无状态**。

**命名:** `{领域名词}_service`（V 惯例用蛇形命名模块/函数）

领域行为方法: `transfer`, `calculate_price`, `validate_policy`

---

## 二、Application 层

### Use Case (Command / Query)

一个 Use Case 代表一个业务意图。CQRS 建议分离 Command（写）和 Query（读）。

**Command（写操作）:**

命名: `{动词}_{宾语}_usecase`（V 函数名必须蛇形）

```
create_user_usecase
update_order_usecase
delete_product_usecase
place_order_usecase
approve_application_usecase
```

**Query（读操作）:**

命名: `{动词}_{宾语}_usecase`

```
find_user_by_id_usecase
find_active_orders_usecase
get_user_profile_usecase        ← 期望一定存在
find_products_by_category_usecase
```

**Use Case 动词:**

| 动词 | 语义 |
|------|------|
| `create` | 新建聚合 |
| `update` | 修改聚合 |
| `delete` / `remove` | 移除聚合 |
| `find` | 条件查询，结果**可能为空** |
| `get` | 查询，结果**必定存在**（否则异常） |
| `find_xxx_all` | 列表/分页查询 |

### Application Service

当多个 Use Case 共享编排逻辑时抽出。

命名: `{领域名词}_application_service`

---

## 三、Interfaces 层

### Controller / Handler

对接 HTTP / gRPC / CLI。只做协议适配。

**命名:** `{动作}_{资源}_handler`（V 函数名必须蛇形）

```
create_user_handler
find_user_by_id_handler
find_user_all_handler
update_user_handler
delete_user_handler
```

**Handler 动作词:**

| 动作 | HTTP | URL 模式 | 示例 |
|------|------|----------|------|
| `create` | POST | `/{动作}_{资源}` | `/create_user` |
| `update` | POST | `/{动作}_{资源}` | `/update_user` |
| `delete` | POST | `/{动作}_{资源}` | `/delete_user` |
| `find_by_id` | POST | `/{动作}_{资源}` | `/find_user_by_id` |
| `find_all` | POST | `/{动作}_{资源}` | `/find_user_all` |

### DTO (Data Transfer Object)

在 Interfaces 和 Application 之间传输数据，防止 Domain 对象泄漏到外层。

**命名:** `{动作}{资源}Req` / `{动作}{资源}Resp`（V struct 支持大驼峰）

```
CreateUserReq          CreateUserResp
UpdateUserReq          UpdateUserResp
FindUserByIdReq        FindUserByIdResp
FindUserAllReq         FindUserAllResp
```

> 每个字段必须标注 `@[json: 'field_name']`

### JSON 字段命名约定

V struct 字段使用 **snake_case**，`@[json]` tag 使用 **camelCase**：

```v
pub struct CreateCurrencyReq {
    english_name    string @[json: 'englishName']
    currency_code   string @[json: 'currencyCode']
    decimal_place   u8     @[json: 'decimalPlace']
}
```

- V 侧遵循语言惯例（蛇形命名）
- JSON 侧遵循前端惯例（驼峰命名）
- 两者通过 `@[json: '...']` 桥接，互不干扰

---

## 四、Infrastructure 层

### Repository Implementation

实现 Domain 层定义的仓储契约。封装数据库访问细节。

**命名:** 蛇形命名私有函数 `{动作}_{资源}_repo`

```
create_user_repo
find_user_by_id_repo
find_users_by_email_repo
update_user_repo
delete_user_repo
```

**数据库访问固定模式:**

```
db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }
// V ORM: sql db { select/insert/update from/into Xxx }
```

---

## 五、单个 *_logic.v 文件规范

### 基本原则

- 一个文件只能包含**一个 API 路由**（一个 `@['/xxx'; post]`）
- 所有函数（handler / usecase / domain / repo）放在同一个 `module` 命名空间下
- 同一目录下的文件**不互相 import**，通过 module 共享 pub 结构体

### 代码组织顺序

每个 `*_logic.v` 文件必须按以下顺序组织代码，并用 `// ═══` 注释标注分区：

```
1. ═══ Handler ═══
2. ═══ Use Case ═══
3. ═══ Domain ═══
4. ═══ DTO ═══
5. ═══ Repository ═══
```

- 如果某一层没有对应代码（如只读查询可能无 Domain 校验，或无需 DTO），则**跳过该注释**，不写空分区

### 完整示例

以"按 ID 查询用户"为例:

```
文件: find_user_by_id_logic.v
────────────────────────────────────────────────────

// ═══ Handler ═══
@['/find_user_by_id'; post]
pub fn (app &User) find_user_by_id_handler(mut ctx Context) veb.Result {
    req := json.decode[FindUserByIdReq](ctx.req.data) or {
        return ctx.json(api.json_error_400(err.msg()))
    }
    result := find_user_by_id_usecase(mut ctx, req) or {
        return ctx.json(api.json_error_500('${err}'))
    }
    return ctx.json(api.json_success_200(result))
}

// ═══ Use Case ═══
pub fn find_user_by_id_usecase(mut ctx Context, req FindUserByIdReq) !FindUserByIdResp {
    find_user_by_id_domain(req)!
    return find_user_by_id_repo(mut ctx, req)
}

// ═══ Domain ═══
fn find_user_by_id_domain(req FindUserByIdReq) ! {
    if req.id == '' {
        return error('id is required')
    }
}

// ═══ DTO ═══
pub struct FindUserByIdReq {
    id string @[json: 'id']
}

pub struct FindUserByIdResp {
    id       string @[json: 'id']
    username string @[json: 'username']
    email    string @[json: 'email']
}

// ═══ Repository ═══
fn find_user_by_id_repo(mut ctx Context, req FindUserByIdReq) !FindUserByIdResp {
    db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
    defer { ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') } }

    rows := sql db {
        select from User where id == req.id && del_flag == 0
    } or { return error('query failed: ${err}') }

    if rows.len == 0 {
        return error('user not found')
    }

    return FindUserByIdResp{
        id:       rows[0].id
        username: rows[0].username
        email:    rows[0].email
    }
}
```

### 各层函数命名总结

| 层 | 可见性 | 命名模式 | 示例 |
|------|--------|----------|------|
| Handler | `pub fn` | `{动作}_{资源}_handler` | `find_user_by_id_handler` |
| Usecase | `pub fn` | `{动作}_{资源}_usecase` | `find_user_by_id_usecase` |
| Domain | `fn` | `{动作}_{资源}_domain` | `find_user_by_id_domain` |
| Repository | `fn` | `{动作}_{资源}_repo` | `find_user_by_id_repo` |

---

## 六、命名速查表

| DDD 概念 | 标准命名 | V 命名 (蛇形) |
|----------|---------|---------------|
| Entity struct | `User` | `User` (struct 大驼峰) |
| Value Object struct | `EmailAddress` | `EmailAddress` (struct 大驼峰) |
| Repository Interface | `UserRepository.findById()` | `find_user_by_id_repo()` |
| Domain function | `validatePolicy()` | `create_user_domain()` |
| Use Case function | `CreateUserUseCase.execute()` | `create_user_usecase()` |
| Handler function | `UserController.create()` | `create_user_handler()` |
| DTO struct | `CreateUserReq` | `CreateUserReq` (struct 大驼峰) |
| Domain Service | `TransferService.transfer()` | `transfer_service.transfer()` |
| 文件名 | `CreateUserUseCase.java` | `create_user_logic.v` (蛇形) |

---

## 七、Use Case 文件命名

| 操作 | 文件名 | Handler | Usecase | Domain | Repo |
|------|--------|---------|---------|--------|------|
| 新建 | `create_user_logic.v` | `create_user_handler` | `create_user_usecase` | `create_user_domain` | `create_user_repo` |
| 更新 | `update_user_logic.v` | `update_user_handler` | `update_user_usecase` | `update_user_domain` | `update_user_repo` |
| 删除 | `delete_user_logic.v` | `delete_user_handler` | `delete_user_usecase` | `delete_user_domain` | `delete_user_repo` |
| 按ID查 | `find_user_by_id_logic.v` | `find_user_by_id_handler` | `find_user_by_id_usecase` | `find_user_by_id_domain` | `find_user_by_id_repo` |
| 列表 | `find_user_all_logic.v` | `find_user_all_handler` | `find_user_all_usecase` | `find_user_all_domain` | `find_user_all_repo` |
| Upsert | `save_user_logic.v` | `save_user_handler` | `save_user_usecase` | `save_user_domain` | `save_user_repo` |

**关键规律:**
- Handler: `{动作}_{资源}_handler`（动作在前，语义是"对资源执行某个动作"）
- Usecase/Domain/Repo: `{动作}_{资源}_{后缀}`（动作在前，语义是"对资源的某种操作"）
- 文件名: `{动作}_{资源}_logic.v`

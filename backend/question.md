分析报告：RuoQi-v 后端架构与代码问题

---

### 🟠 高 — 代码重复

**1. 重复的适配器目录**

| 目录 | 使用方 | 冗余目录 |
|---|---|---|
| `adapter/dbpool/` | 生产代码 | `adapter/mysql_pool/` — 3 个文件，仅模块名不同 |
| `adapter/cache_pool/` | 生产代码 | `adapter/redis/` — 2 个文件，仅 TLS 默认值不同 |

无任何生产代码 import 冗余目录。建议直接删除 `mysql_pool/` 和 `redis/`。

**2. 旧 JWT 模块与新 jwts 模块并存**

旧模块 `common/jwt/`、`common/opt/`、`common/captcha/` 仍被所有生产代码引用。新模块 `common/jwts/`（更优雅的泛型实现，含 `jwt_core.v`、`auth.v`、`opt.v`、`captcha.v`）仅有内部测试引用。旧模块不会自动消失，新模块不会自动启用——两条轨道并行运行。

---

### 🟡 中 — 代码质量

**3. N+1 查询**

两个用户列表接口对每行结果执行独立 SQL 查询：

| 文件 | 行号 | 每行查询 |
|---|---|---|
| `sys_admin_api/user/get_user_list_logic.v` | 148-174 | 角色 + 职位 + 部门（3 次独立查询） |
| `core_admin_api/user/get_user_list_logic.v` | 97-121 | 角色（1 次独立查询） |

应改为 JOIN 或批量 ID 查询。

**4. 配置校验拒绝 PostgreSQL**

`check/toml_check.v:80-83` 只允许 `mysql` 和 `tidb`，但 `adapter/pgsql_pool/` 已完整实现 PostgreSQL 连接池，`config_dev.toml:61` 也预留了 pgsql 配置。

**5. 缺少共用分页工具**

17 个文件中重复同一公式：`(req.page - 1) * req.page_size`，分页验证逻辑也分散在各处。应抽取通用 helper。

**6. 旧 JWT 结构体三处定义但各有差异**

`common/jwt/struct_jwt.v`（13 字段）、`common/opt/struct_jwt.v`（15 字段）、`common/captcha/struct_jwt.v`（15 字段）并不完全一致——`jwt` 版本缺少 `team_id`、`app_id` 等字段。字段修改易遗漏，应合并为统一版本。

---

### 🔵 低 — 空缺与清理

**7. 空壳模块与死代码**

| 项目 | 状态 |
|---|---|
| `adapter/mq/mq.v` | 仅 `module mq` |
| `service/fms_api/` | 仅 `app_struct.v` + README |
| `service/pay_api/` | 仅 `app_struct.v` |
| `middleware/dataperm_middleware.v` | 清空为 1 行 `module middleware`，建议直接删除文件 |
| `authority_sys_by_redis.v` | 整文件注释，死代码 |
| `sys_casbin_rule` schema | 仅 DDL 建表，代码中未使用 |

**8. 缺少基础设施**

- 无数据库版本化迁移
- 无 API 限流 / 请求体大小限制
- `cache_middleware` 已定义但被注释掉，cache_pool 仍在初始化（资源浪费）

**9. 测试覆盖不均衡**

18 个测试文件集中在 adapter（6 个）和 common（10 个）层。service 层（~200 个文件）、中间件层、路由层为零。

**10. i18n `lang_cache` 脆弱的取值模式**

`i18n/i18n.v:102` 用 `lang_cache.keys()[0]` 取单键值——依赖 map 只存一项的隐含假设，改为普通 `string` 字段更安全。

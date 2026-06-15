---
name: ruoqi-v-add-module
description: "Add a new business module to RuoQi-v following Clean Architecture. Use when asked to add a new CRUD API, business domain entity, route group, or data table. Covers schema struct, DTO, domain validation, usecase, handler, and route registration in V with veb + V ORM."
---

# RuoQi-v Add Module

Add a new business module to the RuoQi-v backend following established Clean Architecture patterns. A module exposes CRUD endpoints through veb: Schema → DTO → Domain → Usecase → Handler → Route.

## Directory layout

A new module in `sys_admin_api` named `audit_log` creates these files:

```
backend/
├── structs/schema_sys/sys_audit_log.v       # ORM schema struct
├── service/sys_admin_api/audit_log/
│   ├── app_struct.v                         # Module struct (embeds structs.App)
│   ├── create_audit_log_logic.v             # POST: handler + usecase + domain + DTO + repo
│   ├── find_audit_log_all_logic.v           # POST: list query
│   ├── find_audit_log_by_id_logic.v         # POST: single record by ID
│   ├── update_audit_log_logic.v             # POST: update
│   ├── delete_audit_log_logic.v             # POST: soft-delete
│   └── audit_log_test.v                     # Test file
└── route/route_sys_admin.v                 # Register the module route
```

## Step-by-step workflow

### Step 1: Create the Schema struct

Create `backend/structs/schema_<domain>/<name>.v`. Use [schema-template.v](references/schema-template.v).

Key rules:
- `id` is always `string` with `rand.uuid_v7()`, attributes: `immutable; primary; required; sql_type: 'CHAR(36)'; unique`
- Include all standard lifecycle fields: `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`
- Annotate every field with `@[comment: '...']`
- Table name via `@[table: 'xxx']` attribute

### Step 2: Create the module directory and app_struct.v

Create `backend/service/<api_group>/<module_name>/`. Create `app_struct.v`. The struct embeds `structs.App` — named after the module, without any suffix (e.g., `pub struct AuditLog { App }`).

### Step 3: Create CRUD logic files

Create one file per operation. Each file contains all layers inline (handler, usecase, domain, DTO, repository) within the same `module` namespace. Files in the same directory share the module and do **not** import each other.

**One file = one API route.** A file must have exactly one `@['/xxx'; post]` handler.

**Naming:** `{action}_{module_name}_logic.v`

| Action   | File name                   | HTTP | URL pattern                |
|----------|-----------------------------|------|----------------------------|
| Create   | `create_xxx_logic.v`        | POST | `/create_xxx`              |
| List     | `find_xxx_all_logic.v`      | POST | `/find_xxx_all`            |
| FindById | `find_xxx_by_id_logic.v`    | POST | `/find_xxx_by_id`          |
| Update   | `update_xxx_logic.v`        | POST | `/update_xxx`              |
| Delete   | `delete_xxx_logic.v`        | POST | `/delete_xxx`              |

**See the complete example and file structure in [ddd-conventions.md §5](references/ddd-conventions.md).**


**DB access pattern (every repository function):**
```v
db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
defer {
    ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
}
```

**API response helpers (`import common.api`):**
- `api.json_success_200(data)` / `api.json_success_201(data)`
- `api.json_error_400(msg)` / `api.json_error_401()` / `api.json_error_403()` / `api.json_error_404()` / `api.json_error_500(msg)`

### Step 4: Register the route

In the appropriate `backend/route/route_<scope>.v`, add the import and registration. See the registration table above for the correct method.

**API group → route file → registration method:**

| API group          | Route file              | Method                    | Auth required       |
|--------------------|-------------------------|---------------------------|---------------------|
| `base_api`         | `route_base.v`          | `register_routes_no_auth` | None                |
| `sys_admin_api`    | `route_sys_admin.v`     | `register_routes_sys`     | System admin JWT    |
| `core_admin_api`   | `route_core_admin.v`    | `register_routes_sys`     | System admin JWT    |
| `core_tenant_api`  | `route_core_tenant.v`   | `register_routes_core`    | Core business JWT   |
| `fms_api`          | (file API route)         | `register_routes_core`    | Core business JWT   |
| `job_api`          | (job API route)          | `register_routes_sys`     | System admin JWT    |
| `msg_api`          | (msg API route)          | `register_routes_sys`     | System admin JWT    |
| `pay_api`          | (pay API route)          | `register_routes_core`    | Core business JWT   |

Example:
```v
import service.sys_admin_api.audit_log { AuditLog }

fn (mut app AliasApp) routes_sys_admin(mut ctx Context) {
    app.register_routes_sys[AuditLog, Context](mut &AuditLog{}, '/audit_log', mut ctx)
}
```

### Step 5: Create the test file

Create `backend/service/<api_group>/<module_name>/<module_name>_test.v`. Follow the project's test conventions:

- Test file: `audit_log_test.v` in the same directory
- Test functions: `test_xxx()` — one per usecase
- Module declaration matches the logic files

```v
module audit_log

fn test_create_audit_log() {
    // test code
}
```

### Step 6: Verify integration

- The route function is called from `backend/route/route.v` or a route index file
- Schema struct is importable from `structs.schema_<domain>`
- All logic files and the test file share the same `module` name as the directory

## Naming conventions

| Layer       | Pattern                          | Example                     |
|-------------|----------------------------------|-----------------------------|
| Module dir  | `lower_snake_case`               | `audit_log`                |
| App struct  | `PascalCase` (no suffix)         | `AuditLog`                 |
| Handler fn  | `{action}_{module}_handler`      | `create_audit_log_handler` |
| Usecase fn  | `{action}_{module}_usecase`      | `create_audit_log_usecase` |
| Domain fn   | `{action}_{module}_domain`       | `create_audit_log_domain`  |
| Repo fn     | `{action}_{module}_repo`         | `create_audit_log_repo`    |
| Request DTO | `{Action}{Module}Req`            | `CreateAuditLogReq`        |
| Response DTO| `{Action}{Module}Resp`           | `CreateAuditLogResp`       |
| Schema file | `{domain}_{module}.v`            | `sys_audit_log.v`          |
| Schema struct| `{Domain}{Module}`              | `SysAuditLog`              |
| Route file  | `route_<scope>.v`                | `route_sys_admin.v`        |
| Test file   | `{module_name}_test.v`           | `audit_log_test.v`         |

## Directories to NOT modify

These directories are code-generated or infrastructure-only, per AGENTS.md. Never create or edit files in:

- `backend/adapter/repository/` — persistence implementations
- `backend/handler/` — interface adapter layer
- `backend/dto/` — data transfer objects
- `backend/parts/` — interface definitions
- `backend/usecase/` — use case implementations

## Common pitfalls

- **DTO field tags:** Every DTO field must have `@[json: 'field_name']`
- **DB connection leak:** Every `ctx.dbpool.acquire()` must have `defer { ctx.dbpool.release(conn) or {} }`
- **JSON decode errors:** Always `json.decode[...](ctx.req.data) or { return ctx.json(api.json_error_400(err.msg())) }`
- **Same-module imports:** Logic files sharing a directory do NOT import each other — only external packages
- **Schema location:** Schema structs go in `structs/schema_<domain>/`, not in the service directory
- **Soft delete:** Delete operations set `del_flag = 1`; never issue a physical `DELETE`
- **UUIDs:** Use `rand.uuid_v7()` for all primary key generation
- **One API per file:** Each `*_logic.v` must contain exactly one `@['/xxx'; post]` handler — never bundle multiple routes in one file
- **Section comments:** Every `*_logic.v` must annotate layers with `// ═══ xxx ═══` comments in the order: Handler → Usecase → Domain → DTO → Repository

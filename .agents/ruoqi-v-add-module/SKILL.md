---
name: ruoqi-v-add-module
description: "Add a business module (route, handler, service, domain) to RuoQi-v following Clean Architecture patterns. Use when adding a new API endpoint, CRUD module, business domain, route group, or data entity."
---

# RuoQi-v Add Module

Add a new business module to the RuoQi-v backend following established Clean Architecture patterns. A module exposes CRUD endpoints through veb: Schema → DTO → Domain → Usecase → Handler → Route.

## Directory layout

A new module lives under `backend/service/<api_group>/<module_name>/`. Example for `sys_admin_api` module `audit_log`:

```
backend/
├── structs/schema_sys/sys_audit_log.v    # ORM schema struct
├── service/sys_admin_api/audit_log/
│   ├── app_struct.v                       # Module struct (embeds structs.App)
│   ├── create_audit_log_logic.v           # POST handler + usecase + domain + DTO + repo
│   ├── get_audit_log_list_logic.v         # GET list with pagination
│   ├── get_audit_log_by_id_logic.v        # GET single by ID
│   ├── update_audit_log_logic.v           # PUT update
│   └── delete_audit_log_logic.v           # DELETE (soft-delete)
└── route/route_sys_admin.v               # Register the module route
```

## Step-by-step workflow

### Step 1: Create the Schema struct

Create `backend/structs/schema_<domain>/<name>.v`. Use [schema-template.v](references/schema-template.v) for the structure. The struct maps to a database table via V ORM attributes.

Key rules:
- `id` is always `string` with `rand.uuid_v7()`, marked `immutable; primary; required; sql_type: 'CHAR(36)'; unique`
- Always include standard lifecycle fields: `status`, `updater_id`, `updated_at`, `creator_id`, `created_at`, `del_flag`, `deleted_at`
- Annotate every field with `@[comment: '...']`

### Step 2: Create the module directory and app_struct.v

Create `backend/service/<api_group>/<module_name>/`. Copy [app-struct-template.v](references/app-struct-template.v) as `app_struct.v`. The struct embeds `structs.App` and is registered as a veb controller.

### Step 3: Create CRUD logic files

Create one file per operation. Each file contains all layers inline (handler, usecase, domain, DTO, repository) within the same `module` namespace — no imports between files of the same module.

**Naming:** `{action}_{module_name}_logic.v`

| Action   | File name example               | HTTP   | URL pattern               |
|----------|----------------------------------|--------|---------------------------|
| Create   | `create_audit_log_logic.v`       | POST   | `/audit_log/create`       |
| List     | `get_audit_log_list_logic.v`     | POST   | `/audit_log/list`         |
| GetById  | `get_audit_log_by_id_logic.v`    | POST   | `/audit_log/by_id`        |
| Update   | `update_audit_log_logic.v`       | POST   | `/audit_log/update`       |
| Delete   | `delete_audit_log_logic.v`       | POST   | `/audit_log/delete`       |

**Start from these templates:**
- Create: [logic-create-template.v](references/logic-create-template.v)
- List (paginated query): [logic-list-template.v](references/logic-list-template.v)

For Update and Delete, adapt the Create pattern — Update uses `update ... set ... where`, Delete sets `del_flag = 1`.

**Layered structure inside each logic file:**

```
// 1. Handler — @['/path'; post], decodes JSON, calls usecase, returns ApiSuccessResponse/ApiErrorResponse
// 2. Usecase — pub fn, orchestrates domain validation then repository
// 3. Domain — fn, validates business rules, returns ! on violation
// 4. DTO — pub struct Req/Resp with @[json: '...'] tags
// 5. Repository — fn, acquires DB conn from ctx.dbpool, runs V ORM sql, releases conn via defer
```

**DB access pattern (used in every repository function):**
```v
db, conn := ctx.dbpool.acquire() or { return error('Failed to acquire DB conn: ${err}') }
defer {
    ctx.dbpool.release(conn) or { log.warn('Failed to release conn: ${err}') }
}
// V ORM queries: sql db { select/insert/update from/into Struct }
```

**API response helpers (import `common.api`):**
- `api.json_success_200(data)` — 200 OK with payload
- `api.json_success_201(data)` — 201 Created
- `api.json_error_400(msg)` — validation error
- `api.json_error_401()` — unauthenticated
- `api.json_error_403()` — forbidden
- `api.json_error_404()` — not found
- `api.json_error_500(msg)` — server error

### Step 4: Register the route

In the appropriate `backend/route/route_<scope>.v` file, register the module. See [route-template.v](references/route-template.v).

Three registration methods:

| Method                    | Authentication    | When to use             |
|---------------------------|-------------------|-------------------------|
| `register_routes_no_auth` | None              | Public APIs, healthcheck|
| `register_routes_sys`     | System admin JWT  | System management       |
| `register_routes_core`    | Core business JWT | Tenant-scoped business  |

Example:
```v
import service.sys_admin_api.audit_log { AuditLogApp }

fn (mut app AliasApp) routes_sys_admin(mut ctx Context) {
    app.register_routes_sys[AuditLogApp, Context](mut &AuditLogApp{}, '/audit_log', mut ctx)
}
```

### Step 5: Verify integration

- The route function must be called from `backend/route/route.v` or a route index file
- The schema struct must be importable from `structs.schema_<domain>`
- All logic files share the same `module` name as the directory

## Naming conventions

| Layer       | Pattern                                 | Example                     |
|-------------|-----------------------------------------|-----------------------------|
| Module dir  | lower_snake_case                        | `audit_log`                |
| App struct  | PascalCase + App suffix                 | `AuditLogApp`              |
| Handler fn  | `{module}_{action}_handler`             | `audit_log_create_handler` |
| Usecase fn  | `{action}_{module}_usecase`             | `create_audit_log_usecase` |
| Domain fn   | `{action}_{module}_domain`              | `create_audit_log_domain`  |
| Repo fn     | `{action}_{module}_repo`                | `create_audit_log_repo`    |
| Request DTO | `{Action}{Module}Req`                   | `CreateAuditLogReq`        |
| Response DTO| `{Action}{Module}Resp`                  | `CreateAuditLogResp`       |
| Schema struct| PascalCase with domain prefix          | `SysAuditLog`              |
| Route file  | `route_<scope>.v`                       | `route_sys_admin.v`        |

## Common pitfalls

- **DTO field defaults:** Every DTO field must have `@[json: 'field_name']` to avoid silent mismatches
- **DB connection leak:** Every `ctx.dbpool.acquire()` must have `defer { ctx.dbpool.release(conn) or {} }`
- **JSON decode errors:** Always check `json.decode[...](ctx.req.data) or { return ctx.json(api.json_error_400(err.msg())) }`
- **Module imports:** Logic files in the same directory share the module namespace — do not import each other, only external packages
- **Schema location:** Schema structs go in `structs/schema_<domain>/` — not in the service directory

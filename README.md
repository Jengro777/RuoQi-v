# RuoQi (若栖)

> [English](README.md) | [中文](README.zh-CN.md)

RuoQi-V is a full-stack monorepo: the backend is developed with the Veb framework
based on the V language, and the frontend is a Flutter workspace (melos).

## Project Structure

```
backend/    # V / Veb backend
frontend/   # Flutter monorepo (melos workspace: 4 domains × app/pc + shared packages)
deploy/     # Docker / Podman deployment scripts
docs/       # Documentation
example/    # Backend examples
```

## OpenAPI Documentation

### Four Documentation Viewers

After starting the service, visit the following endpoints in your browser:

| Endpoint                              | Viewer             | Highlights                                      |
| ------------------------------------- | ------------------ | ----------------------------------------------- |
| `http://localhost:9009/rapidoc`       | RapiDoc            | Interactive debugging, dark theme, schema table view |
| `http://localhost:9009/redoc`         | Redoc              | Classic three-column layout, deeply expanded search |
| `http://localhost:9009/sleapidoc`     | Stoplight Elements | Modern UI, sidebar navigation, Try It panel     |
| `http://localhost:9009/scalar`        | Scalar             | Modern UI, built-in API testing, code examples  |
| `http://localhost:9009/openapi.json`  | OpenAPI 3.0.3 JSON | Raw specification data; shared data source for all four viewers |

### Generate the OpenAPI Specification

```bash
v run openapi/openapi_generate.vsh
```

## Quick Start

### Requirements

- **V language**: 0.5.0+
- **Database**: MySQL 8.0+ / PostgreSQL 18+
- **Cache**: Redis 7.0+ (optional)

### Run

```bash
cd backend

# Development (hot reload with a specified config)
v -d autofree -d trace_orm -d veb_livereload watch -o app run main/main.v -f etc/config_dev.toml

# Build and run
v -d autofree -prod -o app ./main
./app -f etc/config_dev.toml
```

> Default port: `9009`. After startup, visit `http://localhost:9009`.

### Frontend

```bash
cd frontend
flutter pub get
melos run run:platform_app   # or any run:* script, see frontend/README.md
```

The full frontend layout and commands are documented in
[frontend/README.md](frontend/README.md).
The Flutter version is pinned in [.tool-versions](.tool-versions) (currently
`3.44.0`) and the CI reads the same file.

### Splitting the Frontend Later

The frontend lives under `frontend/` as a git subtree (imported from
`RuoQi-flutter-ui`). If the monorepo grows too large, split it back out
while keeping its history:

```bash
git subtree split --prefix=frontend -b frontend-export
```

Then push `frontend-export` to a new repository.

## TODO

- [x] HTTP1 (HTTP2 and HTTP3 future)
- [x] Logging Middleware
- [x] Authority Middleware (JWT + AK/SK)
- [x] CORS Middleware
- [x] Data permission middleware
- [x] Config Middleware
- [x] Database Connection Pool Middleware (MySQL, PostgreSQL)
- [x] locale
- [x] Multitenancy (tenant / subproduct / subportal / workspace isolation) [Tenant → App → Portal → Workspace]
- [x] OpenAPI: automatic spec generation (openapi_generate.vsh)
- [x] RBAC Permission Control

## Features

- Web framework: `veb` from the V standard library
- ORM: `orm` from the V standard library
- Database Connection Pool: database thread pool, supporting MySQL and PostgreSQL

## Tenant Permissions

Relationship diagram: [Mermaid Live Editor](https://www.mermaidchart.com/play?utm_source=mermaid_live_editor&utm_medium=toggle#pako:eNqVkEFLwzAcxb9KyGHMQ5Gk3QalFjvEs8hu1kPWZm5Qk5J0DBm7iifBgyhevAqC3vTix3GK38JkTeo21oG55b33f_9fMoUJTyn04SDjk2RIRAF6BzEDctw_EyQfAolOYhjInCituMjoXsIzLvxwQPwBcXIqJGfgiIuCZMABnx8P85v7n7unr6v3YFdPhTE8VX3mMNRWdWVqQvvO_PZy_nj9_fwa9EVYyhFLBR-lf5YpoCxd4cL_4dJlL2_buDqqrkxpLkNUCpZoRRxx6azDqdNtxjDKc4BiuAMcJ1T_BxoKtnSZ_kxtYzW3sA-VsAkZ6UADMFzj4wqfuSrSo-S86mTIU9Ixz-hyzDOr3SrW2rLb8qKmCo0lFQu1fFJkFlaQrk3jKo2rtHUjw-ZatuU17sLs2qtnsrrci5mV2_tTIIckpz4QfMxSms6s1VmyaFIYXeKNMkO1RTUDbk2Pt1n3avtbNUXrC-DsF_G8OEo)

## Git Commit Guidelines

- Refer to the [vue](https://github.com/vuejs/vue/blob/dev/.github/COMMIT_CONVENTION.md) convention ([Angular](https://github.com/conventional-changelog/conventional-changelog/tree/master/packages/conventional-changelog-angular))
  - `feat`: add new features
  - `fix`: fix issues/bugs
  - `style`: code style changes that do not affect runtime behavior
  - `perf`: optimizations / performance improvements
  - `refactor`: refactoring
  - `revert`: revert changes
  - `test`: testing related
  - `docs`: documentation / comments
  - `chore`: dependency updates / scaffolding configuration changes, etc.
  - `workflow`: workflow improvements
  - `ci`: continuous integration
  - `types`: type definition file changes
  - `wip`: work in progress

## 若栖 (RuoQi)

RuoQi-V 是基于 v 语言的 veb 框架开发的后端项目

---

## OpenAPI 文档

### 三种文档查看器

启动服务后，浏览器访问：

| 端点                                 | 查看器             | 特点                                  |
| ------------------------------------ | ------------------ | ------------------------------------- |
| `http://localhost:9009/rapidoc`      | RapiDoc            | 交互式调试、暗色主题、Schema 表格视图 |
| `http://localhost:9009/redoc`        | Redoc              | 三栏经典布局、搜索深度展开            |
| `http://localhost:9009/sleapidoc`    | Stoplight Elements | 现代化 UI、侧边栏导航、Try It 面板    |
| `http://localhost:9009/openapi.json` | OpenAPI 3.0.3 JSON | 原始规范数据，三种查看器共用此数据源  |

### 生成 OpenAPI 规范

```bash
v run openapi/openapi_generate.vsh
```

---

## 快速开始

### 环境要求

- **V 语言**: 0.5.0+
- **数据库**: MySQL 8.0+ / PostgreSQL 18+
- **缓存**: Redis 7.0+ (可选)

### 运行

```bash
cd backend

# 开发环境（热加载-指定配置)
v -d autofree -d trace_orm -d veb_livereload watch -o app run main/main.v -f etc/config_dev.toml

# 编译后运行
v -d autofree -prod -o app ./main
./app -f etc/config_dev.toml
```

> 默认端口: `9009`，启动后访问 `http://localhost:9009`

---

## TODO

- [x] HTTP1 (HTTP2 and HTTP3 future)
- [x] Logging Middleware
- [x] Authority Middleware (JWT + AK/SK)
- [x] CORS Middleware
- [x] Data permission middleware
- [x] Config Middleware
- [x] Database Connection Pool Middleware (MySQL, PostgreSQL)
- [x] locale
- [x] Multitenancy (tenant / subproduct / subportal / workspace isolation) [租户 → 应用 → 门户 → 空间]
- [x] OpenAPI: automatic spec generation (openapi_generate.vsh)
- [x] RBAC Permission Control

---

## 特性

- web框架：使用v标准库的 veb
- ORM：使用v标准库的 orm
- Database Connection Pool：数据库线程池，支持mysql和pgsql

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

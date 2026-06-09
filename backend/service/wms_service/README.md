# 仓储管理服务

WMS 仓储管理领域的服务模块（HTTP + RPC），承载货主、租户两方门户。

## 在架构中的位置

```
workspace_portal_api → 选择工作区 → 看到租户订阅了 WMS → 跳转到货主/租户门户
```

## 业务边界

- 入库出库、库存管理、储位分配、盘点等 WMS 核心业务
- WMS 域内的租户配置（仓库设置、储位规则），与顶层 `tenant_portal_api`（订阅、计费）无关

## 子门户

| 门户 | 用户 |
|---|---|
| `wms_owner_portal_api` | 货主 |
| `wms_tenant_portal_api` | 租户在 WMS 域内的配置 |

# 运输管理服务

TMS 运输管理领域的服务模块（HTTP + RPC），承载客户、司机、企业、场站、租户五方门户。

## 在架构中的位置

```
workspace_portal_api → 选择工作区 → 看到租户订阅了 TMS → 跳转到对应角色门户
```

## 业务边界

- 运单调度、运输跟踪、场站中转、运力管理等 TMS 核心业务
- TMS 域内的租户配置（运输参数、计价规则），与顶层 `tenant_portal_api`（订阅、计费）无关

## 子门户

| 门户 | 用户 |
|---|---|
| `tms_customer_portal_api` | 客户 |
| `tms_driver_portal_api` | 司机 |
| `tms_enterprise_portal_api` | 运输企业 |
| `tms_station_portal_api` | 场站操作人员 |
| `tms_tenant_portal_api` | 租户在 TMS 域内的配置 |

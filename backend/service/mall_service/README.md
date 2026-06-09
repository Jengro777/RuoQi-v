# 商城服务

电商商城领域的服务模块（HTTP + RPC），承载买家、卖家、租户三方门户。

## 在架构中的位置

```
workspace_portal_api → 选择工作区 → 看到租户订阅了 Mall → 跳转到买家/卖家/租户门户
```

## 业务边界

- 商品、订单、交易、店铺运营等商城核心业务
- 商城域内的租户配置（店铺设置、支付/物流规则），与顶层 `tenant_portal_api`（订阅、计费）无关

## 子门户

| 门户 | 用户 |
|---|---|
| `mall_buyer_portal_api` | 买家 |
| `mall_seller_portal_api` | 卖家 |
| `mall_tenant_portal_api` | 租户在商城域内的配置 |

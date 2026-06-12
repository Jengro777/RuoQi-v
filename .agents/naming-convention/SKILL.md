---
name: naming-convention
description: "RuoQi-v 项目命名规范：SaaS 多租户的 product/subproduct、app/subapp、portal/subportal 三层订阅模型，以及 pf_/tn_ 表前缀、外键命名规则。涉及命名、表设计、字段命名时参考。"
---

# 命名标准

## 设计原则

1. **名字即文档。** 看到名字就知道它是什么，不需要查表。
2. **目录与实例分离。** "能订阅什么"和"订阅后得到什么"是不同的概念，用不同的词。
3. **`sub-` = subscription。** 统一前缀，看到就懂，没有例外。
4. **外键名 = 目标表名。** 字段 `foo_id` 指向 `foo.id`，不猜、不绕。

---

## 业务模型

SaaS 多租户的本质是 **订阅**。平台定义可订阅的目录，租户或客户订阅后得到实例。

三条订阅链，结构一致：

```
                      目录（可订阅什么）        实例（订阅后得到什么）
                      ────────────────        ──────────────────
平台 → 租户            product                 subproduct
平台 → 租户            app                     subapp
平台 → 租户客户         portal                  subportal
```

---

## 六个概念

### product — 平台有什么产品

平台的 SKU，可以卖的东西。

| 属性 | 含义 |
|------|------|
| `product.code` | `mall / wms / tms` |
| `product.name` | MALL电商平台 / WMS仓库管理 |

---

### subproduct — 租户订阅 product 后的实例

租户签了一个 product + 选了一个 plan，得到一个实例。

**实物：** "某公司签约了 MALL 企业版，这就是该公司的 MALL 实例。"

`subproduct` = sub(product) = subscription to a product。

---

### app — 产品下有哪些应用模块

一个 product 提供哪些可选的应用/模块，供租户按需开通。

| 属性 | 含义 |
|------|------|
| `app.code` | `payment / inventory / crm` |
| `app.name` | 支付模块 / 库存管理 / 客户管理 |

product 和 app 是 1:N 关系。与 portal 不同：app 是功能维度（能做什么），portal 是入口维度（从哪进）。

---

### subapp — 租户开通 app 后的实例

租户在自己的 subproduct 内选择开通了哪些应用模块。

**实物：** "某公司的 MALL 实例开通了支付模块和库存模块。"

`subapp` = sub(app) = subscription to an app。与 subproduct 结构对称。

---

### portal — 产品下有哪些门户/入口

一个 product 提供哪些端，供租户的客户进入。

| 属性 | 含义 |
|------|------|
| `portal.code` | `seller / buyer / owner / admin` |

product 和 portal 是 1:N 关系：MALL 下有 seller、buyer 两个门户。

---

### subportal — 客户入住 portal 后的实例

租户的客户注册/入驻了一个 portal，得到一个实例。

**实物：** "某 seller 商家入驻了某公司的 MALL 店铺"、"某 buyer 用户注册了某公司的商城"。

`subportal` = sub(portal) = subscription to a portal。与 subproduct、subapp 结构对称。

---

## 三条链的关系

```
product（目录）
 ├─ plan（定价，product 的附属属性，不是独立订阅目标）
 ├─ app（目录：功能模块）
 └─ portal（目录：入口/端）
      │
      │ 租户订阅
      ▼
 subproduct（实例，租户有）
      │
      ├── 租户开通
      │   ▼
      │   subapp（实例，租户有）
      │
      └── 租户客户入住
          ▼
          subportal（实例，客户有）
```

| | subproduct | subapp | subportal |
|---|------------|--------|-----------|
| 订阅者 | **租户**（公司） | **租户**（公司） | **租户的客户**（个人/商家） |
| 从哪订阅 | 平台的 product | subproduct 下的 app | subproduct 下的 portal |
| 一句话 | 租户有平台了 | 租户开通模块了 | 客户进店了 |
| 值类型 | UUID | UUID | UUID |

---

## 为什么 `sub-` 前缀是好的

`sub-` 全部读作 **subscription**，六个字含义一致：

| 词 | = subscription to a ... | 中文 |
|----|------------------------|------|
| sub**product** | subscription to a **product** | 订阅了一个产品 |
| sub**app** | subscription to an **app** | 开通了一个应用 |
| sub**portal** | subscription to a **portal** | 入住了一个门户 |

对称、一致、看到就懂。每条链的目录侧和实例侧共享同一个词根，只靠 `sub-` 区分。

---

## 表命名

```
┌─ platform 层（平台定义有什么）
│     pf_product    有什么产品
│     pf_plan       有什么套餐（产品定价）
│     pf_app        有什么应用模块
│     pf_portal     有什么门户
│
└─ tenant 层（租户有什么 + 租户客户有什么）
      tn_subproduct  租户订阅产品 → 实例
      tn_subapp      租户开通应用 → 实例
      tn_subportal   客户入住门户 → 实例
```

**前缀：**
- `pf_` = platform，平台层。平台定义的可订阅目录。
- `tn_` = tenant，租户层。所有订阅产生的实例，不论订阅者是租户自己还是租户的客户。客户的实例挂在租户的 subproduct 之下，归租户层管。

**表名规则：** 目录表直接用概念名（`pf_product`），实例表用 `sub-` 前缀（`tn_subproduct`）。概念名和表名一一对应，没有映射负担。

| 概念 | 表 |
|------|-----|
| product | `pf_product` |
| plan | `pf_plan` |
| app | `pf_app` |
| portal | `pf_portal` |
| subproduct | `tn_subproduct` |
| subapp | `tn_subapp` |
| subportal | `tn_subportal` |

---

## 关键字段命名

外键名直接指向被引用的表，看到字段名就知道去哪张表查。

| 字段 | 指向 | 说明 |
|------|------|------|
| `product_id` | `pf_product.id` | 产品编码（mall/wms/tms） |
| `plan_id` | `pf_plan.id` | 套餐 ID |
| `app_id` | `pf_app.id` | 应用模块 ID |
| `portal_id` | `pf_portal.id` | 门户 ID（seller/buyer） |
| `subproduct_id` | `tn_subproduct.id` | 租户产品实例 ID |
| `subapp_id` | `tn_subapp.id` | 租户应用实例 ID |
| `subportal_id` | `tn_subportal.id` | 客户门户实例 ID |

> **注意：** 实例侧的外键字段名也带 `sub-` 前缀——`subproduct_id` 而不叫 `tn_product_id`。字段名指向的是表名（`tn_subproduct`），不是前缀缩写。

---

## 举个例子（MALL）

```
pf_product:    code=mall, name=MALL电商平台
pf_plan:       product_id=mall, code=enterprise, 企业版
pf_app:        product_id=mall, code=payment, 支付模块
pf_app:        product_id=mall, code=crm, 客户管理模块
pf_portal:     product_id=mall, code=seller, 商家端
pf_portal:     product_id=mall, code=buyer,  买家端

→ 某电商公司签约 MALL 企业版
   tn_subproduct: product_id=mall, plan_id=enterprise, company=某电商

→ 该公司在实例下开通支付和 CRM 模块
   tn_subapp: subproduct_id=..., app_id=payment
   tn_subapp: subproduct_id=..., app_id=crm

→ seller 商家入驻该公司的 MALL
   tn_subportal: subproduct_id=..., portal_id=seller, shop_name=某某店

→ buyer 注册购物
   tn_subportal: subproduct_id=..., portal_id=buyer, user_name=张三
```

一条数据线从头到尾：

```
产品 ─→ 套餐 ─→ 租户实例 ─┬→ 开通应用
                          └→ 门户 ─→ 客户入住
```

每层的名字直接说清它是什么。

---

## 常见问题

### `tn_` 为什么不区分租户和客户？

客户的 subportal 挂在租户的 subproduct 之下——客户不能脱离租户独立存在。用同一个 `tn_` 前缀表达这种归属关系，比引入 `ws_` 或 `cs_` 更简单。如果未来客户数据膨胀到需要独立分层，再引入新前缀。

### `subapp` 跟 `subproduct` 的区别？

`subproduct` 是订阅产品——签合同、选套餐、付费。`subapp` 是开通模块——在已有的实例里按需启用功能。前者是商业行为，后者是配置行为，但都遵循"从目录选 → 得到实例"的订阅模式，所以都用 `sub-`。

### `plan` 为什么没有 subplan？

plan 不是独立的订阅目标——它是 product 的附属属性。租户订阅 product 时选定 plan，plan 信息挂在 subproduct 上（`plan_id`），不产生独立实例。不存在"订阅一个 plan"这种业务动作。

### 为什么不用 `pf_product_portal`？

portal 对 product 的归属关系已通过 `product_id` 外键表达。把关系写进表名会导致：
- 名字膨胀（`pf_product_portal` → 如果再嵌套呢？）
- 外键字段膨胀（`product_portal_id`）
- 冗余——表名描述"它是什么"就够，"它属于谁"交给外键。

# RuoQi Flutter UI

RuoQi 多项目 Flutter 巨仓（monorepo），基于 Dart 原生 pub workspace 与 [melos](https://melos.invertase.dev) 管理。
每个业务域都有 App（移动端）与 PC（Web）两个 UI 项目，共享同一份域 API 包。

## 目录结构

```
apps/
  app/                       # 移动端
    platform/                # 平台 App（ruoqi_platform_app）
    customer/                # 客户 App（ruoqi_customer_app）
    merchant/                # 商户 App（ruoqi_merchant_app）
    partner/                 # 伙伴 App（ruoqi_partner_app）
  pc/                        # PC 端（Web）
    platform/                # 平台（ruoqi_platform_pc）
    customer/                # 客户（ruoqi_customer_pc）
    merchant/                # 商户（ruoqi_merchant_pc）
    partner/                 # 伙伴（ruoqi_partner_pc）
packages/
  ruoqi_common/              # 品牌主题、通用组件、端类型
  ruoqi_network/             # 网络基础设施（不绑定后端）
  ruoqi_platform_api/        # 平台域 DTO + 客户端（两端共用）
  ruoqi_customer_api/        # 客户域 DTO + 客户端（两端共用）
  ruoqi_merchant_api/        # 商户域 DTO + 客户端（两端共用）
  ruoqi_partner_api/         # 伙伴域 DTO + 客户端（两端共用）
```

> 说明：`platform` 与 pub.dev 上的 `platform` 包同名，会与 workspace 解析冲突，
> 因此 Dart 包名统一使用 `ruoqi_` 前缀，App 包名再带 `_app` / `_pc` 后缀区分两端。

## 环境准备

Flutter 版本钉在仓库根的 `.tool-versions`（当前 `3.44.0`，对应 Dart 3.12.0），
CI 读同一个文件，本地请保持一致。

> 为什么必须钉版本：`meta` / `matcher` / `test_api` / `vector_math` 这几个传递依赖
> 由 Flutter SDK 精确钉住，SDK 版本一变，`frontend/pubspec.lock` 就会被 pub 改写；
> 而依赖集在运行中变化会让 dev server 拒绝热重载（`Hot reload rejected due to
> unsupported changes`）。

用 mise / asdf 管理：

```bash
mise install        # asdf 用户：asdf install
flutter --version   # 应输出 3.44.0
```

手动安装：把 3.44.0 放在 `$HOME/opt/flutter`，再把它和 melos 加进 PATH：

```bash
export PATH="$PATH":"$HOME/opt/flutter/bin":"$HOME/.pub-cache/bin"
flutter --version # 应输出 3.44.0
melos --version   # 首次使用前：dart pub global activate melos 6.3.3
```

升级 Flutter 时：改 `.tool-versions` 的版本号 → `cd frontend && flutter pub get`
→ 提交更新后的 `frontend/pubspec.lock`，CI 会自动切到新版本。

## 常用命令

```bash
# 安装依赖（在仓库根目录执行一次，解析整个 workspace）
flutter pub get

# 分析 / 测试全部包
melos analyze
melos test

# 重新生成 JSON 序列化代码（改过 packages/ruoqi_*_api 的 models 后执行）
melos gen

# 运行某个端（App 或 PC）
melos run run:platform_app
melos run run:platform_pc
melos run run:customer_app
melos run run:customer_pc
melos run run:merchant_app
melos run run:merchant_pc
melos run run:partner_app
melos run run:partner_pc
```

## 分层约定

- `packages/ruoqi_network`：只提供「怎么发请求」的能力——超时、token 注入、统一错误；
  不含任何后端地址或接口。
- `packages/ruoqi_<域>_api`：每个业务域一份，包含该域后端的 DTO 与 API 客户端，
  App 端与 PC 端共用；`json_serializable` 生成 `*.g.dart`，改动后执行 `melos gen`。
- `apps/`：只放 UI。移动端（`apps/app/*`）与 PC 端（`apps/pc/*`）各自维护页面与交互，
  共享逻辑一律从域包引用。

后端地址通过 `--dart-define` 注入，例如：

```bash
flutter run --dart-define=CUSTOMER_API_BASE_URL=https://customer.example.com
```

## 端类型

| 域 | App（移动端） | PC（Web） |
|---|---|---|
| platform | apps/app/platform | apps/pc/platform |
| customer | apps/app/customer | apps/pc/customer |
| merchant | apps/app/merchant | apps/pc/merchant |
| partner | apps/app/partner | apps/pc/partner |

每个 App 在 `main.dart` 用 `RuoQiPlatformScope` 声明端类型（`RuoQiPlatform.mobile` / `pc`），
布局代码通过 `RuoQiPlatformScope.of(context)` 或 `RuoQiBreakpoints` 断点自适应。
断点常量为 `tablet: 600`、`desktop: 1024`。

## 新增域

1. 新建域 API 包 `packages/ruoqi_<域>_api`（参考现有域包）；
2. 分别创建移动端与 PC 端工程：

```bash
flutter create --org com.ruoqi --platforms android,ios,web apps/app/<name>
flutter create --org com.ruoqi --platforms web apps/pc/<name>
```

3. 两个工程的 `pubspec.yaml` 改为 `ruoqi_<name>_app` / `ruoqi_<name>_pc`，
   添加 `resolution: workspace`，接入 `ruoqi_common` 与域 API 包；
4. 根 `pubspec.yaml` 的 `workspace:` 加入新目录，`melos.yaml` 按需添加运行脚本。

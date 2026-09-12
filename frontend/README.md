# RuoQi Flutter UI

RuoQi 多项目 Flutter 巨仓（monorepo），基于 Dart 原生 pub workspace 与 [melos](https://melos.invertase.dev) 管理。
每个业务域都有 App（移动端）与 PC（Web）两个 UI 项目，各自在 `lib/api/` 下持有本端的域 API 层。

## 目录结构

```
apps/
  platform_pc/               # 平台端 PC（ruoqi_platform_pc）：系统管理 / 运营后台
  platform_app/              # 平台端 App（ruoqi_platform_app）
  business_pc/               # 业务端 PC（ruoqi_business_pc）：客户 / 商户 / 伙伴
  business_app/              # 业务端 App（ruoqi_business_app）：客户 / 商户 / 伙伴
packages/
  common/                    # 品牌主题、通用组件、端类型、营销组件
  network/                   # 网络基础设施（不绑定后端）
```

域 API 随应用壳走，不再是独立包。以业务端为例：

```
apps/business_pc/
  lib/api/customer/           # 客户域 DTO + 客户端（本端一份）
  lib/api/merchant/           # 商户域 DTO + 客户端
  lib/api/partner/            # 伙伴域 DTO + 客户端
  lib/customer|merchant|partner/   # 对应域的 UI 页面
```

> 说明：App 包名用 `ruoqi_` 前缀 + `_app` / `_pc` 后缀——`platform` 之类的名字与
> pub.dev 上的同名包（Flutter SDK 的传递依赖）冲突，会让 workspace 解析失败；
> 共享包则直接叫 `common` / `network`，import 时一眼能看出用途。

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

# 重新生成 JSON 序列化代码（改过 apps/*/lib/api 下的 models 后执行）
melos gen

# 运行某个端（App 或 PC）
melos run run:platform_app
melos run run:platform_pc
melos run run:business_app
melos run run:business_pc
```

## 分层约定

- `packages/network`：只提供「怎么发请求」的能力——超时、token 注入、统一错误；
  不含任何后端地址或接口。
- `packages/common`：品牌主题、通用组件、`RuoQiPlatform` 端类型与营销组件，
  四个端共用同一份，改一次四端生效。
- `apps/<壳>/lib/api/<域>/`：该应用壳自己的域 API 层（DTO + `<域>_api.dart` 客户端），
  `json_serializable` 生成 `*.g.dart`，改动后执行 `melos gen`；各端接口本来就不同，
  因此按端各持一份，互不牵连。
- `apps/<壳>/lib/<域>/`：该域的 UI 页面，按「应用壳 + 端类型」划分——`platform_*` 是平台端
  （系统管理 / 运营后台），`business_*` 是业务端（客户 / 商户 / 伙伴，
  三个业务域的页面放在同一个壳里，由工作台入口在弹窗内打开）。

后端地址通过 `--dart-define` 注入，例如：

```bash
flutter run --dart-define=CUSTOMER_API_BASE_URL=https://customer.example.com
```

## 端类型

| 域 | App（移动端） | PC（Web） |
|---|---|---|
| platform（系统管理 / 运营后台） | apps/platform_app | apps/platform_pc |
| business（客户 / 商户 / 伙伴） | apps/business_app | apps/business_pc |

每个 App 在 `main.dart` 用 `RuoQiPlatformScope` 声明端类型（`RuoQiPlatform.mobile` / `pc`），
布局代码通过 `RuoQiPlatformScope.of(context)` 或 `RuoQiBreakpoints` 断点自适应。
断点常量为 `tablet: 600`、`desktop: 1024`。

## 新增域

1. 在对应的应用壳里新增域 API 目录 `lib/api/<域>/`（DTO + 客户端，参考现有域）；
2. 在同一个壳里新增 `lib/<域>/` 页面目录与工作台入口卡片：

```bash
# PC 端 / App 端分别对应
apps/business_pc/lib/api/<域>/   +   apps/business_pc/lib/<域>/
apps/business_app/lib/api/<域>/  +   apps/business_app/lib/<域>/
```

3. 若该域需要独立的 App 壳（不走业务端），再按现有壳复制目录：

```bash
flutter create --org com.ruoqi --platforms android,ios,web apps/<name>_app
flutter create --org com.ruoqi --platforms web apps/<name>_pc
```

4. 两个工程的 `pubspec.yaml` 改为 `ruoqi_<name>_app` / `ruoqi_<name>_pc`，
   添加 `resolution: workspace`，接入共享包 `common` 与 `network`；
5. 根 `pubspec.yaml` 的 `workspace:` 加入新目录，`melos.yaml` 按需添加运行脚本。

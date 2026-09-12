# personal_pages（个人中心）

平台端账号自己的页面，从 运营后台（`ops_pages`）的「个人中心」板块独立出来，
入口是首页顶栏账号菜单的「个人资料」。

| 目录 | 内容 |
| --- | --- |
| `profile_page/` | 个人资料（头像、姓名 / 邮箱 / 手机号） |
| `account_security_page/` | 账号安全（登录密码、手机号、邮箱、多因素认证、账号日志） |
| `mfa_page/` | 多因素认证（短信 / 邮箱 / TOTP / 备用码） |
| `localization_page/` | 本地化（界面语言、时区、货币、日期与数字格式） |
| `theme_page/` | 主题（背景：跟随系统 / 亮色 / 暗色，强调色色板），版式参考 hopscotch |

- `personal_console_dialog.dart`：个人中心入口弹窗（根目录），外壳与
  管理后台 / 运营后台 一致：`ConsoleTopBar` + 左侧菜单 + 右侧内容区。
- `personal_sidebar.dart`：左侧菜单（四个固定页面，无搜索框与树形层级）。
- `personal_nav.dart`：页面清单（菜单文案 + 正文 Builder + 外观设置上下文）。
- 页面内的跳转（个人资料 → 账号安全 / 多因素认证 / 本地化）通过
  `onOpenPage` 回调切换左侧菜单选中项；整页路由单独打开时退化为 push。
- 主题页的取值来自应用外壳（`PlatformApp` 的 `themeMode` / `accent`），
  改完立即生效：背景走 `MaterialApp.themeMode`，强调色走 `ruoQiTheme(accent:)`。
- 色板与默认值在 `lib/appearance.dart`：默认强调色为**青色**，末档玫红即
  规范品牌色（选它等同于恢复设计规范默认取色）。

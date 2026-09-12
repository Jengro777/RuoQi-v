---
version: beta
name: ruoqi-design-system-flutter
description: >
  RuoQi 设计系统的 Flutter 规范。所有令牌、组件与行为均以 Flutter 约定表达：
  ThemeData / ColorScheme / TextTheme / ThemeExtension / Widget / MediaQuery。
  本文件可独立实现，不需要对照任何 CSS 文档。
mode: "Brightness.light | Brightness.dark × RuQiPurpose.standard | marketing"
related: 由原 CSS 版设计共识转换而来；本文件为 Flutter 端唯一设计规范。
---

# RuoQi 设计系统 — Flutter 规范

## 概述

本系统为每个颜色、表面、文本角色定义 **亮色 / 暗色两套取值**。组件不直接引用
十六进制色值，而是引用语义角色（`ColorScheme.primary`、`ThemeData.scaffoldBackgroundColor`、
`RuQiThemeExtension.canvas` 等），由 `ThemeData` 在运行时解析。

品牌锚点：

- 主色：Douyin 热粉 `Color(0xFFFE2C55)`（规范默认；个性化强调色见 §1.5）；
- 字体族：Inter（含 CJK 回退链）；
- 默认按钮：`BorderRadius.circular(8)`；
- 间距基准：4px；
- 深度体系：表面阶梯 + 可选阴影（亮色阴影 / 暗色描边）。

**营销扩展**：新增转化组件（倒计时、社交证明、吸附 CTA、对比表、优惠码输入、
浮动弹层）。营销上下文通过 `RuQiPurpose.marketing` 标记，主色填充面积 ≤ 5%
页面，避免「廉价促销」观感。

---

## 1. 颜色

### 1.1 `ColorScheme` 角色

| `ColorScheme` 角色        | 用途                         | 亮色                | 暗色                |
| ------------------------- | ---------------------------- | ------------------- | ------------------- |
| `primary`                 | CTA 填充、焦点、链接         | `Color(0xFFFE2C55)` | `Color(0xFFFE2C55)` |
| `onPrimary`               | 主色填充表面上的文本         | `Color(0xFFFFFFFF)` | `Color(0xFFFFFFFF)` |
| `primaryContainer`        | 柔和标签 / 徽章背景          | `Color(0xFFFFF0F3)` | `Color(0xFF2D0D14)` |
| `secondary`               | 高能强调（价格、倒计时数字） | `Color(0xFFFE2C55)` | `Color(0xFFFE2C55)` |
| `surface`                 | 页面 / 顶栏 / 菜单背景       | `Color(0xFFFFFFFF)` | `Color(0xFF0B0C0F)` |
| `surfaceContainerLowest`  | 页面背景最低层               | `Color(0xFFFFFFFF)` | `Color(0xFF0B0C0F)` |
| `surfaceContainerLow`     | 柔和交替背景带               | `Color(0xFFFAFAFA)` | `Color(0xFF101215)` |
| `surfaceContainer`        | 默认卡片 / 面板              | `Color(0xFFF5F5F5)` | `Color(0xFF141518)` |
| `surfaceContainerHigh`    | 精选卡片、悬停表面           | `Color(0xFFEDEDED)` | `Color(0xFF1C1E23)` |
| `surfaceContainerHighest` | 更深抬升表面（如组内徽章）     | `Color(0xFFEDEDED)` | `Color(0xFF1C1E23)` |
| `onSurface`               | 主文本与标题                 | `Color(0xFF0F172A)` | `Color(0xFFF0F2F5)` |
| `onSurfaceVariant`        | 次级正文、描述               | `Color(0xFF64748B)` | `Color(0xFFCDD1D8)` |
| `outlineVariant`          | 卡片 / 表格 / 面板 / 分隔线描边 | `Color(0xFFEAEAEA)` | `Color(0xFF26282F)` |
| `outline`                 | 更强描边                     | `Color(0xFFDBDBDB)` | `Color(0xFF353840)` |
| `error`                   | 错误文本、破坏性操作         | `Color(0xFFCF222E)` | `Color(0xFFF85149)` |
| `scrim`                   | 模态遮罩                     | `Color(0x80000000)` | `Color(0xA6000000)` |

### 1.2 `RuQiThemeExtension` 自定义角色

Material 角色覆盖不到的颜色统一放进 `ThemeExtension<RuQiThemeExtension>`，
通过 `Theme.of(context).extension<RuQiThemeExtension>()` 读取：

| 字段             | 用途                                 | 亮色                | 暗色                |
| ---------------- | ------------------------------------ | ------------------- | ------------------- |
| `primaryHover`   | 悬停 CTA                             | `Color(0xFFFF4D6A)` | `Color(0xFFFF4D6A)` |
| `primaryPress`   | 按下 CTA                             | `Color(0xFFE01A44)` | `Color(0xFFE01A44)` |
| `primarySubdued` | 柔和标签背景（营销亮色用 `#EFF6FF`） | `Color(0xFFFFF0F3)` | `Color(0xFF2D0D14)` |
| `accentEnergy`   | 高能强调（营销模式保持热粉）         | `Color(0xFFFE2C55)` | `Color(0xFFFE2C55)` |
| `surface3`       | 子导航、下拉层                       | `Color(0xFFE4E4E4)` | `Color(0xFF23252B)` |
| `surface4`       | 最深抬升表面                         | `Color(0xFFDCDCDC)` | `Color(0xFF2A2D34)` |
| `hairlineStrong` | 更强描边                             | `Color(0xFFDBDBDB)` | `Color(0xFF353840)` |
| `hairlineInput`  | 表单输入描边（同 `outline`）         | `Color(0xFFDBDBDB)` | `Color(0xFF3E414A)` |
| `canvasSoft`     | 柔和交替背景带                       | `Color(0xFFF7F7F7)` | `Color(0xFF101215)` |
| `canvasCream`    | 暖色插曲带                           | `Color(0xFFFAF7F0)` | `Color(0xFF1C1A12)` |
| `brandDark`      | 反色面板背景                         | `Color(0xFF111B3D)` | `Color(0xFF0F1030)` |
| `inkMuted`       | 辅助文本、说明、页脚                 | `Color(0xFF94A3B8)` | `Color(0xFF8B9098)` |
| `inkTertiary`    | 禁用态、脚注                         | `Color(0xFFCBD5E1)` | `Color(0xFF63676E)` |
| `onDark`         | 反色表面上的文本                     | `Color(0xFFFFFFFF)` | `Color(0xFFFFFFFF)` |
| `success`        | 成功状态                             | `Color(0xFF1A7F37)` | `Color(0xFF3FB950)` |
| `warning`        | 警告状态                             | `Color(0xFF9A6700)` | `Color(0xFFD29922)` |
| `info`           | 信息状态                             | `Color(0xFF0969DA)` | `Color(0xFF58A6FF)` |

营销模式覆盖（`RuQiPurpose.marketing`）：

| 场景 | 覆盖字段                                                       | 值                                            |
| ---- | -------------------------------------------------------------- | --------------------------------------------- |
| 亮色 | `primary` / `primaryHover` / `primaryPress` / `primarySubdued` | `#2563EB` / `#1D4ED8` / `#1E40AF` / `#EFF6FF` |
| 暗色 | `primarySubdued` / `hairlineInput`                             | `#3D1520` / `#4A4E59`（提升对比）             |

### 1.3 营销色约束

- 营销页面主色填充面积 ≤ 5%；
- 主色仅用于：主 CTA、价格高亮、倒计时数字、链接下划线；
- 禁止：大面积背景、多个并排主按钮、全宽横幅。

### 1.4 色块约束（standard 模式）

- 尽量避免大面积色块：整块背景、整屏横幅、整列卡片底色都不承载强色；
- 需要底色时用最浅的中性表面（`surfaceContainerLowest`，亮色 `#FFFFFF`，
  暗色 `surfaceContainerLow`），层级交给 1px 描边 + 浅阴影（§4.1 深度 1）；
- 主色 / `primaryContainer` 只用于小面积元素：图标底色、标签、按钮、1px 描边；
- 交互高亮（hover / focus）统一走中性：两者都取 `surfaceContainerLow`
  （亮色 `#FAFAFA`），按下 `highlightColor` 取 `surfaceContainerHigh`；
  悬停反馈靠底色变化 + 位移 / 阴影，不用主色描边或主色容器；
- 卡片等大面积区域不铺灰底：亮色页面 / 顶栏 / 菜单 / 卡片统一 `#FFFFFF`，
  用 1px `outlineVariant`（`#EAEAEA`）描边 / 分隔线划分层级；
- 表格表头例外：用最轻一档表面 `surfaceContainer`（亮色 `#F5F5F5`）作细带 +
  下分隔线，保证「有表头」；不使用 `#EDEDED` 及以上灰阶铺整块；
- 实现注意：`BoxShadow` 必须与填充色写在同一层 `BoxDecoration` 里——若把填充放在
  外层 `Material`、`BoxShadow` 放在内层装饰上，阴影会盖在填充之上，把整块压暗
  约 9%（亮色 `#FFFFFF` 实测被压成 `#E8E8E8`）；
- 营销模式的 `brandDark` 面板规则见 §1.3，不适用于 standard 页面。

### 1.5 强调色（个人中心 → 主题）

个性强调色由用户在「个人中心 → 主题」选择，应用外壳把它交给
`ruoQiTheme(accent:)`；`RuQiColors.forMode` 只接管主色一族，中性表面、文本与
状态色不带入色相。色板九档（末档为规范品牌色）：

| 档位 | 值                  | 说明                         |
| ---- | ------------------- | ---------------------------- |
| 绿色 | `Color(0xFF16A34A)` |                              |
| 青色 | `Color(0xFF0D9488)` | **默认档**：平台端初始强调色 |
| 蓝色 | `Color(0xFF2563EB)` |                              |
| 靛蓝 | `Color(0xFF4F46E5)` |                              |
| 紫色 | `Color(0xFF9333EA)` |                              |
| 琥珀 | `Color(0xFFD97706)` |                              |
| 橙色 | `Color(0xFFEA580C)` |                              |
| 红色 | `Color(0xFFDC2626)` |                              |
| 玫红 | `Color(0xFFFE2C55)` |                              |

派生规则（`accent` 非空且不等于品牌色时生效）：

| 角色                 | 亮色              | 暗色                           |
| -------------------- | ----------------- | ------------------------------ |
| `primary`            | `accent`          | `accent`                       |
| `primaryHover`       | `accent` → 白 11% | 同左                           |
| `primaryPress`       | `accent` → 黑 12% | 同左                           |
| `primaryContainer`   | `accent` → 白 94% | `accent` 15% 压在 `#0B0C0F` 上 |
| `onPrimaryContainer` | `accent` → 黑 45% | `accent` → 白 65%              |
| `inversePrimary`     | `primary`         | `primary`                      |

约定：

- `accent` 为空或等于 `Color(0xFFFE2C55)` 时，§1.1 取值逐位保持规范值——
  「默认」与「选回玫红」必须完全一致；
- `secondary` / `accentEnergy` 不随强调色变化（营销语义固定为品牌热粉）；
- 强调色的填充面积约束同 §1.4：只用于 CTA、选中态、图标与 1px 描边。

---

## 2. 字体

### 2.1 字体族与回退

- 工作字体：Inter。实现时打包字体资源（`pubspec.yaml` 的 `fonts:` 或
  `google_fonts` 包），通过 `ThemeData(fontFamily: 'Inter')` 全局应用；
- CJK 回退链：`['PingFang SC', 'Microsoft YaHei', 'Noto Sans CJK SC', 'sans-serif']`
  → `ThemeData(fontFamilyFallback:)`；
- 等宽：`['JetBrains Mono', 'SF Mono', 'Menlo', 'monospace']`；
- OpenType 特性：正文 `FontFeature.stylisticSet(1)`；数值上下文
  `FontFeature.tabularFigures()`。

### 2.2 `TextTheme` 层级

| `TextTheme` 角色 | 字号 / 字重 / 行高 / 字距 | 用途                     |
| ---------------- | ------------------------- | ------------------------ |
| `displayLarge`   | 64 / 600 / 1.05 / -2.0    | Hero 主标题              |
| `displayMedium`  | 48 / 600 / 1.08 / -1.4    | 区块开场                 |
| `displaySmall`   | 36 / 600 / 1.12 / -0.8    | 子区块标题               |
| `headlineLarge`  | 28 / 600 / 1.18 / -0.4    | 卡片组标题               |
| `headlineMedium` | 22 / 600 / 1.25 / -0.2    | 定价档位标题、功能卡标题 |
| `headlineSmall`  | 18 / 400 / 1.40 / 0       | 导语、intro 正文         |
| `bodyLarge`      | 16 / 400 / 1.50 / 0       | 主正文                   |
| `bodyMedium`     | 15 / 400 / 1.50 / 0       | 默认 UI 正文             |
| `titleSmall`     | 14 / 400 / 1.45 / 0       | 卡片正文、页脚、说明     |
| `bodySmall`      | 12 / 400 / 1.40 / 0       | 元信息、时间戳、状态     |
| `labelLarge`     | 14 / 500 / 1.20 / 0       | 按钮标签                 |
| `labelMedium`    | 12 / 500 / 1.20 / 0       | 紧凑按钮标签             |
| `labelSmall`     | 13 / 500 / 1.30 / +0.3    | 区块眉题                 |

> 说明：`titleLarge` / `titleMedium` 分别复用 `headlineSmall` / `bodyLarge`
> 的规格，供 `AppBar`、列表标题等 Material 组件使用。

### 2.3 自定义 `TextStyle`（`RuQiTextStyles`）

以下样式不进入 `TextTheme`，由组件按需引用：

| 常量             | 规格                                     | 用途               |
| ---------------- | ---------------------------------------- | ------------------ |
| `mono`           | 13 / 400 / 1.5                           | 代码、ID、数据令牌 |
| `tabular`        | 14 / 400 / 1.4 / -0.3 + `tabularFigures` | 金额、数值单元格   |
| `countdownDigit` | 36 / 700 / 1.0 / -0.5 + `tabularFigures` | 倒计时数字         |

### 2.4 CJK 字距重置

展示层负字距不应用于中文。统一使用助手函数：

```dart
TextStyle zh(TextStyle style) => style.copyWith(letterSpacing: 0);
```

### 2.5 字重

```dart
FontWeight displayWeightFor(Brightness brightness) =>
    brightness == Brightness.dark ? FontWeight.w600 : FontWeight.w500;
// headline 系固定 FontWeight.w600。
```

---

## 3. 布局

### 3.1 间距令牌（`RuQiSpacing`）

| 常量      | 值  | 用途                   |
| --------- | --- | ---------------------- |
| `xxs`     | 4   | 精细间隙、图标与文字   |
| `xs`      | 8   | 紧凑行内间隙           |
| `sm`      | 12  | 卡片内容间隙           |
| `md`      | 16  | 组件与组件之间         |
| `lg`      | 24  | 区块内间距、卡片内边距 |
| `xl`      | 32  | 卡片间、引述内边距     |
| `xxl`     | 48  | CTA 横幅内边距         |
| `section` | 80  | 区块纵向间距           |
| `huge`    | 120 | 主要区块分隔           |

营销页保持 `section` 级间距，不压缩；留白 = 可读性。

### 3.2 容器与栅格

- 内容最大宽：默认 1280、宽屏 1440 →
  `Center(child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 1280), child: ...))`；
- 卡片栅格：`LayoutBuilder` 或 `MediaQuery.sizeOf(context).width` 决定列数：
  桌面 3 列 / 平板 2 列 / 移动 1 列（`GridView` 或 `Wrap`）；
- 定价栅格：桌面 3–4 列 / 平板 2 列 / 移动 1 列；
- 产品截图：`SizedBox(width: double.infinity)` 横跨内容全宽，是页面主角。

---

## 4. 深度

### 4.1 阴影令牌（`RuQiElevation`）

亮色模式阴影；暗色模式一律为空列表（`List<BoxShadow> const []`），深度改由
「更亮的表面 + `BorderSide` 描边」承担：

| 层级 | 亮色                                                                    | 暗色                                                                   |
| ---- | ----------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| 0    | 无阴影、无描边                                                          | 无阴影、无描边                                                         |
| 1    | `surfaceContainerLowest` + `shadowSm`                                   | `surfaceContainer` + `BorderSide(width: 1, color: outlineVariant)`     |
| 2    | `surfaceContainerHigh` + `shadowMd`                                     | `surfaceContainerHigh` + `BorderSide(width: 1, color: hairlineStrong)` |
| 3    | `surface3` + `shadowLg` + `BorderSide(width: 1, color: hairlineStrong)` | 同左                                                                   |
| 4    | 焦点高亮 `surfaceContainerLow`；输入框聚焦描边 = 默认中性灰（仅加粗至 1.5px）                     | 同左                                                                   |

> 层级 1–3 用于自定义抬升容器（首页入口卡、浮动弹层、吸附 CTA）；
> `Card` 组件按 §4.2 用「1px 描边 + `elevation: 0`」，不再铺灰底。
> 例：首页入口卡默认 = 深度 1（`surfaceContainerLowest` + `shadowSm` + 1px
> `outlineVariant`），悬停 = 深度 2 阴影 + `surfaceContainerLow` 底色（§1.4）。

```dart
const List<BoxShadow> shadowSm = [
  BoxShadow(offset: Offset(0, 1), blurRadius: 3, color: Color(0x0F000000)),
  BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0A000000)),
];

const List<BoxShadow> shadowMd = [
  BoxShadow(offset: Offset(0, 4), blurRadius: 16, color: Color(0x1A000000)),
  BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x0F000000)),
];

const List<BoxShadow> shadowLg = [
  BoxShadow(offset: Offset(0, 12), blurRadius: 32, color: Color(0x1F000000)),
  BoxShadow(offset: Offset(0, 4), blurRadius: 8, color: Color(0x0F000000)),
];

const List<BoxShadow> shadowXl = [
  BoxShadow(offset: Offset(0, 24), blurRadius: 48, color: Color(0x26000000)),
  BoxShadow(offset: Offset(0, 8), blurRadius: 16, color: Color(0x14000000)),
];
```

### 4.2 `Card` 与焦点

```dart
CardThemeData(
  // 亮色白底、暗色比页面更亮一档；两种模式都用 1px 描边分层
  color: isDark ? scheme.surfaceContainer : scheme.surfaceContainerLowest,
  elevation: 0,
  surfaceTintColor: Colors.transparent,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
    side: BorderSide(color: scheme.outlineVariant, width: 1),
  ),
)
```

焦点提示：`ThemeData.focusColor = surfaceContainerLow`（最浅中性表面，键盘焦点
也不再整块上色）；输入框
`focusedBorder = OutlineInputBorder(borderSide: BorderSide(color: hairlineInput, width: 1.5))`
——聚焦沿用默认中性描边，只从 1px 加粗到 1.5px，不上主色（见 §6.5）。

---

## 5. 动效

### 5.1 时长（`RuQiMotion`）

| 常量      | 值                            | 用途                       |
| --------- | ----------------------------- | -------------------------- |
| `instant` | `Duration(milliseconds: 80)`  | 波纹、开关、勾选           |
| `fast`    | `Duration(milliseconds: 150)` | 悬停、焦点环、气泡         |
| `normal`  | `Duration(milliseconds: 250)` | 弹窗、抽屉、下拉           |
| `slow`    | `Duration(milliseconds: 400)` | 页面转场、首屏淡入、跑马灯 |

### 5.2 缓动（`Curve`）

| 常量          | 值                           |
| ------------- | ---------------------------- |
| `easeDefault` | `Cubic(0.2, 0, 0, 1)`        |
| `easeIn`      | `Cubic(0.4, 0, 1, 1)`        |
| `easeOut`     | `Cubic(0, 0, 0.2, 1)`        |
| `easeSpring`  | `Cubic(0.34, 1.56, 0.64, 1)` |
| `easePulse`   | `Cubic(0.4, 0, 0.2, 1)`      |

### 5.3 减少动态

读取系统偏好：`MediaQuery.disableAnimationsOf(context)`。

- 命中时所有动画时长归零（`Duration.zero`），`easeSpring` 退化为
  `Curves.linear`；
- 主 CTA / 吸附 CTA 的过渡保留但用 `Duration.zero`；
- 倒计时脉冲**减弱而非禁用**：去掉 scale 动画，保留数字变化。

---

## 6. 组件

### 6.1 按钮（`RuQiButtonStyles`）

统一基线：`RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))`、
`EdgeInsets.symmetric(horizontal: 14, vertical: 8)`、`labelLarge`、最小高度 36。

| 组件                | Flutter                                                      | 状态规则                                                                                                                                                                 |
| ------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `button-primary`    | `FilledButton` + `RuQiButtonStyles.primary`                  | 默认中性：`surfaceContainerHigh` 填充 + `onSurface` 文本；hover / 聚焦亮成主色（hover `primaryHover` / press `primaryPress` + `onPrimary`）；disabled `surfaceContainerLow` + `inkTertiary` |
| `button-secondary`  | `OutlinedButton` + `secondary`                               | 默认中性：透明背景 + 1px `outline` 描边 + `onSurfaceVariant` 文本；hover / press / 聚焦时描边与文字转 `primary`（不铺底色） |
| `button-tertiary`   | `TextButton` + `tertiary`                                    | `onSurface` 文本；hover 背景 `surfaceContainer`                                                                                                                          |
| `button-link`       | `TextButton` + `link`（`textButtonTheme` 默认）               | 表格「操作」列行内动作：无描边 / 无底色 / 无水波纹；默认 `onSurfaceVariant` 文本，hover / press 只把文字转 `primary`                                                     |
| `button-link-danger` | `TextButton` + `linkDanger`                            | 表格「操作」列的破坏性动作（删除 / 移除）：默认与 `button-link` 同为 `onSurfaceVariant` 中性文本、无描边无底色，hover / press / 聚焦才转 `error` |
| `row-actions-menu`   | `RuQiRowActionsMenu`                                         | 表格「操作」列：动作 **≥3** 时统一收进 `···` 菜单（与 用户 页一致），≤2 时保持行内文字按钮；`···` 命中区 36×36，悬停只把图标转 `primary`（不渲染 tooltip，只保留无障碍标签）；菜单面板白底 + 1px `outlineVariant` 描边，菜单项 36 高、悬停文案转 `primary`（无灰底） |
| `button-inverse`    | `FilledButton` + `inverse`                                   | 亮色 `surface` 背景 + 亮色 `onSurface` 文本（用于 `brandDark` 表面）                                                                                                     |
| `button-danger`     | `FilledButton` + `danger`                                    | 默认中性：`surfaceContainerHigh` 填充 + `onSurface` 文本；hover / 聚焦亮成 `error`（press 更深一档）+ `onPrimary`；disabled `surfaceContainerLow` + `outline` |
| `button-full-width` | `SizedBox(width: double.infinity, child: FilledButton(...))` | 小屏（<428px）所有主 CTA 全宽居中                                                                                                                                        |

### 6.2 营销组件（NEW）

#### `CountdownTimer`

```dart
CountdownTimer({
  required DateTime endTime,
  bool compact = false,            // 紧凑变体：数字 24，块内边距 2/4
  List<String> labels = const ['时', '分', '秒'],
  String separator = ':',
  VoidCallback? onExpired,         // 到期触发一次；调用方禁用周边 CTA
})
```

规范：

- 实现：`Timer.periodic(const Duration(seconds: 1))`，按 `endTime.difference(now)`
  计算 时/分/秒，两位数补零；
- 数字块：`Container`，背景 `surfaceContainerHigh`，
  `BorderRadius.circular(6)`，`EdgeInsets.symmetric(horizontal: 8, vertical: 4)`
  （紧凑 4/2），最小宽 48（紧凑 36），内容居中；
- 数字：`RuQiTextStyles.countdownDigit`（36/700/1.0/-0.5），
  `FontFeature.tabularFigures()`，颜色 `accentEnergy`；
- 标签：`bodySmall` + `inkMuted`；分隔符：`inkTertiary`；
- 脉冲：数字变化时 `ScaleTransition`（`Tween(1.05 → 1.0)`），
  `RuQiMotion.fast` + `easePulse`（`didUpdateWidget` 中重新 `forward(from: 0)`）；
- 到期：全部显示 `00`，`onExpired` 仅回调一次；
- 无障碍：外层 `Semantics(liveRegion: true, label: '剩余时间 …')`；
- 使用规则：每页最多一个倒计时；到期不得自动播放声音。

#### `SocialProofBar` / `SocialProofTicker`

```dart
SocialProofBar({
  required String message,          // 如「200+ 人今天加入」
  String? actionLabel,              // 如「立即加入」，主色加粗
  VoidCallback? onAction,
  List<Widget> avatars = const [],  // 调用方传入 28px 头像
  bool inline = false,              // 内联变体：无背景，嵌入 Hero
})
```

规范：

- 容器：`Container`，`StadiumBorder()`，背景 `surfaceContainer`，
  `BorderSide(color: outlineVariant, width: 1)`，
  `EdgeInsets.symmetric(horizontal: 16, vertical: 8)`；
- 头像栈：28px 正圆、2px `surface` 描边、8px 重叠（`Stack` + `Positioned`）；
- 消息：`titleSmall` + `onSurfaceVariant`；动作文字：`primary` + `FontWeight.w500`；
- 位置：放在主 CTA 附近；
- Ticker 变体：`SocialProofTicker(messages:, duration: Duration(seconds: 30))`，
  内容复制一份做无缝横向滚动（`Transform.translate` + `AnimationController.repeat`）；
  系统减少动态时退化为静态列表。

#### `StickyCta`

```dart
StickyCta({
  required String buttonLabel,
  required VoidCallback onPressed,
  String? price,                    // 现价：headlineMedium + 700 + accentEnergy
  String? originalPrice,            // 划线原价：inkTertiary
  ScrollController? controller,     // 滚动超过首屏 70% 自动滑入
  bool visible = false,             // 手动显隐（不传 controller 时）
  VoidCallback? onDismissed,        // 持久化本次会话关闭偏好
})
```

规范：

- 放置：`Stack` 底部，`Positioned(left: 0, right: 0, bottom: 0)`；
- 外观：`Material` + `Container`，背景 `surface`，顶部
  `Border(top: BorderSide(color: outlineVariant))`，亮色加 `shadowLg`，
  `EdgeInsets.symmetric(horizontal: 24, vertical: 16)`，内容最大宽 1280；
- 显隐：`AnimatedSlide(offset: Offset(0, 1) ↔ Offset.zero)`，
  `RuQiMotion.normal` + `easeOut`；
- 滚动判定：

  ```dart
  final passed = position.pixels >= position.viewportDimension * 0.7;
  ```

- 布局：宽屏 `Row`（价格 + `Spacer` + CTA）；<768px 改 `Column` 纵向堆叠、
  CTA 全宽；
- 关闭按钮始终提供（`Icon(Icons.close)`）；关闭偏好存会话。

#### `ComparisonTable`

```dart
ComparisonTable({
  required List<String> columns,
  required List<ComparisonRow> rows,   // feature + List<ComparisonCell>
  int? featuredColumn,                 // 推荐列：primaryContainer 背景 + 徽章
  bool compact = false,                // 单元格 12/16，行高 40
  String recommendedLabel = '推荐',
})
```

规范：

- 桌面（`MediaQuery.sizeOf(context).width >= 768`）：标准表格——容器
  `RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
side: BorderSide(color: outlineVariant))`；表头 `surfaceContainer` 细带 +
  `outlineVariant` 下分隔线 + 字重 `w600`；
  单元格 `EdgeInsets.symmetric(horizontal: 24, vertical: 16)`（紧凑 16/12）；
  特性列 `FontWeight.w500` + `onSurface`；值列居中；
  勾选 `Icon(Icons.check, size: 18, color: success)`；空值 `—` + `inkTertiary`；
- 移动端（<768px）：**堆叠卡片**——每行一张 `Card`（`surfaceContainer`、
  `outlineVariant` 描边、`BorderRadius.circular(12)`、下边距 16），
  特性名作标题，其余单元格渲染为 `Row(mainAxisAlignment: spaceBetween)`
  「列名 + 值」；
- 推荐列徽章位于表头上方。

#### `PromoCodeInput`

```dart
PromoCodeInput({
  required double price,
  required FutureOr<PromoCodeResult> Function(String code) onApply,
  VoidCallback? onRemove,
})
// PromoCodeResult: PromoCodeValid(discount) | PromoCodeInvalid(message)
```

状态机：

- `idle`：`TextField` 占位「Enter promo code」+ `OutlinedButton`「Apply」；
- `applying`：按钮转 `CircularProgressIndicator`，输入框禁用；
- `invalid`：`enabledBorder` 用 `error` 描边 + `bodySmall` 错误消息；
- `valid`：`success` 描边 + 成功消息；按钮变「Remove」；
- 应用后显示优惠行：顶部 `BorderSide(width: 1, color: outlineVariant)`；原价 `TextDecoration.lineThrough`
  - `inkTertiary`；优惠额 `success`；最终价 `FontWeight.w700` + `accentEnergy`。

#### `FloatingPromo`

```dart
FloatingPromo({
  required String headline,
  required String body,
  required String ctaLabel,
  required VoidCallback onCtaPressed,
  Duration autoShowDelay = Duration(seconds: 15),  // 页面停留 15s
  double scrollThreshold = 0.8,                    // 滚动到 80% 页面
  ScrollController? scrollController,
  VoidCallback? onDismissed,
})
```

规范：

- 触发：进入页面 15s 的 `Timer`、滚动深度 80%（`pixels >= maxScrollExtent * 0.8`），
  取先到者；退出意图在 Flutter 桌面 Web 可另用 `PointerEvent` 监听扩展；
- 外观：右下角 `EdgeInsets.all(32)`、宽 360、最大宽 `viewportWidth - 64`；
  背景 `surface`、`BorderSide(width: 1, color: hairlineStrong)`、
  `BorderRadius.circular(12)`、亮色 `shadowLg`；
- 显隐：`AnimatedOpacity` + `AnimatedSlide(Offset(0, 0.2) ↔ Offset.zero)`，
  `RuQiMotion.normal` + `easeOut`；
- 内容：`headlineMedium` + `titleSmall` 正文 + 全宽 `FilledButton`；
- 关闭：X 按钮永久关闭（持久化）；点击外部 / Esc 本次会话关闭；
- 移动端（<768px）：全宽底部、`BorderRadius.vertical(top: circular(12))`，
  作为底部弹层展示。

### 6.3 定价组件

| 组件                      | Flutter                     | 关键规范                                                                                                                             |
| ------------------------- | --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| 定价切换（未选中 / 选中） | `ToggleButtons` 或 `TabBar` | 未选中：`surface` 背景 + `inkMuted` + `labelMedium` + `StadiumBorder()`；选中：`surfaceContainerHigh` + `onSurface`                  |
| 标准定价卡                | `Card` + 自定义布局         | 按 §4.2（亮色白底 / 暗色比页面亮一档 + 1px `outlineVariant` 描边、`elevation: 0`）、`BorderRadius.circular(12)`、`EdgeInsets.all(24)`；标题 `headlineMedium`、价格 `headlineLarge`、CTA 钉底 |
| 推荐定价卡                | 自定义容器                  | `brandDark` 背景 + `onDark` 文本、深度 2、CTA 用 `button-inverse`                                                                    |
| 营销定价卡                | 标准卡 + 附加               | 节省徽章（`tag-soft`）+ 内联 `SocialProofBar`                                                                                        |

### 6.4 卡片与容器

| 组件           | Flutter                                 | 内边距 / 圆角 / 深度                                           |
| -------------- | --------------------------------------- | -------------------------------------------------------------- |
| 功能卡         | `Card` + `headlineMedium` 标题 + 图标槽 | 24 / 12 / 1                                                    |
| 客户引述卡     | `Card` + 引述 + 40px 头像               | 32 / 12 / 1                                                    |
| 截图卡         | `Card` + 全宽截图                       | 24 / 16 / 2                                                    |
| 仪表盘合成卡   | `Card` + 多面板合成图                   | 24 / 12 / 2                                                    |
| 暖色插曲带     | `Container`（少用）                     | 32 / 12 / 0                                                    |
| 收尾 CTA 横幅  | 自定义容器，居中布局                    | 48 / 12 / 2                                                    |
| 营销 CTA 横幅  | 自定义容器                              | `brandDark`、64/48、倒计时 + 社交证明 + 双 CTA，移动端纵向堆叠 |
| 客户 Logo 瓦片 | `Container`                             | 16 / 4 / 0                                                     |

> 「深度」列为 §4.1 的抬升等级，适用于自定义容器（首页入口卡、营销卡等）；
> `Card` 一律按 §4.2：亮色白底 / 暗色比页面亮一档 + 1px `outlineVariant`
> 描边 + `elevation: 0`。

### 6.5 输入与表单

`TextField` 统一由 `InputDecorationTheme` 提供：`filled: true` +
`surfaceContainerLowest` 填充（亮色 = 卡片白，与底色一致）、
`OutlineInputBorder(borderRadius: BorderRadius.circular(6))` +
`BorderSide(width: 1, color: hairlineInput)`
描边、`EdgeInsets.symmetric(horizontal: 12, vertical: 8)`；占位 `inkTertiary`；
浮动标签（有值 / 聚焦时贴在描边上）取 `inkMuted`，不使用主色；
焦点沿用默认 `hairlineInput` 描边（仅 1px → 1.5px，不上主色，填充也不变深）；
错误态 `error` 描边 + `bodySmall` 错误文本。

线索收集组（`form-group-marketing`）：`Wrap` / `Row` —— 输入框 `Expanded`
（最小宽 200）、`FilledButton` 不换行、同意文本 `bodySmall` + `inkTertiary`
占满整行。

### 6.6 标签、Pill 与状态

| 组件          | Flutter              | 规范                                                                          |
| ------------- | -------------------- | ----------------------------------------------------------------------------- |
| `tag-soft`    | `Chip` 或自定义容器  | `primaryContainer` 背景 + `primary` 文本 + `bodySmall` + `StadiumBorder()`    |
| `tag-outline` | `Chip`               | 透明背景 + `BorderSide(width: 1, color: hairlineStrong)` + `onSurfaceVariant` |
| 节省徽章      | 自定义容器           | `success` @ 12% 背景 + `success` 文本 + `FontWeight.w600` + `StadiumBorder()` |
| 状态徽章      | `Chip` / 圆点 + 文本 | `surfaceContainerHigh` + `inkMuted`；语义变体 `success/warning/error/info`    |
| 筛选 Chip（默认） | `Chip` / `FilterChip` | `surfaceContainerLowest` 底（亮色 = 白）+ 1px `outline` 描边（比卡片描边深一档，保证小元素辨识）；选中 `primaryContainer`；文字 `onSurfaceVariant`、`StadiumBorder()` |
| 分段选择（`SegmentedButton`） | `segmentedButtonTheme` | 选中段 `surfaceContainerHigh` 底 + **`primary` 文案高亮**，未选中透明 + `onSurfaceVariant`；整组 1px `outlineVariant` 描边；hover `surfaceContainerLow`；不使用 M3 默认 `secondaryContainer`（品牌粉） |

### 6.7 导航

- 顶部导航 → `AppBar`（或自定义 `PreferredSizeWidget`）：`surface` 背景、
  `onSurface` 文本、高 56、无阴影；左侧 Logo、中间链接、右侧次按钮 + 主按钮
  （控制台顶栏的「退出」用 `button-secondary`：默认中性描边，hover 才转主色）；
  <768px 收起为抽屉 / 汉堡菜单；
- 营销导航 → 同顶部导航，右侧主 CTA 与页面主 CTA 文案一致；滚动越过 Hero
  后高度缩至 48（`AppBar.scrolledUnderElevation` / 滚动监听调整）。

### 6.8 页脚

自定义 `Footer`：`surface` 背景、`inkMuted` + `bodySmall` 文本、
`EdgeInsets.symmetric(horizontal: 24, vertical: 64)`；桌面 4–6 列、
平板 2 列、移动 1 列；末行法律与版权信息。

### 6.9 弹层面板（In-Place Panel）

后台控制台（管理后台 / 运营后台）的内容区弹层：点击卡片「设置 / 编辑」等
动作后，面板覆盖在内容区之上，左侧菜单与顶部导航保持可见；面板是内容区的
内嵌层而非悬浮模态，返回时 `Navigator.pop` 关闭。

| 项     | 规范                                                                                                                                                      |
| ------ | --------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 尺寸   | 与内容区同尺寸（大面板模式）：`Positioned(left: 菜单宽, top: 顶栏高, right: 0, bottom: 0)`                                                                |
| 遮罩   | 无：`barrierColor: Colors.transparent`；仍保留 `barrierDismissible: true`（点击外部关闭）与 `barrierLabel`                                                |
| 阴影   | 无：深度 0，不引用 `RuQiElevation`，`Material` 不设 `elevation`                                                                                           |
| 描边   | 仅 `left` / `top` 两条 `BorderSide(width: 1, color: outlineVariant)`，与菜单、顶栏分隔；右 / 下边缘贴齐窗口，不画框线                                     |
| 背景   | `surface`                                                                                                                                                 |
| 标题条 | 高 48、`surfaceContainerLow` 背景、左侧 `RuQiSpacing.md` 内边距；标题 `titleMedium` / 700 / `onSurface`，右侧关闭按钮（tooltip「关闭」，图标 `inkMuted`） |
| 分隔线 | 标题条与正文之间 `Divider(height: 1, color: outlineVariant)`                                                                                              |
| 正文   | 可滚动区域（`SingleChildScrollView` / `ListView`）；表单类弹层底部固定操作行：`button-tertiary` 取消 + `button-primary` 主操作                            |

动效（§5 令牌）：

- 进入 / 返回：从右侧滑入 / 滑出，`SlideTransition` 位移
  `Offset(1, 0) → Offset.zero`，`RuQiMotion.normal`（250ms）+ `easeOut`；
- 减少动态：命中 `MediaQuery.disableAnimationsOf(context)` 时动画时长归零。

实现约定：

```dart
showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: '关闭',
  barrierColor: Colors.transparent,
  transitionDuration: RuQiMotion.resolve(context, RuQiMotion.normal),
  transitionBuilder: (context, animation, secondaryAnimation, child) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(
        parent: animation,
        curve: RuQiMotion.resolveCurve(context, RuQiMotion.easeOut),
      )),
      child: child,
    );
  },
  pageBuilder: (context, animation, secondaryAnimation) {
    // Positioned(left: 菜单宽, top: 顶栏高, right: 0, bottom: 0, child: 面板)
  },
);
```

参考实现：管理后台设置内容面板（`SettingsContentPanel` /
`showSystemSettingsPanel`）与运营后台动作弹窗的大面板模式。

### 6.10 主题设置（个人中心 → 主题）

版式参考 hopscotch：左列为页面标题 + 说明，右列为设置分组；每组是
「组标题 + 当前取值 + 选项行」。

| 项         | 规范                                                                                                                                                                                                                      |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 布局       | `Row`：左列 `flex: 4`（标题 `titleLarge` / 600 + 说明 `bodyMedium` / `inkMuted`），右列 `flex: 6`，列间距 `RuQiSpacing.xxl`                                                                                               |
| 分组       | 组标题 `titleSmall` / 700 / `onSurface`；当前取值 `bodySmall` / `inkMuted`（间距 2）；选项行距离取值 `RuQiSpacing.sm`；组间距 `RuQiSpacing.xl`                                                                            |
| 背景选项   | 36 × 36 图标按钮：`desktop_windows_outlined`（跟随系统）/ `light_mode_outlined`（亮色）/ `dark_mode_outlined`（暗色）；选中 = `surfaceContainerHigh` 底 + `primary` 图标，未选中 = `onSurfaceVariant`；`Tooltip` 显示文案 |
| 强调色选项 | 36 × 36 命中区 + 20px 圆环（2px 描边取色板原色），选中 = `surfaceContainerHigh` 底；`Tooltip` 显示色名                                                                                                                    |
| 生效       | 背景写 `MaterialApp.themeMode`，强调色写 `ruoQiTheme(accent:)`，即时生效（§1.5、§9.4）                                                                                                                                    |
| 数据源     | 取值由 App 根部持有；弹窗打开期间外壳持有当前值，切页返回不丢选择                                                                                                                                                         |

---

## 7. 营销约束

1. 营销上下文用 `RuQiPurpose.marketing` 标记主题；
2. 主色填充面积 ≤ 5% 页面：主色仅用于主 CTA、价格高亮、倒计时数字、
   链接下划线；
3. 每个 band 只允许一个主按钮；同 band 出现多个主按钮时，其余降级为
   `button-secondary` 样式；
4. 紧迫组件最多取两个（倒计时 / 库存 / 社交证明 / 吸附 CTA）；
5. 吸附 CTA 必须可关闭；
6. 深色模式营销页：白底截图替换为暗色变体，或 `ColorFiltered` 压暗
   （`ColorFilter.matrix` 亮度 0.8）；`primarySubdued` 用 `#3D1520`；
   反色表面文本用 `#F0F2F5` 而非纯白；
7. 小屏（<428px）所有主 CTA 全宽。

---

## 8. 响应式

### 断点

| 名称         | 判定            | 说明                                |
| ------------ | --------------- | ----------------------------------- |
| Wide         | `width >= 1440` | 内容最大宽 1440                     |
| Desktop      | `width >= 1024` | 卡片 3 列、定价 3–4 列              |
| Tablet       | `width >= 768`  | 卡片 2 列、定价 2 列、导航收起      |
| Mobile       | `width >= 428`  | 单列、display 字号下调、定价手风琴  |
| Small Mobile | `width < 428`   | `displayLarge` 缩至 32、主 CTA 全宽 |

判定统一使用 `MediaQuery.sizeOf(context).width` 或 `LayoutBuilder`。

> 注意：`common` 包现有 `RuoQiBreakpoints.tablet = 600` 与本规范 768
> 不一致，落地时需统一（建议以本规范为准）。

### 组件响应式行为

| 组件       | 桌面                | 平板            | 移动           |
| ---------- | ------------------- | --------------- | -------------- |
| 倒计时     | 行内横向            | 行内可换行      | 纵向堆叠、居中 |
| 吸附 CTA   | 两列（价格 + 按钮） | 两列            | 全宽堆叠       |
| 对比表     | 标准表格            | 横向滚动        | 堆叠卡片       |
| 浮动弹层   | 右下角 360px        | 底部居中 90% 宽 | 全宽底部       |
| 社交证明条 | 胶囊                | 胶囊            | 胶囊、文本换行 |

---

## 9. 模式实现

### 9.1 `ThemeData` 构建

```dart
ThemeData ruoQiTheme({
  Brightness brightness = Brightness.light,
  RuQiPurpose purpose = RuQiPurpose.standard,
  String? fontFamily = 'Inter',
  Color? accent,                        // 见 §1.5：个人中心 → 主题
}) {
  final colors = RuQiColors.forMode(
    brightness,
    purpose: purpose,
    accent: accent,
  );
  final isDark = brightness == Brightness.dark;
  // 1. ColorScheme.copyWith：见「1.1 ColorScheme 角色」
  // 2. TextTheme：见「2.2 TextTheme 层级」（display 系字重按模式注入）
  // 3. 组件主题：filledButtonTheme / outlinedButtonTheme / textButtonTheme /
  //    inputDecorationTheme / cardTheme / chipTheme / segmentedButtonTheme /
  //    dataTableTheme …
  //    inputDecorationTheme / cardTheme / chipTheme / dataTableTheme …
  // 4. extensions: [RuQiThemeExtension(colors, elevation, displayWeight)]
  // 5. 模式差异：卡片两种模式都是 1px outlineVariant 描边 + elevation 0（§4.2）
}
```

### 9.2 模式检测与持久化

- 默认跟随系统：`MaterialApp(theme: ruoQiTheme(brightness: light),
darkTheme: ruoQiTheme(brightness: dark), themeMode: ThemeMode.system)`；
- 提供显式切换（`Brightness` 状态提升到 App 根部）；
- 营销页同时声明 `purpose`；
- 持久化：`shared_preferences` 保存 mode 与 purpose。

### 9.3 亮色模式设计依据

亮色与暗色需要**相反的深度策略**：

| 属性       | 亮色                                           | 暗色                       |
| ---------- | ---------------------------------------------- | -------------------------- |
| 深度机制   | `BoxShadow`                                    | 表面亮度（更亮的表面更近） |
| 卡片分隔   | 白卡片 + 1px `outlineVariant` 描边（§4.2）     | 更亮背景 + 1px 描边        |
| 描边可见性 | 用于卡片 / 表格 / 输入边界                     | 必需，用于边缘定义         |
| 文本对比   | 深色文本 ≥ 4.5:1（WCAG AA）                    | 天然更高对比               |
| 表面阶梯   | 页面 / 卡片 `#FFFFFF`、悬停 `#FAFAFA`、选中 `#EDEDED` | 每级 2–3% 亮度      |

亮色以「白卡片 + 1px 描边」为主，避免大面积灰底（§1.4）；阴影只用于抬升卡
（首页入口卡、浮动弹层、吸附 CTA）。暗色背景上阴影不可见，改用描边。
亮色底一律为白（页面 / 顶栏 / 菜单 / 卡片），柔和分层用无彩灰
（`#FAFAFA` / `#F5F5F5` / `#EDEDED`），不带色相；
需要着色时由主题设置的强调色注入（§1.5）。

亮色「线框」分两级：结构性描边（卡片 / 表格 / 面板 / 分隔线）取
`outlineVariant`（`#EAEAEA`），输入框与 Chip 等需要辨识的小元素取
`outline`（`#DBDBDB`）。既不铺灰底，又保留足够结构感——「白 + 一档可辨的线」。

### 9.4 背景模式（个人中心 → 主题）

| 选项     | 图标                             | 解析结果                        |
| -------- | -------------------------------- | ------------------------------- |
| 跟随系统 | `Icons.desktop_windows_outlined` | `ThemeMode.system`              |
| 亮色     | `Icons.light_mode_outlined`      | `ThemeMode.light`（平台端默认） |
| 暗色     | `Icons.dark_mode_outlined`       | `ThemeMode.dark`                |

- 单一数据源：App 根部持有 `themeMode` 与 `accent`，
  `MaterialApp.themeMode` + `theme: ruoQiTheme(accent:)` +
  `darkTheme: ruoQiTheme(brightness: dark, accent:)` 同时读取；
- 顶栏背景模式切换与主题页写同一份状态，两处都是同样三档
  （`RuQiThemeModeSwitch` 复用 `system / light / dark` 选项与选中样式）；
- 弹窗（个人中心）打开期间由外壳持有当前值，切页返回仍是刚选的那套；
- 持久化：`shared_preferences` 保存 `themeMode` 与 `accent`（建议键
  `appearance.themeMode` / `appearance.accent`），启动读取后注入根部状态。

---

## 10. Do's and Don'ts — 营销扩展

### Do

- 每页最多一个倒计时；
- 社交证明放在主 CTA 附近；
- 吸附 CTA 必须可关闭；
- 移动端验证对比表堆叠布局；
- 营销页主色面积控制在 5% 以内；
- 小屏（<428px）主 CTA 全宽；
- 为产品截图提供暗色变体。

### Don't

- 倒计时到期不自动播放声音；
- 浮动弹层不在首屏立即出现（15s 或滚动 80% 之后）；
- 不堆叠多个紧迫组件（最多两个）；
- 营销页不用主色做大面积背景；
- 吸附 CTA 不提供关闭按钮；
- 主按钮与次按钮文案不重复。

---

## 11. 迭代指南

1. 一次只落地一个组件，按令牌名引用；
2. 新增区块先决定它位于哪一级表面抬升；
3. 默认正文 `bodyMedium`（15 / 400）；
4. 每个组件在亮色与暗色下都验证后再合入；
5. 营销组件用 `RuQiPurpose.marketing` 验证；
6. 新增变体作为独立组件条目；
7. 主色稀缺：每个 band 一个主按钮（营销页每页一个）；
8. 功能区块以产品截图为先，Hero 以 mesh 或截图为先。

---

## 12. 已知缺口

- Inter 字体资源需由各 App 打包（或引入 `google_fonts`），规范只约定字体族；
- 渐变 mesh 需 `CustomPainter` / SVG 资源；
- 表单校验与多步表单按需扩展；
- 骨架屏 / 空态沿用语义表面 + 文本令牌；
- 营销组件无障碍审计未完成（焦点顺序、倒计时变化的屏幕阅读器播报、
  社交证明 ticker 的 `Semantics(liveRegion:)`）；
- 减少动态需要更细粒度：倒计时脉冲应减弱而非完全禁用；
- `RuoQiBreakpoints.tablet`（600）与本规范断点（768）需统一。
- 外观设置（背景模式 / 强调色）尚未持久化：目前只存在 App 内存状态，
  刷新后回到默认值（§9.4 的 `shared_preferences` 约定待落地）。

---

## 附录：参考实现

### 倒计时数字脉冲

```dart
// didUpdateWidget 中，数字值变化时触发
final scale = Tween<double>(begin: 1.05, end: 1.0).animate(
  CurvedAnimation(parent: controller, curve: Cubic(0.4, 0, 0.2, 1)),
);
```

### 吸附 CTA 滚动判定

```dart
final passed = position.pixels >= position.viewportDimension * 0.7;
```

### 对比表移动端堆叠

```dart
// <768px：Row 布局切换为 Column；每行一行 Card，
// 单元格渲染为 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween)。
```

### 浮动弹层

```dart
// AnimatedOpacity + AnimatedSlide(Offset(0, 0.2) → Offset.zero)，
// duration: Duration(milliseconds: 250), curve: Cubic(0, 0, 0.2, 1)。
```

### 营销模式覆盖

```dart
// 亮色营销：primary = Color(0xFF2563EB)，accentEnergy 保持 Color(0xFFFE2C55)。
// 暗色营销：primarySubdued = Color(0xFF3D1520)，hairlineInput = Color(0xFF4A4E59)。
// 卡片：两种模式都是白底（暗色比页面亮一档）+ 1px outlineVariant 描边 + elevation 0。
```

### 全局营销重置

```dart
// purpose == RuQiPurpose.marketing 时：主色用量 ≤ 5%；
// 同一 band 多个主按钮 → 其余降级为 button-secondary 样式。
```

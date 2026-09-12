import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'admin_pages/system_settings_dialog.dart';
import 'ops_pages/operations_console_dialog.dart';

/// 平台端（PC）首页：控制台入口。
///
/// 版式参考 `frontend/tools/dev_all_hub.html`：标题区 + 响应式卡片网格 + 页脚说明。
/// 颜色一律取自 DESIGN-consensus.md 的语义角色（ColorScheme / RuQiThemeExtension），
/// 不写死十六进制色值。
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.themeMode = ThemeMode.light,
    this.onThemeModeChanged,
  });

  /// 当前主题模式，决定顶栏切换按钮的图标。
  final ThemeMode themeMode;

  /// 切换深浅色；为 null 时按钮不可点（预览 / 测试场景）。
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // 文案可选中由 main.dart 的全站 builder 统一提供（ruoQiSelectionBuilder）。
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        // 规范 §6.7 顶部导航无阴影；用 1px 细线把顶栏与画布分开
        // （与入口页 `.doc-topbar` 的 border-bottom、ConsoleTopBar 一致）。
        shape: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
        title: _TopBar(
          themeMode: themeMode,
          onThemeModeChanged: onThemeModeChanged,
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              RuQiSpacing.lg,
              RuQiSpacing.xl,
              RuQiSpacing.lg,
              RuQiSpacing.xxl,
            ),
            children: [
              const _PageHeader(),
              const SizedBox(height: RuQiSpacing.lg),
              LayoutBuilder(
                builder: (context, constraints) {
                  final cards = [
                    for (final entry in _entries)
                      _ConsoleEntryCard(entry: entry),
                  ];
                  if (constraints.maxWidth < _twoColumnBreakpoint) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        cards[0],
                        const SizedBox(height: RuQiSpacing.sm),
                        cards[1],
                      ],
                    );
                  }
                  // 注意：这里不能用 IntrinsicHeight + stretch 强行等高——
                  // 文本的 intrinsic 高度与真实字体渲染会差 1–2px，会把卡片撑溢出。
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: RuQiSpacing.sm),
                      Expanded(child: cards[1]),
                    ],
                  );
                },
              ),
              const SizedBox(height: RuQiSpacing.xl),
              const _PageFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 正文最大宽度，与入口页 `.grid` 的 1000px 一致。
const double _contentMaxWidth = 1000;

/// 宽于该值时入口卡片排成两列。
const double _twoColumnBreakpoint = 760;

/// 顶栏内容：与正文共用同一条内容栏（maxWidth 1000 + 24 水平内边距），
/// 这样左侧品牌、右侧开关和下方卡片的左右边缘严格对齐。
/// 版本徽标紧跟在品牌文案之后成组，右侧只留深浅色开关。
class _TopBar extends StatelessWidget {
  const _TopBar({required this.themeMode, this.onThemeModeChanged});

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentMaxWidth),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: RuQiSpacing.lg),
          child: Row(
            children: [
              Text(
                'RuoQi-Platform',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: RuQiSpacing.xs),
              const AppBadge(appName: 'platform_pc', version: '1.0.0'),
              const Spacer(),
              RuQiThemeModeSwitch(
                themeMode: themeMode,
                onChanged: onThemeModeChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 首页的两个控制台入口。
const _entries = <_ConsoleEntry>[
  _ConsoleEntry(
    icon: Icons.admin_panel_settings_outlined,
    title: '系统管理',
    subtitle: '一账通 ID 独立体系',
    modules: '设置 · 用户 · 权限 · 菜单 · 基础 · 语言 · 日志',
    tags: ['管理后台', '一账通 ID'],
    onOpen: SystemSettingsDialog.show,
  ),
  _ConsoleEntry(
    icon: Icons.dashboard_customize_outlined,
    title: '运营后台',
    subtitle: '一账通运营端 SSO',
    modules: '租户 · 团队空间 · 项目 · API 授权 · 个人中心',
    tags: ['运营端', 'SSO'],
    onOpen: OperationsConsoleDialog.show,
  ),
];

class _ConsoleEntry {
  const _ConsoleEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.modules,
    required this.tags,
    required this.onOpen,
  });

  final IconData icon;
  final String title;

  /// 一句话定位，如「一账通 ID 独立体系」。
  final String subtitle;

  /// 体系内的模块清单，用 `·` 分隔。
  final String modules;

  /// 卡片底部的能力标签，对应入口页的 `.tag` 胶囊。
  final List<String> tags;

  final void Function(BuildContext context) onOpen;
}

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        theme.colorScheme.onSurfaceVariant;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '平台工作台',
          // 页标题取 headlineLarge（28 / 600）；中文按 §2.4 复位负字距。
          style: zh(
            theme.textTheme.headlineLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.sm),
        Text(
          '两个控制台入口：系统管理面向一账通 ID 独立体系，'
          '运营后台面向一账通运营端 SSO。入口在弹窗内打开，关闭后回到本页。',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: muted,
            height: 1.6,
          ),
        ),
      ],
    );
  }
}

class _PageFooter extends StatelessWidget {
  const _PageFooter();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        theme.colorScheme.onSurfaceVariant;
    return Text(
      'platform_pc · 平台端 PC 原型 · 端口 51000',
      style: theme.textTheme.bodySmall?.copyWith(color: muted),
    );
  }
}

/// 入口卡片：图标 + 标题 + 说明 + 能力标签，悬停时描边转主色并轻微上浮。
class _ConsoleEntryCard extends StatefulWidget {
  const _ConsoleEntryCard({required this.entry});

  final _ConsoleEntry entry;

  @override
  State<_ConsoleEntryCard> createState() => _ConsoleEntryCardState();
}

class _ConsoleEntryCardState extends State<_ConsoleEntryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entry = widget.entry;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        colorScheme.onSurfaceVariant;
    final radius = BorderRadius.circular(RuQiSpacing.sm);
    // 规范 §1.4 色块约束：卡片不铺灰底，底色取最浅的中性表面（亮色 #FAFBFC），
    // 层级交给 1px 描边 + 浅阴影（§4.1 深度 1）。
    final cardColor = theme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;
    final hoverColor = theme.brightness == Brightness.dark
        ? colorScheme.surfaceContainer
        : colorScheme.surfaceContainerLow;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: RuQiMotion.resolve(context, RuQiMotion.fast),
        curve: RuQiMotion.easeOut,
        transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
        decoration: BoxDecoration(
          color: _hovered ? hoverColor : cardColor,
          borderRadius: radius,
          border: Border.all(
            color: _hovered ? colorScheme.primary : colorScheme.outlineVariant,
          ),
          // 规范 §4.1 深度 1：亮色给阴影、暗色为空（靠描边分层）。
          // 填充与阴影同在一层装饰里，阴影先画、填充后盖，
          // 不会像「Material 底色 + BoxShadow」那样把卡片内部压暗。
          boxShadow: RuQiElevation.shadowsFor(
            theme.brightness,
            _hovered ? 2 : 1,
          ),
        ),
        // 透明 Material 只承载 InkWell 水波纹，填充在上一层装饰里。
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: () => entry.onOpen(context),
            child: Padding(
              padding: const EdgeInsets.all(RuQiSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(RuQiSpacing.sm),
                        ),
                        child: Icon(
                          entry.icon,
                          size: 22,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: RuQiSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.title,
                              style: zh(
                                theme.textTheme.titleLarge!.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            const SizedBox(height: RuQiSpacing.xs),
                            Text(
                              entry.subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: muted,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: RuQiSpacing.xxs),
                            Text(
                              entry.modules,
                              style: zh(
                                theme.textTheme.bodySmall!.copyWith(
                                  color:
                                      theme
                                          .extension<RuQiThemeExtension>()
                                          ?.inkMuted ??
                                      colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: RuQiSpacing.md),
                  Row(
                    children: [
                      for (final tag in entry.tags) ...[
                        _TagPill(label: tag),
                        const SizedBox(width: RuQiSpacing.xs),
                      ],
                      const Spacer(),
                      Text(
                        '打开',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: RuQiSpacing.xxs),
                      Icon(
                        Icons.arrow_forward,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 能力标签，样式对应入口页的 `.tag` 胶囊。
class _TagPill extends StatelessWidget {
  const _TagPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = theme.extension<RuQiThemeExtension>();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: RuQiSpacing.xs + 2,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        // 规范 §6.6 `tag-outline`：1px hairlineStrong + onSurfaceVariant 文本。
        border: Border.all(
          color: ext?.hairlineStrong ?? theme.colorScheme.outline,
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

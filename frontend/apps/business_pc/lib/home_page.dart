import 'package:flutter/material.dart';
import 'package:common/common.dart';

import 'customer/marketing_page.dart';
import 'merchant/home_page.dart';
import 'partner/home_page.dart';
import 'prototype_dialog.dart';

/// 业务端（PC）首页：业务工作台。
///
/// 三个业务域（客户 / 商户 / 伙伴）各自在弹窗内打开原型，
/// 版式与交互对齐平台端首页：标题区 + 响应式卡片 + 页脚说明。
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    this.themeMode = ThemeMode.light,
    this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
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
              // 三个业务域是并列入口：宽屏用横向卡片（图标 + 文案在左、
              // 标签与动作在右），窄屏由卡片自身退化为纵向堆叠。
              for (var i = 0; i < _entries.length; i++) ...[
                if (i > 0) const SizedBox(height: RuQiSpacing.sm),
                _EntryCard(entry: _entries[i]),
              ],
              const SizedBox(height: RuQiSpacing.xl),
              const _PageFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

/// 正文最大宽度，与平台端首页保持一致。
const double _contentMaxWidth = 1000;

/// 卡片宽于该值时用横向版式（图标在左、动作在右）。
const double _wideCardBreakpoint = 680;

/// 顶栏：品牌 + 版本徽标成组在左，右侧是背景模式切换。
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
                'RuoQi-Business',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: RuQiSpacing.xs),
              const AppBadge(appName: 'business_pc', version: '1.0.0'),
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
          '业务工作台',
          style: zh(
            theme.textTheme.headlineLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.sm),
        Text(
          '三个业务域入口：客户面向 C 端客户的营销落地页，商户面向一账通租户的 IDM 业务页，'
          '伙伴面向合作伙伴中心。入口在弹窗内打开，关闭后回到本页。',
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
      'business_pc · 业务端 PC 原型 · 端口 51002',
      style: theme.textTheme.bodySmall?.copyWith(color: muted),
    );
  }
}

/// 业务工作台的三个入口。
const _entries = <_Entry>[
  _Entry(
    icon: Icons.storefront_outlined,
    title: '客户',
    subtitle: '营销落地页',
    modules: '首屏 · 功能 · 对比 · 定价 · 收尾 CTA',
    tags: ['客户域', '营销'],
    dialogTitle: '客户 PC — 营销落地页',
    builder: _customerPrototype,
  ),
  _Entry(
    icon: Icons.fingerprint,
    title: '商户',
    subtitle: 'IDM 租户业务',
    modules: '自建应用 · 身份源 · 导入 · 消息设置',
    tags: ['商户域', 'IDM'],
    dialogTitle: '商户 PC — IDM 租户业务',
    builder: _merchantPrototype,
  ),
  _Entry(
    icon: Icons.handshake_outlined,
    title: '伙伴',
    subtitle: '合作伙伴中心',
    modules: '合作概览（原型占位）',
    tags: ['伙伴域'],
    dialogTitle: '伙伴 PC — 合作伙伴中心',
    builder: _partnerPrototype,
  ),
];

Widget _customerPrototype() => const MarketingPage(embedded: true);
Widget _merchantPrototype() => const MerchantHomePage(embedded: true);
Widget _partnerPrototype() => const PartnerHomePage(embedded: true);

class _Entry {
  const _Entry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.modules,
    required this.tags,
    required this.dialogTitle,
    required this.builder,
  });

  final IconData icon;
  final String title;

  /// 一句话定位，如「IDM 租户业务」。
  final String subtitle;

  /// 业务域内的页面清单，用 `·` 分隔。
  final String modules;

  final List<String> tags;

  /// 弹窗顶栏标题。
  final String dialogTitle;

  /// 弹窗内的原型页面。
  final Widget Function() builder;
}

/// 入口卡片：图标 + 标题 + 说明 + 页面清单 + 标签，悬停时描边转主色并轻微上浮。
class _EntryCard extends StatefulWidget {
  const _EntryCard({required this.entry});

  final _Entry entry;

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final radius = BorderRadius.circular(RuQiSpacing.sm);
    // 规范 §1.4 色块约束：卡片不铺灰底，底色取最浅的中性表面（亮色 #FFFFFF），
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
          // 悬停高亮用底色（亮色 #FAFAFA）+ 上浮/阴影，不用主色描边。
          border: Border.all(color: colorScheme.outlineVariant),
          // 填充与阴影同层：阴影先画、填充后盖，卡片内部不会被压暗。
          boxShadow: RuQiElevation.shadowsFor(
            theme.brightness,
            _hovered ? 2 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            onTap: () => PrototypeDialog.show(
              context,
              title: widget.entry.dialogTitle,
              child: widget.entry.builder(),
            ),
            child: Padding(
              padding: const EdgeInsets.all(RuQiSpacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) =>
                    constraints.maxWidth >= _wideCardBreakpoint
                    ? _wide(context)
                    : _narrow(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 宽屏：图标 + 文案在左，标签与动作在右，撑满卡片宽度。
  Widget _wide(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _icon(context),
        const SizedBox(width: RuQiSpacing.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _title(context),
              const SizedBox(height: RuQiSpacing.xs),
              _subtitle(context, theme),
              const SizedBox(height: RuQiSpacing.xxs),
              _modules(context, theme),
            ],
          ),
        ),
        const SizedBox(width: RuQiSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _tags(context, entry),
            ),
            const SizedBox(height: RuQiSpacing.md),
            _action(context, theme),
          ],
        ),
      ],
    );
  }

  /// 窄屏：图标与文案横向成组，模块清单与动作在下方堆叠。
  Widget _narrow(BuildContext context) {
    final theme = Theme.of(context);
    final entry = widget.entry;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _icon(context),
            const SizedBox(width: RuQiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _title(context),
                  const SizedBox(height: RuQiSpacing.xs),
                  _subtitle(context, theme),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: RuQiSpacing.sm),
        _modules(context, theme),
        const SizedBox(height: RuQiSpacing.md),
        Row(
          children: [
            ..._tags(context, entry),
            const Spacer(),
            _action(context, theme),
          ],
        ),
      ],
    );
  }

  Widget _icon(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(RuQiSpacing.sm),
      ),
      child: Icon(widget.entry.icon, size: 22, color: colorScheme.primary),
    );
  }

  Widget _title(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      widget.entry.title,
      style: zh(
        theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _subtitle(BuildContext context, ThemeData theme) {
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        theme.colorScheme.onSurfaceVariant;
    return Text(
      widget.entry.subtitle,
      style: theme.textTheme.bodyMedium?.copyWith(color: muted, height: 1.5),
    );
  }

  Widget _modules(BuildContext context, ThemeData theme) {
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        theme.colorScheme.onSurfaceVariant;
    return Text(
      widget.entry.modules,
      style: zh(theme.textTheme.bodySmall!.copyWith(color: muted)),
    );
  }

  List<Widget> _tags(BuildContext context, _Entry entry) {
    return [
      for (final tag in entry.tags) ...[
        _TagPill(label: tag),
        const SizedBox(width: RuQiSpacing.xs),
      ],
    ];
  }

  Widget _action(BuildContext context, ThemeData theme) {
    final primary = theme.colorScheme.primary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('打开', style: theme.textTheme.labelLarge?.copyWith(color: primary)),
        const SizedBox(width: RuQiSpacing.xxs),
        Icon(Icons.arrow_forward, size: 18, color: primary),
      ],
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

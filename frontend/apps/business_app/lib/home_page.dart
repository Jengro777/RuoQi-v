import 'package:flutter/material.dart';
import 'package:common/common.dart';

import 'customer/login_page.dart';
import 'merchant/home_page.dart';
import 'partner/home_page.dart';
import 'prototype_dialog.dart';

/// 业务端（App）首页：业务工作台。
///
/// 三个业务域（客户 / 商户 / 伙伴）各自在弹窗内打开原型，
/// 与 PC 端 `business_pc` 共用同一套结构与文案。
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('RuoQi 业务端 App'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: AppBadge(appName: 'business_app', version: '1.0.0'),
            ),
          ),
        ],
        shape: Border(bottom: BorderSide(color: colorScheme.outlineVariant)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          RuQiSpacing.lg,
          RuQiSpacing.lg,
          RuQiSpacing.lg,
          RuQiSpacing.xl,
        ),
        children: [
          const _PageHeader(),
          const SizedBox(height: RuQiSpacing.lg),
          for (var i = 0; i < _entries.length; i++) ...[
            if (i > 0) const SizedBox(height: RuQiSpacing.sm),
            _EntryCard(entry: _entries[i]),
          ],
          const SizedBox(height: RuQiSpacing.xl),
          const _PageFooter(),
        ],
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
            theme.textTheme.headlineMedium!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.sm),
        Text(
          '三个业务域入口：客户（登录）、商户（IDM 租户业务）、伙伴（伙伴移动端）。'
          '入口在弹窗内打开，关闭后回到本页。',
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
      'business_app · 业务端 App 原型 · 端口 51003',
      style: theme.textTheme.bodySmall?.copyWith(color: muted),
    );
  }
}

/// 业务工作台的三个入口。
const _entries = <_Entry>[
  _Entry(
    icon: Icons.account_circle_outlined,
    title: '客户',
    subtitle: '登录',
    modules: '账号密码登录（原型占位）',
    tags: ['客户域'],
    dialogTitle: '客户 App — 登录',
    builder: _customerPrototype,
  ),
  _Entry(
    icon: Icons.fingerprint,
    title: '商户',
    subtitle: 'IDM 租户业务',
    modules: '登录 · 注册 · 个人中心 · 账号安全',
    tags: ['商户域', 'IDM'],
    dialogTitle: '商户 App — IDM 租户业务',
    builder: _merchantPrototype,
  ),
  _Entry(
    icon: Icons.handshake_outlined,
    title: '伙伴',
    subtitle: '伙伴移动端',
    modules: '合作概览（原型占位）',
    tags: ['伙伴域'],
    dialogTitle: '伙伴 App — 伙伴移动端',
    builder: _partnerPrototype,
  ),
];

Widget _customerPrototype() => const LoginPage(embedded: true);
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

/// 入口卡片：图标 + 标题 + 说明 + 页面清单 + 标签，悬停时描边转主色。
class _EntryCard extends StatefulWidget {
  const _EntryCard({required this.entry});

  final _Entry entry;

  @override
  State<_EntryCard> createState() => _EntryCardState();
}

class _EntryCardState extends State<_EntryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final entry = widget.entry;
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        colorScheme.onSurfaceVariant;
    final radius = BorderRadius.circular(RuQiSpacing.sm);
    // 规范 §1.4 色块约束：卡片不铺灰底，底色取最浅的中性表面（亮色 #FFFFFF）。
    final cardColor = theme.brightness == Brightness.dark
        ? colorScheme.surfaceContainerLow
        : colorScheme.surfaceContainerLowest;

    return AnimatedContainer(
      duration: RuQiMotion.resolve(context, RuQiMotion.fast),
      curve: RuQiMotion.easeOut,
      decoration: BoxDecoration(
        color: _pressed ? colorScheme.surfaceContainerLow : cardColor,
        borderRadius: radius,
        border: Border.all(
          color: _pressed ? colorScheme.primary : colorScheme.outlineVariant,
        ),
        boxShadow: RuQiElevation.shadowsFor(theme.brightness, 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: radius,
          onTap: () => PrototypeDialog.show(
            context,
            title: entry.dialogTitle,
            child: entry.builder(),
          ),
          onHighlightChanged: (value) => setState(() => _pressed = value),
          child: Padding(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(RuQiSpacing.sm),
                  ),
                  child: Icon(entry.icon, size: 22, color: colorScheme.primary),
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
                      const SizedBox(height: RuQiSpacing.xxs),
                      Text(
                        entry.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: muted,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: RuQiSpacing.xs),
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
                      const SizedBox(height: RuQiSpacing.sm),
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
              ],
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

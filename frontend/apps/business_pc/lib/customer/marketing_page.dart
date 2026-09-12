import 'package:flutter/material.dart';
import 'package:common/common.dart';

/// RuoQi 客户门户（PC）营销落地页。
///
/// 按 DESIGN-consensus.md 落地：Hero + 社交证明 + 功能卡 + 对比表 +
/// 定价（含优惠码）+ 营销 CTA 横幅（倒计时）+ 页脚 + 吸附 CTA +
/// 浮动弹层。主色仅用于主 CTA、价格高亮、倒计时数字与链接。
class MarketingPage extends StatefulWidget {
  const MarketingPage({super.key, this.embedded = false});

  /// 嵌入业务工作台弹窗时使用：弹窗顶部已有控制台导航栏，
  /// 因此去掉页面自带的营销导航与抽屉，只保留落地页正文。
  final bool embedded;

  @override
  State<MarketingPage> createState() => _MarketingPageState();
}

class _MarketingPageState extends State<MarketingPage> {
  final _scrollController = ScrollController();
  final _heroKey = GlobalKey();
  final _featuresKey = GlobalKey();
  final _comparisonKey = GlobalKey();
  final _pricingKey = GlobalKey();

  late final DateTime _promoEnd = DateTime.now().add(const Duration(hours: 48));

  bool _navCompact = false;
  bool _stickyVisible = false;
  bool _stickyDismissed = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final heroBox = _heroKey.currentContext?.findRenderObject() as RenderBox?;
    final compact =
        heroBox != null && heroBox.localToGlobal(Offset.zero).dy < 0;
    final passed70 =
        _scrollController.position.pixels >=
        _scrollController.position.viewportDimension * 0.7;
    if (compact != _navCompact || passed70 != _stickyVisible) {
      setState(() {
        _navCompact = compact;
        _stickyVisible = passed70;
      });
    }
  }

  void _scrollTo(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: RuQiMotion.slow,
      curve: RuQiMotion.easeOut,
      alignment: 0.08,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: RuQiMotion.slow,
      curve: RuQiMotion.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final showSticky = _stickyVisible && !_stickyDismissed;
    final content = Stack(
      children: [
        Column(
          children: [
            // 嵌入弹窗时由控制台导航栏承担顶部导航，营销导航整条隐藏。
            if (!widget.embedded)
              _MarketingNav(
                compact: _navCompact,
                onLogo: _scrollToTop,
                onFeatures: () => _scrollTo(_featuresKey),
                onComparison: () => _scrollTo(_comparisonKey),
                onPricing: () => _scrollTo(_pricingKey),
                onCta: () => _scrollTo(_pricingKey),
              ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: EdgeInsets.only(bottom: showSticky ? 132 : 48),
                child: Column(
                  children: [
                    _HeroSection(
                      key: _heroKey,
                      onFeatures: () => _scrollTo(_featuresKey),
                      onPricing: () => _scrollTo(_pricingKey),
                    ),
                    const _LogoStrip(),
                    _FeaturesSection(key: _featuresKey),
                    _ComparisonSection(key: _comparisonKey),
                    _PricingSection(key: _pricingKey),
                    _FinalCtaSection(promoEnd: _promoEnd),
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: StickyCta(
            visible: showSticky,
            price: '¥99/月',
            originalPrice: '¥198/月',
            buttonLabel: '立即开始',
            onPressed: () => _scrollTo(_pricingKey),
            onDismissed: () => setState(() => _stickyDismissed = true),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: showSticky ? 104 : 0,
          child: FloatingPromo(
            headline: '首单立减 ¥100',
            body: '新用户专享：订阅任意年度方案立减 ¥100，活动有效期至本月底。',
            ctaLabel: '领取优惠',
            onCtaPressed: () => _scrollTo(_pricingKey),
            scrollController: _scrollController,
            onDismissed: () => setState(() {}),
          ),
        ),
      ],
    );

    if (widget.embedded) {
      // 弹窗内没有 Scaffold，这里补一层 Material：输入框、按钮等
      // Material 组件需要 Material 祖先。
      return Material(
        color: Theme.of(context).colorScheme.surface,
        child: content,
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      endDrawer: _MarketingDrawer(
        onFeatures: () => _scrollTo(_featuresKey),
        onComparison: () => _scrollTo(_comparisonKey),
        onPricing: () => _scrollTo(_pricingKey),
        onCta: () => _scrollTo(_pricingKey),
      ),
      body: content,
    );
  }
}

// ── 导航 ────────────────────────────────────────────────────────

class _MarketingNav extends StatelessWidget {
  const _MarketingNav({
    required this.compact,
    required this.onLogo,
    required this.onFeatures,
    required this.onComparison,
    required this.onPricing,
    required this.onCta,
  });

  final bool compact;
  final VoidCallback onLogo;
  final VoidCallback onFeatures;
  final VoidCallback onComparison;
  final VoidCallback onPricing;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: RuQiMotion.normal,
      curve: RuQiMotion.easeOut,
      height: compact ? 48 : 64,
      color: theme.colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= RuoQiBreakpoints.tablet;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: onLogo,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        foregroundColor: theme.colorScheme.onSurface,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.bolt_rounded,
                            size: 22,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'RuoQi',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (wide) ...[
                      const SizedBox(width: 24),
                      _NavLink('功能', onFeatures),
                      _NavLink('对比', onComparison),
                      _NavLink('定价', onPricing),
                    ],
                    const Spacer(),
                    if (wide) ...[
                      TextButton(
                        onPressed: () {},
                        style: RuQiButtonStyles.tertiary(context),
                        child: const Text('登录'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    FilledButton(
                      onPressed: onCta,
                      style: RuQiButtonStyles.primary(context),
                      child: const Text('免费试用'),
                    ),
                    if (!wide) ...[
                      const SizedBox(width: 4),
                      Builder(
                        builder: (context) => IconButton(
                          tooltip: '菜单',
                          onPressed: () => Scaffold.of(context).openEndDrawer(),
                          icon: Icon(
                            Icons.menu,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  const _NavLink(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        foregroundColor: theme.colorScheme.onSurfaceVariant,
        textStyle: theme.textTheme.titleSmall,
      ),
      child: Text(label),
    );
  }
}

class _MarketingDrawer extends StatelessWidget {
  const _MarketingDrawer({
    required this.onFeatures,
    required this.onComparison,
    required this.onPricing,
    required this.onCta,
  });

  final VoidCallback onFeatures;
  final VoidCallback onComparison;
  final VoidCallback onPricing;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Row(
              children: [
                Icon(Icons.bolt_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'RuoQi',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ListTile(
              title: const Text('功能'),
              onTap: () {
                Navigator.of(context).pop();
                onFeatures();
              },
            ),
            ListTile(
              title: const Text('对比'),
              onTap: () {
                Navigator.of(context).pop();
                onComparison();
              },
            ),
            ListTile(
              title: const Text('定价'),
              onTap: () {
                Navigator.of(context).pop();
                onPricing();
              },
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCta();
              },
              child: const Text('免费试用'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero ────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    super.key,
    required this.onFeatures,
    required this.onPricing,
  });

  final VoidCallback onFeatures;
  final VoidCallback onPricing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    final width = MediaQuery.sizeOf(context).width;
    final displaySize = width >= RuoQiBreakpoints.desktop
        ? 64.0
        : width >= RuoQiBreakpoints.tablet
        ? 44.0
        : width >= RuoQiBreakpoints.mobile
        ? 36.0
        : 32.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [ext.canvasSoft, theme.colorScheme.surface],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: RuQiSpacing.xl,
            ),
            child: Column(
              children: [
                const _TagSoft('新用户专享 · 14 天免费试用'),
                const SizedBox(height: RuQiSpacing.lg),
                Text(
                  '一站式身份与订阅管理平台',
                  textAlign: TextAlign.center,
                  style: zh(
                    theme.textTheme.displayLarge!.copyWith(
                      fontSize: displaySize,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    '为 SaaS 团队提供单点登录、审计日志与灵活计费，'
                    '一次接入即可管理身份、订阅与团队权限。',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(height: RuQiSpacing.xl),
                Wrap(
                  spacing: RuQiSpacing.sm,
                  runSpacing: RuQiSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: onPricing,
                      style: RuQiButtonStyles.primary(context),
                      child: const Text('免费试用 14 天'),
                    ),
                    OutlinedButton(
                      onPressed: onFeatures,
                      style: RuQiButtonStyles.secondary(context),
                      child: const Text('查看功能'),
                    ),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.lg),
                SocialProofBar(
                  message: '200+ 团队今天加入',
                  actionLabel: '立即加入',
                  onAction: onPricing,
                  avatars: const [
                    _GradientAvatar(seed: 0xFFFE2C55),
                    _GradientAvatar(seed: 0xFF2563EB),
                    _GradientAvatar(seed: 0xFF10B981),
                    _GradientAvatar(seed: 0xFFF59E0B),
                  ],
                ),
                const SizedBox(height: RuQiSpacing.xl),
                const _ProductScreenshot(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GradientAvatar extends StatelessWidget {
  const _GradientAvatar({required this.seed});

  final int seed;

  @override
  Widget build(BuildContext context) {
    final color = Color(seed);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withValues(alpha: 0.9), color.withValues(alpha: 0.55)],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _TagSoft extends StatelessWidget {
  const _TagSoft(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ProductScreenshot extends StatelessWidget {
  const _ProductScreenshot();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      height: 360,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isDark
            ? Border.all(color: theme.colorScheme.outlineVariant, width: 1)
            : null,
        boxShadow: isDark ? null : RuQiElevation.shadowLg,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [ext.surface4, theme.colorScheme.surfaceContainer]
              : [theme.colorScheme.surfaceContainerHigh, ext.canvasSoft],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.dashboard_customize_outlined,
            size: 56,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            '产品截图（亮 / 暗双变体）',
            style: theme.textTheme.bodySmall?.copyWith(color: ext.inkMuted),
          ),
        ],
      ),
    );
  }
}

// ── Logo 条 ─────────────────────────────────────────────────────

class _LogoStrip extends StatelessWidget {
  const _LogoStrip();

  static const _names = [
    'Acme',
    'Nimbus',
    'Hexlab',
    'Quantia',
    'Fathom',
    'Lumina',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              Text(
                '被 500+ 团队信赖',
                style: theme.textTheme.bodySmall?.copyWith(color: ext.inkMuted),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  for (final name in _names)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 功能 ────────────────────────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection({super.key});

  static const _features = [
    (Icons.shield_outlined, '单点登录', '一次登录，全平台通行；支持 SAML / OIDC 与多因素认证。'),
    (Icons.receipt_long_outlined, '订阅与计费', '灵活订阅、自动续费与透明账单，后台一目了然。'),
    (Icons.fact_check_outlined, '审计日志', '全量操作留痕，满足合规审计与安全追溯。'),
    (Icons.groups_outlined, '团队与角色', '细粒度权限与成员管理，按角色分配只读 / 编辑 / 管理。'),
    (Icons.code_outlined, '开放 API', 'REST API 与 Webhook 开箱即用，快速接入现有工作流。'),
    (Icons.language_outlined, '多语言多时区', '面向全球团队，本地化文案与多时区协作开箱即用。'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            kicker: '功能',
            title: '为增长而设计的完整工具链',
            subtitle: '从身份到计费，覆盖 SaaS 团队最常用的管理场景。',
          ),
          const SizedBox(height: RuQiSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= RuoQiBreakpoints.desktop
                  ? 3
                  : constraints.maxWidth >= RuoQiBreakpoints.tablet
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * RuQiSpacing.md) /
                  columns;
              return Wrap(
                spacing: RuQiSpacing.md,
                runSpacing: RuQiSpacing.md,
                children: [
                  for (final (icon, title, desc) in _features)
                    SizedBox(
                      width: cardWidth,
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(RuQiSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  icon,
                                  size: 22,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: RuQiSpacing.md),
                              Text(
                                title,
                                style: zh(
                                  theme.textTheme.headlineMedium!.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: RuQiSpacing.xs),
                              Text(
                                desc,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── 对比 ────────────────────────────────────────────────────────

class _ComparisonSection extends StatelessWidget {
  const _ComparisonSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surfaceContainerLow,
      child: _SectionShell(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeading(
              kicker: '对比',
              title: '选择适合你的版本',
              subtitle: '专业版覆盖绝大多数团队需求；企业版支持定制部署。',
            ),
            const SizedBox(height: RuQiSpacing.xl),
            const ComparisonTable(
              columns: ['功能', '基础版', '专业版', '企业版'],
              featuredColumn: 2,
              rows: [
                ComparisonRow(
                  feature: '团队成员',
                  cells: [
                    ComparisonCell.text('5 人'),
                    ComparisonCell.text('20 人'),
                    ComparisonCell.text('不限'),
                  ],
                ),
                ComparisonRow(
                  feature: '单点登录（SSO）',
                  cells: [
                    ComparisonCell.missing(),
                    ComparisonCell.check(),
                    ComparisonCell.check(),
                  ],
                ),
                ComparisonRow(
                  feature: '审计日志',
                  cells: [
                    ComparisonCell.missing(),
                    ComparisonCell.check(),
                    ComparisonCell.check(),
                  ],
                ),
                ComparisonRow(
                  feature: 'API 访问',
                  cells: [
                    ComparisonCell.check(),
                    ComparisonCell.check(),
                    ComparisonCell.check(),
                  ],
                ),
                ComparisonRow(
                  feature: '专属支持',
                  cells: [
                    ComparisonCell.missing(),
                    ComparisonCell.missing(),
                    ComparisonCell.check(),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── 定价 ────────────────────────────────────────────────────────

class _PricingSection extends StatefulWidget {
  const _PricingSection({super.key});

  @override
  State<_PricingSection> createState() => _PricingSectionState();
}

class _PricingSectionState extends State<_PricingSection> {
  int _billingIndex = 0;
  bool _annual = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    return _SectionShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(
            kicker: '定价',
            title: '简单透明的定价',
            subtitle: '按需选择，随时升级；年度订阅享 20% 优惠。',
          ),
          const SizedBox(height: RuQiSpacing.lg),
          ToggleButtons(
            isSelected: [_billingIndex == 0, _billingIndex == 1],
            onPressed: (index) {
              setState(() {
                _billingIndex = index;
                _annual = index == 1;
              });
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Text('月度'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Text('年度 -20%'),
              ),
            ],
          ),
          const SizedBox(height: RuQiSpacing.xl),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= RuoQiBreakpoints.desktop
                  ? 3
                  : constraints.maxWidth >= RuoQiBreakpoints.tablet
                  ? 2
                  : 1;
              final cardWidth =
                  (constraints.maxWidth - (columns - 1) * RuQiSpacing.md) /
                  columns;
              final plans = _plans();
              return Wrap(
                spacing: RuQiSpacing.md,
                runSpacing: RuQiSpacing.md,
                children: [
                  for (final plan in plans)
                    SizedBox(width: cardWidth, child: plan),
                ],
              );
            },
          ),
          const SizedBox(height: RuQiSpacing.xl),
          Container(
            padding: const EdgeInsets.all(RuQiSpacing.lg),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '有优惠码？',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: RuQiSpacing.sm),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: PromoCodeInput(
                    price: _annual ? 79 : 99,
                    onApply: (code) => code.trim().toUpperCase() == 'RQ2026'
                        ? const PromoCodeValid(30)
                        : const PromoCodeInvalid('优惠码无效，请检查后重试'),
                  ),
                ),
                const SizedBox(height: RuQiSpacing.xs),
                Text(
                  '提示：输入 RQ2026 可立减 ¥30（演示）。',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: ext.inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _plans() {
    final primaryMonthly = 99.0;
    final primaryPrice = _annual
        ? (primaryMonthly * 0.8).roundToDouble()
        : primaryMonthly;

    return [
      _PricingCard(
        name: '基础版',
        price: _annual ? 23.2 : 29,
        originalPrice: _annual ? 29 : null,
        features: const ['5 名团队成员', '单点登录', '社区支持'],
        ctaLabel: '免费试用',
        featured: false,
        onCta: () {},
      ),
      _PricingCard(
        name: '专业版',
        price: primaryPrice,
        originalPrice: _annual ? primaryMonthly : null,
        features: const ['20 名团队成员', '单点登录 + MFA', '审计日志', 'API 访问'],
        ctaLabel: '立即开始',
        featured: true,
        onCta: () {},
        savingLabel: _annual ? '年度省 20%' : null,
        socialProof: const SocialProofBar(
          message: '本月已有 1,200+ 团队订阅',
          inline: true,
        ),
      ),
      _PricingCard(
        name: '企业版',
        price: null,
        priceNote: '联系销售',
        features: const ['不限成员', '专属支持', '定制部署'],
        ctaLabel: '联系我们',
        featured: false,
        onCta: () {},
      ),
    ];
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.name,
    required this.price,
    required this.features,
    required this.ctaLabel,
    required this.featured,
    required this.onCta,
    this.originalPrice,
    this.priceNote,
    this.savingLabel,
    this.socialProof,
  });

  final String name;
  final double? price;
  final double? originalPrice;
  final String? priceNote;
  final List<String> features;
  final String ctaLabel;
  final bool featured;
  final String? savingLabel;
  final Widget? socialProof;
  final VoidCallback onCta;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: zh(
                  theme.textTheme.headlineMedium!.copyWith(
                    color: featured ? ext.onDark : theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const Spacer(),
              if (featured)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '推荐',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: RuQiSpacing.md),
          if (price != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '¥${price!.toStringAsFixed(price! % 1 == 0 ? 0 : 1)}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: ext.accentEnergy,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '/月',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: featured ? ext.onDark : ext.inkMuted,
                  ),
                ),
                if (originalPrice != null) ...[
                  const SizedBox(width: RuQiSpacing.xs),
                  Text(
                    '¥${originalPrice!.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext.inkTertiary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ],
            )
          else
            Text(
              priceNote ?? '',
              style: theme.textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          if (savingLabel != null) ...[
            const SizedBox(height: RuQiSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: ext.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                savingLabel!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ext.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
          const SizedBox(height: RuQiSpacing.md),
          for (final feature in features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: featured ? ext.onDark : ext.success,
                  ),
                  const SizedBox(width: RuQiSpacing.xs),
                  Text(
                    feature,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: featured
                          ? ext.onDark
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          if (socialProof != null) ...[
            const SizedBox(height: RuQiSpacing.sm),
            socialProof!,
          ],
          const SizedBox(height: RuQiSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: featured
                ? FilledButton(
                    onPressed: onCta,
                    style: RuQiButtonStyles.inverse(context),
                    child: Text(ctaLabel),
                  )
                : OutlinedButton(
                    onPressed: onCta,
                    style: RuQiButtonStyles.secondary(context),
                    child: Text(ctaLabel),
                  ),
          ),
        ],
      ),
    );

    if (featured) {
      return Container(
        decoration: BoxDecoration(
          color: ext.brandDark,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isDark ? null : RuQiElevation.shadowMd,
        ),
        child: content,
      );
    }
    return Card(margin: EdgeInsets.zero, child: content);
  }
}

// ── 收尾 CTA 横幅 ───────────────────────────────────────────────

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({required this.promoEnd});

  final DateTime promoEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    final width = MediaQuery.sizeOf(context).width;
    final narrow = width < RuoQiBreakpoints.tablet;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        24,
        RuQiSpacing.section,
        24,
        RuQiSpacing.section,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: narrow ? RuQiSpacing.lg : 48,
          vertical: narrow ? 48 : 64,
        ),
        decoration: BoxDecoration(
          color: ext.brandDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Column(
              children: [
                Text(
                  '限时优惠 48 小时',
                  textAlign: TextAlign.center,
                  style: zh(
                    theme.textTheme.headlineLarge!.copyWith(color: ext.onDark),
                  ),
                ),
                const SizedBox(height: RuQiSpacing.md),
                CountdownTimer(
                  endTime: promoEnd,
                  compact: narrow,
                  stacked: narrow,
                  labels: const ['时', '分', '秒'],
                ),
                const SizedBox(height: RuQiSpacing.lg),
                const SocialProofBar(
                  message: '已有 3,000+ 团队选择 RuoQi',
                  inline: true,
                ),
                const SizedBox(height: RuQiSpacing.xl),
                Wrap(
                  spacing: RuQiSpacing.sm,
                  runSpacing: RuQiSpacing.sm,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton(
                      onPressed: () {},
                      style: RuQiButtonStyles.inverse(context),
                      child: const Text('立即开始'),
                    ),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: ext.onDark,
                        side: BorderSide(
                          color: ext.onDark.withValues(alpha: 0.55),
                          width: 1,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        minimumSize: const Size(64, 36),
                      ),
                      child: const Text('联系销售'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 页脚 ────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  static const _groups = [
    ('产品', ['功能', '对比', '定价', '更新日志']),
    ('资源', ['文档', '开发者 API', '社区', '状态']),
    ('公司', ['关于我们', '博客', '招聘', '联系']),
    ('法律', ['隐私政策', '服务条款', '安全', '合规']),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns =
                      constraints.maxWidth >= RuoQiBreakpoints.desktop
                      ? 4
                      : constraints.maxWidth >= RuoQiBreakpoints.tablet
                      ? 2
                      : 1;
                  final groupWidth =
                      (constraints.maxWidth - (columns - 1) * RuQiSpacing.lg) /
                      columns;
                  return Wrap(
                    spacing: RuQiSpacing.lg,
                    runSpacing: RuQiSpacing.xl,
                    children: [
                      for (final (title, links) in _groups)
                        SizedBox(
                          width: groupWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: RuQiSpacing.sm),
                              for (final link in links)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: RuQiSpacing.xs,
                                  ),
                                  child: Text(
                                    link,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: ext.inkMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 48),
              Divider(color: theme.colorScheme.outlineVariant),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '© 2026 RuoQi · 保留所有权利',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ext.inkMuted,
                      ),
                    ),
                  ),
                  Text(
                    '隐私政策 · 服务条款',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: ext.inkMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 区块外壳与标题 ──────────────────────────────────────────────

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1280),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: RuQiSpacing.section,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.kicker,
    required this.title,
    required this.subtitle,
  });

  final String kicker;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ext = ruoQiThemeExt(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          kicker.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(color: ext.inkMuted),
        ),
        const SizedBox(height: RuQiSpacing.xs),
        Text(
          title,
          style: zh(
            theme.textTheme.headlineLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: RuQiSpacing.xs),
        Text(
          subtitle,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

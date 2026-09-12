import 'package:common/common.dart';
import 'package:flutter/material.dart';

import '../../appearance.dart';

/// 主题（平台端个人中心）——业务静态页。
class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('主题')),
      body: const ThemeBody(),
    );
  }
}

/// 主题正文（供个人中心对话框内容区内嵌展示）。
///
/// 版式参考 hopscotch 的主题设置：左列标题 + 说明，右列「背景 / 强调色」
/// 两组设置（组标题 + 当前取值 + 选项）。取值由个人中心外壳注入，
/// 为空时退化为本地预览（不改变应用主题）。
class ThemeBody extends StatefulWidget {
  const ThemeBody({
    super.key,
    this.themeMode,
    this.onThemeModeChanged,
    this.accent,
    this.onAccentChanged,
  });

  /// 当前背景模式；为空取 [ThemeMode.system]。
  final ThemeMode? themeMode;

  /// 切换背景模式；为空时仅在页内预览。
  final ValueChanged<ThemeMode>? onThemeModeChanged;

  /// 当前强调色；为空取规范品牌色。
  final Color? accent;

  /// 切换强调色；为空时仅在页内预览。
  final ValueChanged<Color>? onAccentChanged;

  @override
  State<ThemeBody> createState() => _ThemeBodyState();
}

class _ThemeBodyState extends State<ThemeBody> {
  /// 无外壳注入（独立预览）时的本地取值。
  ThemeMode? _localMode;
  Color? _localAccent;

  ThemeMode get _mode => _localMode ?? widget.themeMode ?? ThemeMode.system;

  Color get _accent => _localAccent ?? widget.accent ?? defaultAccentColor;

  void _selectMode(ThemeMode mode) {
    setState(() => _localMode = mode);
    widget.onThemeModeChanged?.call(mode);
  }

  void _selectAccent(Color color) {
    setState(() => _localAccent = color);
    widget.onAccentChanged?.call(color);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted =
        theme.extension<RuQiThemeExtension>()?.inkMuted ??
        theme.colorScheme.onSurfaceVariant;

    return ListView(
      padding: const EdgeInsets.all(RuQiSpacing.lg),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 左列：页面标题与说明。
            Expanded(
              flex: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '主题',
                    style: zh(
                      theme.textTheme.titleLarge!.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: RuQiSpacing.xs),
                  Text(
                    '自定义您的应用程序主题。',
                    style: theme.textTheme.bodyMedium?.copyWith(color: muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: RuQiSpacing.xxl),
            // 右列：背景 + 强调色。
            Expanded(
              flex: 6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Section(
                    title: '背景',
                    value: backgroundChoices
                        .firstWhere(
                          (choice) => choice.mode == _mode,
                          orElse: () => backgroundChoices.first,
                        )
                        .label,
                    child: Row(
                      children: [
                        for (final choice in backgroundChoices)
                          _BackgroundOption(
                            choice: choice,
                            selected: choice.mode == _mode,
                            onTap: () => _selectMode(choice.mode),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: RuQiSpacing.xl),
                  _Section(
                    title: '强调色',
                    value: _accentLabel,
                    child: Row(
                      children: [
                        for (final choice in accentChoices)
                          _AccentSwatch(
                            choice: choice,
                            selected: choice.color == _accent,
                            onTap: () => _selectAccent(choice.color),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String get _accentLabel {
    for (final choice in accentChoices) {
      if (choice.color == _accent) {
        return choice.label;
      }
    }
    return '自定义';
  }
}

/// 设置分组：标题 + 当前取值 + 选项行。
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.value,
    required this.child,
  });

  final String title;
  final String value;
  final Widget child;

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
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        const SizedBox(height: RuQiSpacing.sm),
        child,
      ],
    );
  }
}

/// 背景模式选项：图标按钮，选中项带 `surfaceContainerHigh` 底色。
class _BackgroundOption extends StatelessWidget {
  const _BackgroundOption({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final BackgroundChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: RuQiSpacing.xxs),
      child: Tooltip(
        message: choice.label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(RuQiSpacing.xs),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.surfaceContainerHigh
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(RuQiSpacing.xs),
              ),
              child: Icon(
                choice.icon,
                size: 20,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 强调色色板：圆环 + 选中项底色。
class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.choice,
    required this.selected,
    required this.onTap,
  });

  final AccentChoice choice;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(right: RuQiSpacing.xxs),
      child: Tooltip(
        message: choice.label,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(RuQiSpacing.xs),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.surfaceContainerHigh
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(RuQiSpacing.xs),
              ),
              // 色板是用户可选的品牌取值，这里按色板原色渲染（非语义角色）。
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: choice.color, width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

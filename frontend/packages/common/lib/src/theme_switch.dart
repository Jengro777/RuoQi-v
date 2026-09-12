import 'package:flutter/material.dart';

/// 顶栏的背景模式切换：与「个人中心 → 主题 → 背景」同一套三档选项。
///
/// 三档对应 `ThemeMode.system / light / dark`，选中项用 `surfaceContainerHigh`
/// 底 + 主色图标，未选中 `onSurfaceVariant`——与主题页的背景选项样式一致。
///
/// 颜色取语义角色而非十六进制：`surfaceContainerHigh` 底、`primary` / `inkMuted`
/// 图标，避免顶栏出现抢眼的大色块。
class RuQiThemeModeSwitch extends StatelessWidget {
  const RuQiThemeModeSwitch({
    super.key,
    required this.themeMode,
    this.onChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onChanged;

  /// 三档选项：模式 / 文案 / 图标（顺序与主题页一致）。
  static const List<(ThemeMode, String, IconData)> options = [
    (ThemeMode.system, '跟随系统', Icons.desktop_windows_outlined),
    (ThemeMode.light, '亮色', Icons.light_mode_outlined),
    (ThemeMode.dark, '暗色', Icons.dark_mode_outlined),
  ];

  /// 单个选项命中区与图标尺寸（顶栏内保持紧凑）。
  static const double _itemSize = 26;
  static const double _iconSize = 15;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final enabled = onChanged != null;

    return Semantics(
      container: true,
      label: '背景模式',
      child: Opacity(
        opacity: enabled ? 1 : 0.38,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (mode, label, icon) in options)
              _ThemeModeOption(
                label: label,
                icon: icon,
                selected: mode == themeMode,
                onTap: enabled ? () => onChanged(mode) : null,
              ),
          ],
        ),
      ),
    );
  }
}

/// 单个背景模式选项：图标按钮，选中项带 `surfaceContainerHigh` 底色。
class _ThemeModeOption extends StatelessWidget {
  const _ThemeModeOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Tooltip(
      message: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: RuQiThemeModeSwitch._itemSize,
            height: RuQiThemeModeSwitch._itemSize,
            decoration: BoxDecoration(
              color: selected
                  ? colorScheme.surfaceContainerHigh
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: RuQiThemeModeSwitch._iconSize,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

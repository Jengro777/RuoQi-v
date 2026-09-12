import 'package:flutter/material.dart';

import 'theme/tokens.dart';

/// 顶栏的深浅色切换：Scalar 文档站 `.cs-toggle` 的胶囊开关样式。
///
/// 几何与行为对齐 Scalar：38 × 24 的开关、12px 高的细胶囊轨道、
/// 23px 圆形滑块压在轨道上（深色时右移 14px），位移 300ms ease-in-out，
/// 滑块内是当前模式的图标（浅色太阳 / 深色月亮）。
///
/// 颜色取语义角色而非十六进制：轨道 `outlineVariant`、滑块 `surface` +
/// `outline` 描边、图标 `onSurface`，避免顶栏出现抢眼的主色填充。
class RuQiThemeModeSwitch extends StatelessWidget {
  const RuQiThemeModeSwitch({
    super.key,
    required this.themeMode,
    this.onChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onChanged;

  /// 开关整体尺寸。
  static const double _width = 38;
  static const double _height = 24;

  /// 细胶囊轨道高度，以及左右各让出的 1px。
  static const double _trackHeight = 12;
  static const double _trackInset = 1;

  /// 滑块直径、深色时的位移（38 − 23）与图标尺寸。
  static const double _knobSize = 23;
  static const double _knobTravel = _width - _knobSize;
  static const double _iconSize = 12;

  /// Scalar 的 `transition: transform 0.3s ease-in-out`。
  static const Duration _slideDuration = Duration(milliseconds: 300);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = themeMode == ThemeMode.dark;
    final onChanged = this.onChanged;
    final enabled = onChanged != null;

    return Tooltip(
      message: '切换暗黑 / 亮色模式',
      child: Semantics(
        button: true,
        enabled: enabled,
        toggled: isDark,
        label: '切换暗黑 / 亮色模式',
        child: Opacity(
          opacity: enabled ? 1 : 0.38,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: enabled
                  ? () => onChanged(isDark ? ThemeMode.light : ThemeMode.dark)
                  : null,
              customBorder: const StadiumBorder(),
              child: SizedBox(
                width: _width,
                height: _height,
                child: Stack(
                  children: [
                    Positioned(
                      left: _trackInset,
                      right: _trackInset,
                      top: (_height - _trackHeight) / 2,
                      height: _trackHeight,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(_trackHeight / 2),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: RuQiMotion.resolve(context, _slideDuration),
                      curve: RuQiMotion.resolveCurve(context, Curves.easeInOut),
                      left: isDark ? _knobTravel : 0,
                      top: (_height - _knobSize) / 2,
                      width: _knobSize,
                      height: _knobSize,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.outline),
                          boxShadow: RuQiElevation.shadowsFor(
                            theme.brightness,
                            1,
                          ),
                        ),
                        child: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          size: _iconSize,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'extension.dart';

/// 规范 §6.1 按钮样式。
///
/// 统一基线：圆角 8、水平 14 / 垂直 8 内边距、`labelLarge`、最小高度 36。
abstract final class RuQiButtonStyles {
  static const _shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
  );

  static const _padding = EdgeInsets.symmetric(horizontal: 14, vertical: 8);

  static const _minimumSize = Size(64, 36);

  /// `button-primary`：`FilledButton` 主按钮。
  static ButtonStyle primary(BuildContext context) {
    final theme = Theme.of(context);
    return primaryOf(
      theme.colorScheme,
      theme.extension<RuQiThemeExtension>(),
      theme.textTheme,
    );
  }

  /// 供 `ThemeData` 默认主题使用的无上下文版本。
  static ButtonStyle primaryOf(
    ColorScheme colors,
    RuQiThemeExtension? ext,
    TextTheme textTheme,
  ) {
    final primaryHover =
        ext?.primaryHover ?? Color.lerp(colors.primary, Colors.black, 0.06)!;
    final primaryPress =
        ext?.primaryPress ?? Color.lerp(colors.primary, Colors.black, 0.14)!;
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      minimumSize: const WidgetStatePropertyAll(_minimumSize),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.surfaceContainerLow;
        }
        if (states.contains(WidgetState.pressed)) return primaryPress;
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return primaryHover;
        }
        // 默认中性填充，不上主色；hover / 聚焦才亮成主色。
        return colors.surfaceContainerHigh;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return ext?.inkTertiary ?? colors.outline;
        }
        final highlighted =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused);
        return highlighted ? colors.onPrimary : colors.onSurface;
      }),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// `button-secondary`：`OutlinedButton` 次按钮。
  static ButtonStyle secondary(BuildContext context) {
    final theme = Theme.of(context);
    return secondaryOf(theme.colorScheme, theme.textTheme);
  }

  static ButtonStyle secondaryOf(ColorScheme colors, TextTheme textTheme) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      minimumSize: const WidgetStatePropertyAll(_minimumSize),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.outline;
        }
        final highlighted =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused);
        // 默认中性文本，hover / 聚焦才切主色。
        return highlighted ? colors.primary : colors.onSurfaceVariant;
      }),
      side: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return BorderSide(color: colors.outlineVariant, width: 1);
        }
        final highlighted =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused);
        return BorderSide(
          color: highlighted ? colors.primary : colors.outline,
          width: 1,
        );
      }),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// `button-link`：表格「操作」列的行内文字动作（编辑 / 查看 / 删除 …）。
  ///
  /// 无描边、无底色、无水波纹：默认 `onSurfaceVariant` 文本，
  /// hover / press 只把文字转 `primary`，不做整块高亮。
  static ButtonStyle link(BuildContext context) {
    final theme = Theme.of(context);
    return linkOf(
      theme.colorScheme,
      theme.extension<RuQiThemeExtension>(),
      theme.textTheme,
    );
  }

  static ButtonStyle linkOf(
    ColorScheme colors,
    RuQiThemeExtension? ext,
    TextTheme textTheme,
  ) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      minimumSize: const WidgetStatePropertyAll(_minimumSize),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      // 连按下 / 悬停的水波纹与底色都去掉，反馈只落在文字颜色上。
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      // 无描边：即使挂在 `OutlinedButton` 上也不会继承主题的主色边框。
      side: const WidgetStatePropertyAll(BorderSide.none),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return ext?.inkTertiary ?? colors.outline;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return colors.primary;
        }
        return colors.onSurfaceVariant;
      }),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// `button-link-danger`：行内破坏性动作（表格「操作」列的删除 / 移除）。
  ///
  /// 与 `button-link` 同款：默认 `onSurfaceVariant` 中性文本，
  /// hover / press / 聚焦才转 `error`。
  static ButtonStyle linkDanger(BuildContext context) {
    final theme = Theme.of(context);
    return linkDangerOf(
      theme.colorScheme,
      theme.extension<RuQiThemeExtension>(),
      theme.textTheme,
    );
  }

  static ButtonStyle linkDangerOf(
    ColorScheme colors,
    RuQiThemeExtension? ext,
    TextTheme textTheme,
  ) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      minimumSize: const WidgetStatePropertyAll(_minimumSize),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      backgroundColor: const WidgetStatePropertyAll(Colors.transparent),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      side: const WidgetStatePropertyAll(BorderSide.none),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return ext?.inkTertiary ?? colors.outline;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused)) {
          return colors.error;
        }
        return colors.onSurfaceVariant;
      }),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// `button-tertiary`：`TextButton` 文字按钮（弹窗取消 / 关闭等）。
  static ButtonStyle tertiary(BuildContext context) {
    final theme = Theme.of(context);
    return tertiaryOf(theme.colorScheme, theme.textTheme);
  }

  static ButtonStyle tertiaryOf(ColorScheme colors, TextTheme textTheme) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      minimumSize: const WidgetStatePropertyAll(_minimumSize),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      foregroundColor: WidgetStatePropertyAll(colors.onSurface),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? colors.surfaceContainer
            : Colors.transparent,
      ),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// `button-inverse`：反色面板（`brandDark` 表面）上的主按钮。
  ///
  /// 恒用亮色 surface 背景 + 亮色 onSurface 文本，保证两种模式下都可读。
  static ButtonStyle inverse(BuildContext context) {
    return inverseOf(Theme.of(context).textTheme);
  }

  static ButtonStyle inverseOf(TextTheme textTheme) {
    const surface = Color(0xFFFFFFFF);
    const onSurface = Color(0xFF0F172A);
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      minimumSize: const WidgetStatePropertyAll(_minimumSize),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFFE8E8E8);
        }
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xFFDCDCDC);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFF5F5F5);
        }
        return surface;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? const Color(0xFF94A3B8)
            : onSurface,
      ),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// `button-danger`：破坏性操作。
  static ButtonStyle danger(BuildContext context) {
    final theme = Theme.of(context);
    return dangerOf(theme.colorScheme, theme.textTheme);
  }

  static ButtonStyle dangerOf(ColorScheme colors, TextTheme textTheme) {
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      minimumSize: const WidgetStatePropertyAll(_minimumSize),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.surfaceContainerLow;
        }
        if (states.contains(WidgetState.pressed)) {
          return Color.lerp(colors.error, Colors.black, 0.18)!;
        }
        if (states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.focused)) {
          return Color.lerp(colors.error, Colors.black, 0.08)!;
        }
        // 默认中性填充，hover / 聚焦才亮成错误色。
        return colors.surfaceContainerHigh;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return colors.outline;
        }
        final highlighted =
            states.contains(WidgetState.hovered) ||
            states.contains(WidgetState.pressed) ||
            states.contains(WidgetState.focused);
        return highlighted ? colors.onPrimary : colors.onSurface;
      }),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// `button-full-width`：小屏（<428px）所有主 CTA 全宽居中。
  static Widget fullWidth(Widget button) {
    return SizedBox(width: double.infinity, child: button);
  }
}

/// 营销页主色稀缺约束下的便捷选择：
/// 同一 band 只允许一个主按钮，其余降级为次按钮。
ButtonStyle ruoQiBandButtonStyle(
  BuildContext context, {
  required bool primary,
}) {
  return primary
      ? RuQiButtonStyles.primary(context)
      : RuQiButtonStyles.secondary(context);
}

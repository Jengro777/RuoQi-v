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
          return colors.surfaceContainerHigh;
        }
        if (states.contains(WidgetState.pressed)) return primaryPress;
        if (states.contains(WidgetState.hovered)) return primaryHover;
        return colors.primary;
      }),
      foregroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return ext?.inkTertiary ?? colors.outline;
        }
        return colors.onPrimary;
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
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.hovered)
            ? colors.primaryContainer
            : Colors.transparent,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colors.outline
            : colors.primary,
      ),
      side: WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled)
              ? colors.outlineVariant
              : colors.primary,
          width: 1,
        ),
      ),
      elevation: const WidgetStatePropertyAll(0),
      surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
    );
  }

  /// `button-tertiary`：`TextButton` 文字按钮。
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
    const surface = Color(0xFFFAFBFC);
    const onSurface = Color(0xFF0F172A);
    return ButtonStyle(
      shape: const WidgetStatePropertyAll(_shape),
      padding: const WidgetStatePropertyAll(_padding),
      minimumSize: const WidgetStatePropertyAll(_minimumSize),
      textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0xFFE2E5EA);
        }
        if (states.contains(WidgetState.pressed)) {
          return const Color(0xFFD8DCE2);
        }
        if (states.contains(WidgetState.hovered)) {
          return const Color(0xFFF0F2F5);
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
          return colors.surfaceContainerHigh;
        }
        if (states.contains(WidgetState.pressed)) {
          return Color.lerp(colors.error, Colors.black, 0.18)!;
        }
        if (states.contains(WidgetState.hovered)) {
          return Color.lerp(colors.error, Colors.black, 0.08)!;
        }
        return colors.error;
      }),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? colors.outline
            : colors.onPrimary,
      ),
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

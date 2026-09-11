import 'package:flutter/material.dart';

import 'theme/ruoqi_buttons.dart';
import 'theme/ruoqi_colors.dart';
import 'theme/ruoqi_extension.dart';
import 'theme/ruoqi_tokens.dart';

/// RuoQi 品牌主色锚点（Douyin 热粉）。
const Color ruoQiBrandColor = Color(0xFFFE2C55);

/// 兼容别名：品牌主色。
@Deprecated('Use ruoQiBrandColor instead.')
const Color ruoQiSeedColor = ruoQiBrandColor;

/// 规范 §9.1 构建 RuoQi 主题。
///
/// 亮色 / 暗色两套取值，营销页通过 `purpose: RuQiPurpose.marketing`
/// 标记；字体族默认 Inter（含 CJK 回退链）。
ThemeData ruoQiTheme({
  Brightness brightness = Brightness.light,
  RuQiPurpose purpose = RuQiPurpose.standard,
  String? fontFamily = 'Inter',
}) {
  final colors = RuQiColors.forMode(brightness, purpose: purpose);
  final isDark = brightness == Brightness.dark;
  final scheme = colors.toColorScheme(brightness);
  final textTheme = _ruoQiTextTheme(brightness);
  final ext = RuQiThemeExtension.fromColors(colors);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    fontFamily: fontFamily,
    fontFamilyFallback: const [
      'PingFang SC',
      'Microsoft YaHei',
      'Noto Sans CJK SC',
      'sans-serif',
    ],
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme,
    extensions: [ext],
    focusColor: scheme.primary.withValues(alpha: 0.5),
    // ── 组件主题 ─────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: RuQiButtonStyles.primaryOf(scheme, ext, textTheme),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: RuQiButtonStyles.secondaryOf(scheme, textTheme),
    ),
    textButtonTheme: TextButtonThemeData(
      style: RuQiButtonStyles.tertiaryOf(scheme, textTheme),
    ),
    inputDecorationTheme: _ruoQiInputDecoration(colors, scheme),
    cardTheme: CardThemeData(
      color: scheme.surfaceContainer,
      elevation: isDark ? 0 : 1,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? BorderSide(color: scheme.outlineVariant, width: 1)
            : BorderSide.none,
      ),
    ),
    chipTheme: _ruoQiChipTheme(scheme),
    dataTableTheme: DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(
        scheme.surfaceContainerHigh,
      ),
      headingTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      dataTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onSurface,
      ),
      dividerThickness: 1,
      horizontalMargin: RuQiSpacing.lg,
      headingRowHeight: 48,
      dataRowMinHeight: 48,
      dataRowMaxHeight: 56,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      // 规范 §6.7：顶部导航文本用 `onSurface`。
      // 颜色必须显式声明——`titleTextStyle` 一旦非空就会整体覆盖 Material 3
      // 由 `foregroundColor` 推导的默认样式；颜色为 null 时文字回退成黑色，
      // 暗色模式下标题（如首页顶栏的「RuoQi-Platform」）就完全看不见了。
      titleTextStyle: textTheme.titleLarge?.copyWith(
        color: scheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
      space: 1,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: textTheme.headlineMedium,
      contentTextStyle: textTheme.bodyMedium,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        color: scheme.onInverseSurface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: scheme.primary,
      linearTrackColor: scheme.primaryContainer,
      circularTrackColor: scheme.primaryContainer,
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      textStyle: textTheme.labelMedium,
      color: colors.inkMuted,
      selectedColor: scheme.onSurface,
      fillColor: scheme.surfaceContainerHigh,
      hoverColor: scheme.surfaceContainerHigh,
      focusColor: scheme.surfaceContainerHigh,
      highlightColor: scheme.surfaceContainerHigh,
      borderColor: scheme.outlineVariant,
      selectedBorderColor: scheme.outlineVariant,
      disabledBorderColor: scheme.outlineVariant,
      borderWidth: 1,
      borderRadius: BorderRadius.circular(999),
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: scheme.primary,
      unselectedLabelColor: colors.inkMuted,
      labelStyle: textTheme.labelLarge,
      unselectedLabelStyle: textTheme.labelMedium,
      indicatorColor: scheme.primary,
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: scheme.primary,
      selectionColor: scheme.primary.withValues(alpha: 0.24),
      selectionHandleColor: scheme.primary,
    ),
    iconTheme: IconThemeData(color: scheme.onSurfaceVariant),
  );
}

InputDecorationTheme _ruoQiInputDecoration(
  RuQiColors colors,
  ColorScheme scheme,
) {
  return InputDecorationTheme(
    filled: true,
    fillColor: colors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    hintStyle: TextStyle(color: colors.inkTertiary),
    labelStyle: TextStyle(color: colors.inkMuted),
    floatingLabelStyle: TextStyle(color: colors.primary),
    helperStyle: const TextStyle(fontSize: 12, height: 1.4),
    errorStyle: const TextStyle(fontSize: 12, height: 1.4),
    prefixIconColor: colors.inkMuted,
    suffixIconColor: colors.inkMuted,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(width: 1, color: colors.hairlineInput),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(width: 1, color: colors.hairlineInput),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(width: 1.5, color: colors.primary),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(width: 1, color: scheme.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(width: 1.5, color: scheme.error),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: BorderSide(width: 1, color: colors.hairlineInput),
    ),
  );
}

ChipThemeData _ruoQiChipTheme(ColorScheme scheme) {
  return ChipThemeData(
    backgroundColor: scheme.surfaceContainerHighest,
    selectedColor: scheme.primaryContainer,
    labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    secondaryLabelStyle: TextStyle(color: scheme.onSurfaceVariant),
    checkmarkColor: scheme.primary,
    side: BorderSide(color: scheme.outlineVariant, width: 1),
    shape: const StadiumBorder(),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    showCheckmark: false,
  );
}

TextTheme _ruoQiTextTheme(Brightness brightness) {
  final display = displayWeightFor(brightness);
  final features = [FontFeature.stylisticSet(1)];

  TextStyle displayStyle(
    double size,
    FontWeight weight,
    double height,
    double spacing,
  ) {
    return TextStyle(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
      fontFeatures: features,
    );
  }

  return TextTheme(
    displayLarge: displayStyle(64, display, 1.05, -2.0),
    displayMedium: displayStyle(48, display, 1.08, -1.4),
    displaySmall: displayStyle(36, display, 1.12, -0.8),
    headlineLarge: displayStyle(28, FontWeight.w600, 1.18, -0.4),
    headlineMedium: displayStyle(22, FontWeight.w600, 1.25, -0.2),
    headlineSmall: displayStyle(18, FontWeight.w400, 1.40, 0),
    titleLarge: displayStyle(18, FontWeight.w400, 1.40, 0),
    titleMedium: displayStyle(16, FontWeight.w400, 1.50, 0),
    titleSmall: displayStyle(14, FontWeight.w400, 1.45, 0),
    bodyLarge: displayStyle(16, FontWeight.w400, 1.50, 0),
    bodyMedium: displayStyle(15, FontWeight.w400, 1.50, 0),
    bodySmall: displayStyle(12, FontWeight.w400, 1.40, 0),
    labelLarge: displayStyle(14, FontWeight.w500, 1.20, 0),
    labelMedium: displayStyle(12, FontWeight.w500, 1.20, 0),
    labelSmall: displayStyle(13, FontWeight.w500, 1.30, 0.3),
  );
}

import 'package:flutter/material.dart';

import 'theme/buttons.dart';
import 'theme/colors.dart';
import 'theme/extension.dart';
import 'theme/tokens.dart';

/// RuoQi 品牌主色锚点（Douyin 热粉）。
const Color ruoQiBrandColor = Color(0xFFFE2C55);

/// 兼容别名：品牌主色。
@Deprecated('Use ruoQiBrandColor instead.')
const Color ruoQiSeedColor = ruoQiBrandColor;

/// 规范 §9.1 构建 RuoQi 主题。
///
/// 亮色 / 暗色两套取值，营销页通过 `purpose: RuQiPurpose.marketing`
/// 标记；字体族默认 Inter（含 CJK 回退链）。
/// `accent` 用于个性化强调色（个人中心 → 主题），为空时取规范品牌色。
ThemeData ruoQiTheme({
  Brightness brightness = Brightness.light,
  RuQiPurpose purpose = RuQiPurpose.standard,
  String? fontFamily = 'Inter',
  Color? accent,
}) {
  final colors = RuQiColors.forMode(
    brightness,
    purpose: purpose,
    accent: accent,
  );
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
    // 焦点高亮（InkWell / 列表行等）：取最浅中性表面，不再整块铺主色；
    // 输入框等控件自身的聚焦描边仍会提示（见 inputDecorationTheme）。
    focusColor: colors.surfaceContainerLow,
    // 悬停高亮与焦点同源（#FAFAFA）：行、菜单项、按钮统一走中性色，
    // 不用主色 / 主色容器做交互反馈。
    hoverColor: colors.surfaceContainerLow,
    // 按下高亮比悬停略深一档，仍是中性灰。
    highlightColor: colors.surfaceContainerHigh,
    // ── 组件主题 ─────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: RuQiButtonStyles.primaryOf(scheme, ext, textTheme),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: RuQiButtonStyles.secondaryOf(scheme, textTheme),
    ),
    textButtonTheme: TextButtonThemeData(
      // 未指定样式的 TextButton 一律按行内文字动作（表格「操作」列等）渲染：
      // 无描边无底色，hover / press 只把文字转主色。
      style: RuQiButtonStyles.linkOf(scheme, ext, textTheme),
    ),
    inputDecorationTheme: _ruoQiInputDecoration(colors, scheme),
    cardTheme: CardThemeData(
      // 规范 §1.4：需要底色时用最浅的中性表面。亮色卡片取白底 + 1px 描边，
      // 不再整块铺灰（大面积色块）；暗色仍靠比页面更亮的表面分层。
      color: isDark
          ? scheme.surfaceContainer
          : scheme.surfaceContainerLowest,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant, width: 1),
      ),
    ),
    chipTheme: _ruoQiChipTheme(scheme),
    // 分段选择（如 权限页「运营 / 管理」）：与 Chip、顶栏背景模式切换同源。
    // M3 默认选中态用 `secondaryContainer`（品牌粉）会与强调色冲突，这里显式接管。
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.surfaceContainerHigh
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return ext.inkTertiary;
          }
          // 选中段文案用主色高亮，未选中取中性灰。
          return states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.onSurfaceVariant;
        }),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return colors.surfaceContainerHigh;
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return colors.surfaceContainerLow;
          }
          return Colors.transparent;
        }),
        side: WidgetStatePropertyAll(
          BorderSide(color: scheme.outlineVariant, width: 1),
        ),
        textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
      ),
    ),
    dataTableTheme: DataTableThemeData(
      // 表头不铺色块：与卡片同色，用 1px 分隔线与字重区分。
      headingRowColor: const WidgetStatePropertyAll(Colors.transparent),
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
      // 选中段用 surfaceContainerHigh；悬停 / 焦点仍是 #FAFAFA 的中性高亮。
      hoverColor: colors.surfaceContainerLow,
      focusColor: colors.surfaceContainerLow,
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
    // 输入框底色取最浅中性表面：亮色 = 卡片白（与底色一致），
    // 聚焦时也不变深，只用描边提示。
    fillColor: colors.surfaceContainerLowest,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    hintStyle: TextStyle(color: colors.inkTertiary),
    labelStyle: TextStyle(color: colors.inkMuted),
    // 浮动标签（有值 / 聚焦时贴在描边上）同样取中性灰，不用主色。
    floatingLabelStyle: TextStyle(color: colors.inkMuted),
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
      // 聚焦沿用默认中性描边色，只把 1px 加粗到 1.5px（不再上主色）。
      borderSide: BorderSide(
        width: 1.5,
        color: colors.hairlineInput,
      ),
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
    // 规范 §1.4：Chip 用最浅表面 + 1px 描边，避免小色块叠色块。
    backgroundColor: scheme.surfaceContainerLowest,
    selectedColor: scheme.primaryContainer,
    labelStyle: TextStyle(color: scheme.onSurfaceVariant),
    secondaryLabelStyle: TextStyle(color: scheme.onSurfaceVariant),
    checkmarkColor: scheme.primary,
    // 线框统一 #FAFAFA 后，Chip 这类小元素改用更强的 `outline` 保持可辨识。
    side: BorderSide(color: scheme.outline, width: 1),
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

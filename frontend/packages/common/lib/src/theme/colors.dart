import 'package:flutter/material.dart';

/// 主题用途：标准业务界面或营销落地页。
///
/// 营销模式会按规范 §1.2 覆盖主色为品牌蓝，`accentEnergy` 保持热粉。
enum RuQiPurpose {
  /// 标准业务界面（管理后台、个人中心、表单等）。
  standard,

  /// 营销落地页（倒计时、社交证明、吸附 CTA、对比表、优惠码等）。
  marketing,
}

/// 规范 §1 颜色角色。
///
/// 每个颜色都以语义角色暴露，组件不直接引用十六进制值；
/// 由 [RuQiColors.forMode] 在运行时按亮色 / 暗色 / 营销模式解析。
@immutable
class RuQiColors {
  const RuQiColors({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outlineVariant,
    required this.outline,
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.scrim,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inversePrimary,
    required this.primaryHover,
    required this.primaryPress,
    required this.primarySubdued,
    required this.accentEnergy,
    required this.surface3,
    required this.surface4,
    required this.hairlineStrong,
    required this.hairlineInput,
    required this.canvasSoft,
    required this.canvasCream,
    required this.brandDark,
    required this.inkMuted,
    required this.inkTertiary,
    required this.onDark,
    required this.success,
    required this.warning,
    required this.info,
  });

  // ── ColorScheme 角色（规范 §1.1）──────────────────────────────

  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;
  final Color secondary;
  final Color onSecondary;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceDim;
  final Color surfaceBright;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outlineVariant;
  final Color outline;
  final Color error;
  final Color onError;
  final Color errorContainer;
  final Color onErrorContainer;
  final Color scrim;
  final Color inverseSurface;
  final Color onInverseSurface;
  final Color inversePrimary;

  // ── RuQiThemeExtension 自定义角色（规范 §1.2）─────────────────

  final Color primaryHover;
  final Color primaryPress;
  final Color primarySubdued;
  final Color accentEnergy;
  final Color surface3;
  final Color surface4;
  final Color hairlineStrong;
  final Color hairlineInput;
  final Color canvasSoft;
  final Color canvasCream;
  final Color brandDark;
  final Color inkMuted;
  final Color inkTertiary;
  final Color onDark;
  final Color success;
  final Color warning;
  final Color info;

  /// 按模式与用途解析整套颜色角色。
  factory RuQiColors.forMode(
    Brightness brightness, {
    RuQiPurpose purpose = RuQiPurpose.standard,
  }) {
    final isDark = brightness == Brightness.dark;
    final isMarketing = purpose == RuQiPurpose.marketing;

    // 规范 §1.2 营销覆盖：亮色主色切换为品牌蓝；暗色提升柔色标签对比。
    final primary = isMarketing && !isDark
        ? const Color(0xFF2563EB)
        : const Color(0xFFFE2C55);
    final primaryHover = isMarketing && !isDark
        ? const Color(0xFF1D4ED8)
        : const Color(0xFFFF4D6A);
    final primaryPress = isMarketing && !isDark
        ? const Color(0xFF1E40AF)
        : const Color(0xFFE01A44);
    final primarySubdued = isDark
        ? (isMarketing ? const Color(0xFF3D1520) : const Color(0xFF2D0D14))
        : (isMarketing ? const Color(0xFFEFF6FF) : const Color(0xFFFFF0F3));
    final hairlineInput = isDark
        ? (isMarketing ? const Color(0xFF4A4E59) : const Color(0xFF3E414A))
        : const Color(0xFFC2C7CF);

    if (isDark) {
      return RuQiColors(
        primary: primary,
        onPrimary: const Color(0xFFFFFFFF),
        primaryContainer: primarySubdued,
        onPrimaryContainer: isMarketing
            ? const Color(0xFFBFDBFE)
            : const Color(0xFFFFB3C2),
        secondary: const Color(0xFFFE2C55),
        onSecondary: const Color(0xFFFFFFFF),
        secondaryContainer: const Color(0xFF2D0D14),
        onSecondaryContainer: const Color(0xFFFFB3C2),
        surface: const Color(0xFF0B0C0F),
        surfaceContainerLowest: const Color(0xFF0B0C0F),
        surfaceContainerLow: const Color(0xFF101215),
        surfaceContainer: const Color(0xFF141518),
        surfaceContainerHigh: const Color(0xFF1C1E23),
        surfaceContainerHighest: const Color(0xFF1C1E23),
        surfaceDim: const Color(0xFF101215),
        surfaceBright: const Color(0xFF0B0C0F),
        onSurface: const Color(0xFFF0F2F5),
        onSurfaceVariant: const Color(0xFFCDD1D8),
        outlineVariant: const Color(0xFF26282F),
        outline: const Color(0xFF353840),
        error: const Color(0xFFF85149),
        onError: const Color(0xFFFFFFFF),
        errorContainer: const Color(0xFF3B1216),
        onErrorContainer: const Color(0xFFFFB3BA),
        scrim: const Color(0xA6000000),
        inverseSurface: const Color(0xFFE5E8EC),
        onInverseSurface: const Color(0xFF1C1E23),
        inversePrimary: const Color(0xFFFE2C55),
        primaryHover: primaryHover,
        primaryPress: primaryPress,
        primarySubdued: primarySubdued,
        accentEnergy: const Color(0xFFFE2C55),
        surface3: const Color(0xFF23252B),
        surface4: const Color(0xFF2A2D34),
        hairlineStrong: const Color(0xFF353840),
        hairlineInput: hairlineInput,
        canvasSoft: const Color(0xFF101215),
        canvasCream: const Color(0xFF1C1A12),
        brandDark: const Color(0xFF0F1030),
        inkMuted: const Color(0xFF8B9098),
        inkTertiary: const Color(0xFF63676E),
        onDark: const Color(0xFFFFFFFF),
        success: const Color(0xFF3FB950),
        warning: const Color(0xFFD29922),
        info: const Color(0xFF58A6FF),
      );
    }

    return RuQiColors(
      primary: primary,
      onPrimary: const Color(0xFFFFFFFF),
      primaryContainer: primarySubdued,
      onPrimaryContainer: isMarketing
          ? const Color(0xFF1E3A8A)
          : const Color(0xFF8C1D32),
      secondary: const Color(0xFFFE2C55),
      onSecondary: const Color(0xFFFFFFFF),
      secondaryContainer: const Color(0xFFFFF0F3),
      onSecondaryContainer: const Color(0xFF8C1D32),
      surface: const Color(0xFFFAFBFC),
      surfaceContainerLowest: const Color(0xFFFAFBFC),
      surfaceContainerLow: const Color(0xFFF0F4F8),
      surfaceContainer: const Color(0xFFF2F4F7),
      surfaceContainerHigh: const Color(0xFFE8EBF0),
      surfaceContainerHighest: const Color(0xFFE8EBF0),
      surfaceDim: const Color(0xFFE2E5EA),
      surfaceBright: const Color(0xFFFAFBFC),
      onSurface: const Color(0xFF0F172A),
      onSurfaceVariant: const Color(0xFF64748B),
      outlineVariant: const Color(0xFFE5E8EC),
      outline: const Color(0xFFD1D6DC),
      error: const Color(0xFFCF222E),
      onError: const Color(0xFFFFFFFF),
      errorContainer: const Color(0xFFFFE3E0),
      onErrorContainer: const Color(0xFF8C1E2A),
      scrim: const Color(0x80000000),
      inverseSurface: const Color(0xFF2F3036),
      onInverseSurface: const Color(0xFFF0F2F5),
      inversePrimary: const Color(0xFFFE2C55),
      primaryHover: primaryHover,
      primaryPress: primaryPress,
      primarySubdued: primarySubdued,
      accentEnergy: const Color(0xFFFE2C55),
      surface3: const Color(0xFFDDE1E7),
      surface4: const Color(0xFFD2D7DF),
      hairlineStrong: const Color(0xFFD1D6DC),
      hairlineInput: hairlineInput,
      canvasSoft: const Color(0xFFF0F4F8),
      canvasCream: const Color(0xFFF8F4EA),
      brandDark: const Color(0xFF111B3D),
      inkMuted: const Color(0xFF94A3B8),
      inkTertiary: const Color(0xFFCBD5E1),
      onDark: const Color(0xFFFFFFFF),
      success: const Color(0xFF1A7F37),
      warning: const Color(0xFF9A6700),
      info: const Color(0xFF0969DA),
    );
  }

  /// 构造规范 §1.1 的 [ColorScheme]（含 §1.2 扩展角色之外的补齐值）。
  ColorScheme toColorScheme(Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: secondary,
      onSecondary: onSecondary,
      secondaryContainer: secondaryContainer,
      onSecondaryContainer: onSecondaryContainer,
      tertiary: primary,
      onTertiary: onPrimary,
      tertiaryContainer: primaryContainer,
      onTertiaryContainer: onPrimaryContainer,
      error: error,
      onError: onError,
      errorContainer: errorContainer,
      onErrorContainer: onErrorContainer,
      surface: surface,
      onSurface: onSurface,
      surfaceDim: surfaceDim,
      surfaceBright: surfaceBright,
      surfaceContainerLowest: surfaceContainerLowest,
      surfaceContainerLow: surfaceContainerLow,
      surfaceContainer: surfaceContainer,
      surfaceContainerHigh: surfaceContainerHigh,
      surfaceContainerHighest: surfaceContainerHighest,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outlineVariant,
      shadow: const Color(0xFF000000),
      scrim: scrim,
      inverseSurface: inverseSurface,
      onInverseSurface: onInverseSurface,
      inversePrimary: inversePrimary,
      surfaceTint: Colors.transparent,
    );
  }
}

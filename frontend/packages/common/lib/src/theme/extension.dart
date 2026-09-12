import 'package:flutter/material.dart';

import 'colors.dart';

/// 规范 §1.2 自定义颜色角色。
///
/// Material 角色覆盖不到的颜色统一放入本扩展，
/// 通过 `Theme.of(context).extension<RuQiThemeExtension>()` 读取。
@immutable
class RuQiThemeExtension extends ThemeExtension<RuQiThemeExtension> {
  const RuQiThemeExtension({
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

  /// 悬停 CTA。
  final Color primaryHover;

  /// 按下 CTA。
  final Color primaryPress;

  /// 柔和标签背景（营销亮色为 `#EFF6FF`）。
  final Color primarySubdued;

  /// 高能强调（营销模式保持热粉）。
  final Color accentEnergy;

  /// 子导航、下拉层。
  final Color surface3;

  /// 最深抬升表面。
  final Color surface4;

  /// 更强描边。
  final Color hairlineStrong;

  /// 表单输入描边。
  final Color hairlineInput;

  /// 柔和交替背景带。
  final Color canvasSoft;

  /// 暖色插曲带。
  final Color canvasCream;

  /// 反色面板背景（推荐定价卡、CTA 横幅）。
  final Color brandDark;

  /// 辅助文本、说明、页脚。
  final Color inkMuted;

  /// 禁用态、脚注。
  final Color inkTertiary;

  /// 反色表面上的文本。
  final Color onDark;

  /// 成功状态。
  final Color success;

  /// 警告状态。
  final Color warning;

  /// 信息状态。
  final Color info;

  factory RuQiThemeExtension.fromColors(RuQiColors colors) {
    return RuQiThemeExtension(
      primaryHover: colors.primaryHover,
      primaryPress: colors.primaryPress,
      primarySubdued: colors.primarySubdued,
      accentEnergy: colors.accentEnergy,
      surface3: colors.surface3,
      surface4: colors.surface4,
      hairlineStrong: colors.hairlineStrong,
      hairlineInput: colors.hairlineInput,
      canvasSoft: colors.canvasSoft,
      canvasCream: colors.canvasCream,
      brandDark: colors.brandDark,
      inkMuted: colors.inkMuted,
      inkTertiary: colors.inkTertiary,
      onDark: colors.onDark,
      success: colors.success,
      warning: colors.warning,
      info: colors.info,
    );
  }

  @override
  RuQiThemeExtension copyWith({
    Color? primaryHover,
    Color? primaryPress,
    Color? primarySubdued,
    Color? accentEnergy,
    Color? surface3,
    Color? surface4,
    Color? hairlineStrong,
    Color? hairlineInput,
    Color? canvasSoft,
    Color? canvasCream,
    Color? brandDark,
    Color? inkMuted,
    Color? inkTertiary,
    Color? onDark,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return RuQiThemeExtension(
      primaryHover: primaryHover ?? this.primaryHover,
      primaryPress: primaryPress ?? this.primaryPress,
      primarySubdued: primarySubdued ?? this.primarySubdued,
      accentEnergy: accentEnergy ?? this.accentEnergy,
      surface3: surface3 ?? this.surface3,
      surface4: surface4 ?? this.surface4,
      hairlineStrong: hairlineStrong ?? this.hairlineStrong,
      hairlineInput: hairlineInput ?? this.hairlineInput,
      canvasSoft: canvasSoft ?? this.canvasSoft,
      canvasCream: canvasCream ?? this.canvasCream,
      brandDark: brandDark ?? this.brandDark,
      inkMuted: inkMuted ?? this.inkMuted,
      inkTertiary: inkTertiary ?? this.inkTertiary,
      onDark: onDark ?? this.onDark,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  RuQiThemeExtension lerp(covariant RuQiThemeExtension? other, double t) {
    if (other == null) return this;
    return RuQiThemeExtension(
      primaryHover: Color.lerp(primaryHover, other.primaryHover, t)!,
      primaryPress: Color.lerp(primaryPress, other.primaryPress, t)!,
      primarySubdued: Color.lerp(primarySubdued, other.primarySubdued, t)!,
      accentEnergy: Color.lerp(accentEnergy, other.accentEnergy, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      surface4: Color.lerp(surface4, other.surface4, t)!,
      hairlineStrong: Color.lerp(hairlineStrong, other.hairlineStrong, t)!,
      hairlineInput: Color.lerp(hairlineInput, other.hairlineInput, t)!,
      canvasSoft: Color.lerp(canvasSoft, other.canvasSoft, t)!,
      canvasCream: Color.lerp(canvasCream, other.canvasCream, t)!,
      brandDark: Color.lerp(brandDark, other.brandDark, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkTertiary: Color.lerp(inkTertiary, other.inkTertiary, t)!,
      onDark: Color.lerp(onDark, other.onDark, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// 读取当前主题的 [RuQiThemeExtension]。
RuQiThemeExtension ruoQiThemeExt(BuildContext context) {
  return Theme.of(context).extension<RuQiThemeExtension>()!;
}

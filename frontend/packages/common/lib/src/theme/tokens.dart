import 'package:flutter/material.dart';

import 'extension.dart';

/// 规范 §3.1 间距令牌（4px 基准）。
abstract final class RuQiSpacing {
  /// 4：精细间隙、图标与文字。
  static const double xxs = 4;

  /// 8：紧凑行内间隙。
  static const double xs = 8;

  /// 12：卡片内容间隙。
  static const double sm = 12;

  /// 16：组件与组件之间。
  static const double md = 16;

  /// 24：区块内间距、卡片内边距。
  static const double lg = 24;

  /// 32：卡片间、引述内边距。
  static const double xl = 32;

  /// 48：CTA 横幅内边距。
  static const double xxl = 48;

  /// 80：区块纵向间距。
  static const double section = 80;

  /// 120：主要区块分隔。
  static const double huge = 120;
}

/// 规范 §4.1 阴影令牌。
///
/// 亮色模式使用阴影；暗色模式阴影一律为空，深度由
/// 「更亮的表面 + 描边」承担。
abstract final class RuQiElevation {
  static const List<BoxShadow> shadowSm = [
    BoxShadow(offset: Offset(0, 1), blurRadius: 3, color: Color(0x0F000000)),
    BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0A000000)),
  ];

  static const List<BoxShadow> shadowMd = [
    BoxShadow(offset: Offset(0, 4), blurRadius: 16, color: Color(0x1A000000)),
    BoxShadow(offset: Offset(0, 2), blurRadius: 4, color: Color(0x0F000000)),
  ];

  static const List<BoxShadow> shadowLg = [
    BoxShadow(offset: Offset(0, 12), blurRadius: 32, color: Color(0x1F000000)),
    BoxShadow(offset: Offset(0, 4), blurRadius: 8, color: Color(0x0F000000)),
  ];

  static const List<BoxShadow> shadowXl = [
    BoxShadow(offset: Offset(0, 24), blurRadius: 48, color: Color(0x26000000)),
    BoxShadow(offset: Offset(0, 8), blurRadius: 16, color: Color(0x14000000)),
  ];

  /// 按深度（0–4）返回亮色阴影；暗色一律为空列表。
  static List<BoxShadow> shadowsFor(Brightness brightness, int depth) {
    if (brightness == Brightness.dark) return const [];
    return switch (depth) {
      0 => const [],
      1 => shadowSm,
      2 => shadowMd,
      3 => shadowLg,
      _ => shadowXl,
    };
  }

  /// 按深度返回描边。
  ///
  /// 亮色仅深度 3+ 需要描边；暗色深度 1 用 `outlineVariant`、
  /// 深度 2+ 用 `hairlineStrong`。
  static BorderSide? borderSideFor(
    Brightness brightness,
    Color outlineVariant,
    RuQiThemeExtension ext,
    int depth,
  ) {
    if (brightness == Brightness.dark) {
      return BorderSide(
        width: 1,
        color: depth <= 1 ? outlineVariant : ext.hairlineStrong,
      );
    }
    if (depth >= 3) {
      return BorderSide(width: 1, color: ext.hairlineStrong);
    }
    return null;
  }
}

/// 规范 §5 动效令牌。
abstract final class RuQiMotion {
  /// 80ms：波纹、开关、勾选。
  static const Duration instant = Duration(milliseconds: 80);

  /// 150ms：悬停、焦点环、气泡。
  static const Duration fast = Duration(milliseconds: 150);

  /// 250ms：弹窗、抽屉、下拉。
  static const Duration normal = Duration(milliseconds: 250);

  /// 400ms：页面转场、首屏淡入、跑马灯。
  static const Duration slow = Duration(milliseconds: 400);

  static const Curve easeDefault = Cubic(0.2, 0, 0, 1);
  static const Curve easeIn = Cubic(0.4, 0, 1, 1);
  static const Curve easeOut = Cubic(0, 0, 0.2, 1);
  static const Curve easeSpring = Cubic(0.34, 1.56, 0.64, 1);
  static const Curve easePulse = Cubic(0.4, 0, 0.2, 1);

  /// 规范 §5.3：系统减少动态时所有动画时长归零。
  static Duration resolve(BuildContext context, Duration duration) {
    return MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
  }

  /// 规范 §5.3：减少动态时 `easeSpring` 退化为线性。
  static Curve resolveCurve(BuildContext context, Curve curve) {
    if (!MediaQuery.disableAnimationsOf(context)) return curve;
    return curve == easeSpring ? Curves.linear : curve;
  }
}

/// 规范 §2.3 自定义文本样式（不进入 TextTheme）。
abstract final class RuQiTextStyles {
  /// 13 / 400 / 1.5：代码、ID、数据令牌。
  static const TextStyle mono = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// 14 / 400 / 1.4 / -0.3 + tabularFigures：金额、数值单元格。
  static const TextStyle tabular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: -0.3,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 36 / 700 / 1.0 / -0.5 + tabularFigures：倒计时数字。
  static const TextStyle countdownDigit = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.0,
    letterSpacing: -0.5,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

/// 规范 §2.4：展示层负字距不应用于中文，统一重置字距为 0。
TextStyle zh(TextStyle style) => style.copyWith(letterSpacing: 0);

/// 规范 §2.5：display 系字重按模式注入；headline 系固定 w600。
FontWeight displayWeightFor(Brightness brightness) {
  return brightness == Brightness.dark ? FontWeight.w600 : FontWeight.w500;
}

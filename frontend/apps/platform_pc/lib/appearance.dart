import 'package:common/common.dart';
import 'package:flutter/material.dart';

/// 平台端外观设置（个人中心 → 主题）的可选项，由 `PlatformApp` 持有当前取值。
///
/// 强调色是用户可选的品牌取值，色板按参考稿排布，允许出现字面色值。
class AccentChoice {
  const AccentChoice(this.label, this.color);

  final String label;
  final Color color;
}

/// 默认强调色：青（与 主题 页默认选中项一致）。
const Color defaultAccentColor = Color(0xFF0D9488);

/// 可选强调色九档；末档是规范品牌色（选它等同于恢复设计规范默认）。
const accentChoices = <AccentChoice>[
  AccentChoice('绿色', Color(0xFF16A34A)),
  AccentChoice('青色', defaultAccentColor),
  AccentChoice('蓝色', Color(0xFF2563EB)),
  AccentChoice('靛蓝', Color(0xFF4F46E5)),
  AccentChoice('紫色', Color(0xFF9333EA)),
  AccentChoice('琥珀', Color(0xFFD97706)),
  AccentChoice('橙色', Color(0xFFEA580C)),
  AccentChoice('红色', Color(0xFFDC2626)),
  AccentChoice('玫红', ruoQiBrandColor),
];

/// 背景模式选项：与 Flutter [ThemeMode] 一一对应。
class BackgroundChoice {
  const BackgroundChoice(this.label, this.icon, this.mode);

  final String label;
  final IconData icon;
  final ThemeMode mode;
}

const backgroundChoices = <BackgroundChoice>[
  BackgroundChoice('跟随系统', Icons.desktop_windows_outlined, ThemeMode.system),
  BackgroundChoice('亮色', Icons.light_mode_outlined, ThemeMode.light),
  BackgroundChoice('暗色', Icons.dark_mode_outlined, ThemeMode.dark),
];

import 'package:flutter/material.dart';
import 'package:common/common.dart';

import 'appearance.dart';
import 'home_page.dart';

void main() {
  runApp(const PlatformApp());
}

class PlatformApp extends StatefulWidget {
  const PlatformApp({super.key});

  @override
  State<PlatformApp> createState() => _PlatformAppState();
}

class _PlatformAppState extends State<PlatformApp> {
  /// 背景模式：默认浅色（与 DESIGN-consensus 的默认模式一致），
  /// 由首页顶栏右上角的三档切换或 个人中心 → 主题 修改。
  ThemeMode _themeMode = ThemeMode.light;

  /// 强调色：默认青色，可由 个人中心 → 主题 更换。
  Color _accent = defaultAccentColor;

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.pc,
      child: MaterialApp(
        title: 'RuoQi 平台',
        debugShowCheckedModeBanner: false,
        // 全站文案可选中复制（规范：原型里的版本号 / 端口 / ID 需要被拷走）。
        builder: ruoQiSelectionBuilder,
        theme: ruoQiTheme(accent: _accent),
        darkTheme: ruoQiTheme(brightness: Brightness.dark, accent: _accent),
        themeMode: _themeMode,
        home: HomePage(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
          accent: _accent,
          onAccentChanged: (accent) => setState(() => _accent = accent),
        ),
      ),
    );
  }
}

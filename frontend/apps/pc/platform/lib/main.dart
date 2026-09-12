import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

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
  /// 深浅色模式：默认浅色（与 DESIGN-consensus 的默认模式一致），
  /// 由首页顶栏右上角的按钮切换。
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.pc,
      child: MaterialApp(
        title: 'RuoQi 平台',
        debugShowCheckedModeBanner: false,
        // 全站文案可选中复制（规范：原型里的版本号 / 端口 / ID 需要被拷走）。
        builder: ruoQiSelectionBuilder,
        theme: ruoQiTheme(),
        darkTheme: ruoQiTheme(brightness: Brightness.dark),
        themeMode: _themeMode,
        home: HomePage(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) => setState(() => _themeMode = mode),
        ),
      ),
    );
  }
}

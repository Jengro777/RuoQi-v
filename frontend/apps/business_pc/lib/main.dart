import 'package:flutter/material.dart';
import 'package:common/common.dart';

import 'home_page.dart';

void main() {
  runApp(const BusinessApp());
}

/// 业务端（PC）：客户 / 商户 / 伙伴三个业务域共用一个应用壳。
///
/// 首页是「业务工作台」，三张入口卡片各自在弹窗内打开对应原型，
/// 版式与交互对齐平台端 `platform_pc`。
class BusinessApp extends StatefulWidget {
  const BusinessApp({super.key});

  @override
  State<BusinessApp> createState() => _BusinessAppState();
}

class _BusinessAppState extends State<BusinessApp> {
  /// 深浅色模式：默认浅色，由工作台顶栏右上角的开关切换。
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.pc,
      child: MaterialApp(
        title: 'RuoQi 业务端',
        debugShowCheckedModeBanner: false,
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

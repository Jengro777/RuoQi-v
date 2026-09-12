import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'home_page.dart';

void main() {
  runApp(const BusinessApp());
}

/// 业务端（App）：客户 / 商户 / 伙伴三个业务域共用一个应用壳。
///
/// 首页是「业务工作台」，三张入口卡片各自在弹窗内打开对应原型，
/// 与 PC 端 `business_pc` 保持同一套结构与版本徽标。
class BusinessApp extends StatelessWidget {
  const BusinessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.mobile,
      child: MaterialApp(
        title: 'RuoQi 业务端 App',
        debugShowCheckedModeBanner: false,
        builder: ruoQiSelectionBuilder,
        theme: ruoQiTheme(),
        darkTheme: ruoQiTheme(brightness: Brightness.dark),
        themeMode: ThemeMode.light,
        home: const HomePage(),
      ),
    );
  }
}

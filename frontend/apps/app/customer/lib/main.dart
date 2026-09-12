import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'login_page.dart';

void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.mobile,
      child: MaterialApp(
        title: 'RuoQi 客户 App',
        debugShowCheckedModeBanner: false,
        builder: ruoQiSelectionBuilder,
        theme: ruoQiTheme(),
        darkTheme: ruoQiTheme(brightness: Brightness.dark),
        themeMode: ThemeMode.light,
        home: const LoginPage(),
      ),
    );
  }
}

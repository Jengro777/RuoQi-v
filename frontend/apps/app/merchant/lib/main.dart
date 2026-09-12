import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'home_page.dart';

void main() {
  runApp(const MerchantApp());
}

class MerchantApp extends StatelessWidget {
  const MerchantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.mobile,
      child: MaterialApp(
        title: 'RuoQi 商户 App',
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

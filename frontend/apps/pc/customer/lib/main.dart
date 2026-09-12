import 'package:flutter/material.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

import 'marketing_page.dart';

void main() {
  runApp(const CustomerApp());
}

class CustomerApp extends StatelessWidget {
  const CustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return RuoQiPlatformScope(
      platform: RuoQiPlatform.pc,
      child: MaterialApp(
        title: 'RuoQi 客户',
        debugShowCheckedModeBanner: false,
        builder: ruoQiSelectionBuilder,
        theme: ruoQiTheme(purpose: RuQiPurpose.marketing),
        darkTheme: ruoQiTheme(
          brightness: Brightness.dark,
          purpose: RuQiPurpose.marketing,
        ),
        themeMode: ThemeMode.light,
        home: const MarketingPage(),
      ),
    );
  }
}

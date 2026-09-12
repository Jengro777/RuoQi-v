import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_pc/merchant/business/app_config_page.dart';
import 'package:ruoqi_business_pc/merchant/business/app_list_page.dart';
import 'package:ruoqi_business_pc/merchant/business/create_app_page.dart';
import 'package:ruoqi_business_pc/merchant/business/create_identity_source_page.dart';
import 'package:ruoqi_business_pc/merchant/business/identity_source_page.dart';
import 'package:ruoqi_business_pc/merchant/business/import_page.dart';
import 'package:ruoqi_business_pc/merchant/business/message_settings_page.dart';

void main() {
  testWidgets('merchant business pages render without exceptions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    final pages = <Widget>[
      const AppListPage(),
      const CreateAppPage(),
      const AppConfigPage(),
      const IdentitySourcePage(),
      const CreateIdentitySourcePage(),
      const MessageSettingsPage(),
      const ImportPage(),
    ];
    for (final page in pages) {
      await tester.pumpWidget(MaterialApp(home: page));
      await tester.pump();
      expect(tester.takeException(), isNull, reason: '$page should render');
    }
    tester.view.reset();
  });
}

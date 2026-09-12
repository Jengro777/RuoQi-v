import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_app/business/system_manage_page.dart';
import 'package:ruoqi_platform_app/main.dart';

void main() {
  testWidgets('platform app home renders prototype pages', (tester) async {
    await tester.pumpWidget(const PlatformApp());
    expect(find.text('RuoQi 平台(App) — 运营端原型页面'), findsOneWidget);
  });

  testWidgets('system manage page renders', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SystemManagePage()));
    expect(find.text('系统管理'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

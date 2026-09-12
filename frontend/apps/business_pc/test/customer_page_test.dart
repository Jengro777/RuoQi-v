import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_business_pc/customer/marketing_page.dart';

Widget _app(Widget home) => MaterialApp(theme: ruoQiTheme(), home: home);

void main() {
  testWidgets('客户 PC 营销落地页渲染', (tester) async {
    await tester.pumpWidget(_app(const MarketingPage()));

    expect(find.text('一站式身份与订阅管理平台'), findsOneWidget);
    expect(find.text('免费试用 14 天'), findsOneWidget);
    expect(find.text('简单透明的定价'), findsOneWidget);
  });

  testWidgets('营销页窄屏自适应且不溢出', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const MarketingPage()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('营销页宽屏渲染', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_app(const MarketingPage()));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('嵌入业务工作台弹窗时隐藏营销导航', (tester) async {
    await tester.pumpWidget(_app(const MarketingPage(embedded: true)));

    // 顶栏由控制台导航栏承担：营销页导航（含「免费试用」按钮）不出现，
    // 但落地页正文（首屏 CTA）仍然完整。
    expect(find.text('免费试用 14 天'), findsOneWidget);
    expect(find.text('免费试用'), findsOneWidget);
  });
}

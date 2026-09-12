import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_app/main.dart';

void main() {
  testWidgets('业务工作台展示三个业务域入口', (tester) async {
    await tester.pumpWidget(const BusinessApp());

    expect(find.text('RuoQi 业务端 App'), findsOneWidget);
    expect(find.text('business_app · v1.0.0'), findsOneWidget);
    for (final title in ['客户', '商户', '伙伴']) {
      expect(find.text(title), findsOneWidget, reason: '应有 $title 入口');
    }
  });

  testWidgets('入口卡片在弹窗内打开对应原型', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('伙伴'));
    await tester.pumpAndSettle();

    expect(find.text('伙伴 App — 伙伴移动端'), findsOneWidget);
    expect(find.text('退出'), findsOneWidget);
    // 工作台仍在弹窗之后
    expect(find.text('业务工作台'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_pc/main.dart';

void main() {
  testWidgets('业务工作台展示三个业务域入口', (tester) async {
    await tester.pumpWidget(const BusinessApp());

    expect(find.text('RuoQi-Business'), findsOneWidget);
    expect(find.text('business_pc · v1.0.0'), findsOneWidget);
    for (final title in ['客户', '商户', '伙伴']) {
      expect(find.text(title), findsOneWidget, reason: '应有 $title 入口');
    }
  });

  testWidgets('入口卡片在弹窗内打开对应原型', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const BusinessApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('伙伴'));
    await tester.pumpAndSettle();

    // 弹窗 = 控制台顶栏（标题 + 退出）+ 原型正文
    expect(find.text('伙伴 PC — 合作伙伴中心'), findsOneWidget);
    expect(find.text('退出'), findsOneWidget);
    // 工作台仍在弹窗之后
    expect(find.text('业务工作台'), findsOneWidget);

    await tester.tap(find.text('退出'));
    await tester.pumpAndSettle();
    expect(find.text('伙伴 PC — 合作伙伴中心'), findsNothing);
    expect(find.text('业务工作台'), findsOneWidget);
  });

  testWidgets('默认浅色，顶栏背景模式切到暗色', (tester) async {
    await tester.pumpWidget(const BusinessApp());

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
    await tester.tap(find.byTooltip('暗色'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
  });
}

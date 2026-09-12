import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/common.dart';
import 'package:ruoqi_business_pc/partner/home_page.dart';

void main() {
  testWidgets('伙伴 PC 原型渲染', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: ruoQiTheme(), home: const PartnerHomePage()),
    );

    expect(find.text('RuoQi 伙伴'), findsOneWidget);
    expect(find.text('合作伙伴中心'), findsOneWidget);
    expect(find.text('partner_pc · v1.0.0'), findsOneWidget);
  });
}

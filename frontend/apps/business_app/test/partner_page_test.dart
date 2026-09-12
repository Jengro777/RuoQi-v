import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_app/partner/home_page.dart';

void main() {
  testWidgets('伙伴 App 原型渲染', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PartnerHomePage()));

    expect(find.text('RuoQi 伙伴 App'), findsOneWidget);
    expect(find.text('伙伴移动端'), findsOneWidget);
    expect(find.text('partner_app · v1.0.0'), findsOneWidget);
  });
}

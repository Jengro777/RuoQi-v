import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_app/main.dart';

void main() {
  testWidgets('Platform app home shows IDM prototype pages', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    expect(find.text('RuoQi 平台(App) — 运营端原型页面'), findsOneWidget);
    expect(find.text('platform_app · v1.0.0'), findsOneWidget);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/common.dart';

Widget _wrap(Widget child, {Size size = const Size(1200, 900)}) {
  return MaterialApp(
    theme: ruoQiTheme(purpose: RuQiPurpose.marketing),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: size.width, height: size.height, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('CountdownTimer 渲染时/分/秒', (tester) async {
    await tester.pumpWidget(
      _wrap(
        CountdownTimer(endTime: DateTime.now().add(const Duration(hours: 2))),
      ),
    );
    expect(find.text('时'), findsOneWidget);
    expect(find.text('分'), findsOneWidget);
    expect(find.text('秒'), findsOneWidget);

    // 卸载以取消周期性 Timer。
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('SocialProofBar 渲染消息、头像栈与动作', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SocialProofBar(
          message: '200+ 人今天加入',
          actionLabel: '立即加入',
          avatars: const [_TestAvatar(), _TestAvatar()],
        ),
      ),
    );
    expect(find.text('200+ 人今天加入'), findsOneWidget);
    expect(find.text('立即加入'), findsOneWidget);
  });

  testWidgets('ComparisonTable 桌面为标准表格', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ComparisonTable(
          columns: ['功能', 'A', 'B'],
          rows: [
            ComparisonRow(
              feature: '特性一',
              cells: [ComparisonCell.check(), ComparisonCell.missing()],
            ),
          ],
        ),
      ),
    );
    expect(find.text('特性一'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('ComparisonTable 移动端堆叠卡片', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ComparisonTable(
          columns: ['功能', 'A', 'B'],
          rows: [
            ComparisonRow(
              feature: '特性一',
              cells: [ComparisonCell.check(), ComparisonCell.missing()],
            ),
          ],
        ),
        size: const Size(360, 800),
      ),
    );
    expect(find.text('特性一'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  testWidgets('PromoCodeInput 应用优惠码后显示优惠行', (tester) async {
    await tester.pumpWidget(
      _wrap(
        PromoCodeInput(
          price: 99,
          onApply: (code) => code == 'SAVE30'
              ? const PromoCodeValid(30)
              : const PromoCodeInvalid('无效'),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'SAVE30');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    expect(find.text('优惠码已应用'), findsOneWidget);
    expect(find.text('优惠 -¥30.00'), findsOneWidget);
    expect(find.text('¥69.00'), findsOneWidget);
    expect(find.text('Remove'), findsOneWidget);
  });

  testWidgets('StickyCta 可见时可关闭', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StickyCta(
          visible: true,
          price: '¥99/月',
          originalPrice: '¥198/月',
          buttonLabel: '立即开始',
          onPressed: () {},
        ),
      ),
    );
    expect(find.text('¥99/月'), findsOneWidget);
    expect(find.text('立即开始'), findsOneWidget);
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    // 关闭后滑出屏幕，不可点击。
    expect(find.text('立即开始').hitTestable(), findsNothing);
  });

  testWidgets('FloatingPromo 停留时长后显示，可关闭', (tester) async {
    await tester.pumpWidget(
      _wrap(
        FloatingPromo(
          headline: '首单立减',
          body: '新用户专享',
          ctaLabel: '领取优惠',
          onCtaPressed: () {},
          autoShowDelay: const Duration(seconds: 2),
        ),
      ),
    );
    AnimatedOpacity opacityOf() =>
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity).first);
    expect(opacityOf().opacity, 0);
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 300));
    expect(opacityOf().opacity, 1);

    await tester.tap(find.byTooltip('关闭'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(opacityOf().opacity, 0);
    await tester.pumpWidget(const SizedBox());
  });
}

class _TestAvatar extends StatelessWidget {
  const _TestAvatar();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(color: Colors.blue);
  }
}

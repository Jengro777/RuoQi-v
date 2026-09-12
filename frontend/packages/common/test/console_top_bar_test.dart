import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 控制台顶栏（规范 §6.7）：品牌 + 标题 + 板块 Tab 在左，
/// 退出按钮固定贴住右上角。
void main() {
  const screen = Size(1440, 900);

  Future<void> pumpTopBar(
    WidgetTester tester, {
    String title = 'XX运营后台',
    List<String> tabs = const [],
  }) async {
    tester.view.physicalSize = screen;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ruoQiTheme(),
        home: Scaffold(
          body: Column(
            children: [
              ConsoleTopBar(
                title: title,
                tabs: tabs,
                sectionIndex: 0,
                onSectionSelected: (_) {},
                onExit: () {},
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );
  }

  /// 退出按钮到窗口右边缘的距离。
  double exitRightGap(WidgetTester tester) {
    final rect = tester.getRect(find.widgetWithText(OutlinedButton, '退出'));
    return screen.width - rect.right;
  }

  testWidgets('无板块 Tab 时退出按钮贴右上角', (tester) async {
    await pumpTopBar(tester);

    final rect = tester.getRect(find.widgetWithText(OutlinedButton, '退出'));
    // 顶栏高 56：按钮上半部分位于顶栏内，即右上角而非顶栏中部。
    expect(rect.top, lessThan(28));
    expect(rect.height, lessThanOrEqualTo(56));
    // 右侧只留顶栏内边距，不再被标题 flex 空档推离右边缘。
    expect(exitRightGap(tester), lessThanOrEqualTo(RuQiSpacing.md + 0.5));
    expect(exitRightGap(tester), greaterThanOrEqualTo(0));
    expect(tester.takeException(), isNull);
  });

  testWidgets('有板块 Tab 时退出按钮贴右上角', (tester) async {
    await pumpTopBar(
      tester,
      title: 'XX管理后台',
      tabs: const ['设置', '用户', '权限', '菜单', '基础', '语言', '日志'],
    );

    expect(
      exitRightGap(tester),
      lessThanOrEqualTo(RuQiSpacing.md + 0.5),
      reason: 'Tab 数量变化不应把退出按钮推离右上角',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('窄屏下标题省略，退出按钮仍在右上角', (tester) async {
    tester.view.physicalSize = const Size(414, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ruoQiTheme(),
        home: Scaffold(
          body: Column(
            children: [
              ConsoleTopBar(
                title: '伙伴 App — 伙伴移动端',
                onExit: () {},
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
    );

    final rect = tester.getRect(find.widgetWithText(OutlinedButton, '退出'));
    expect(414 - rect.right, lessThanOrEqualTo(RuQiSpacing.md + 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('退出按钮为中性描边，默认不使用主色', (tester) async {
    await pumpTopBar(tester);

    final button = tester.widget<OutlinedButton>(
      find.widgetWithText(OutlinedButton, '退出'),
    );
    final style = button.style!;
    expect(
      style.side!.resolve(const <WidgetState>{}),
      const BorderSide(color: Color(0xFFDBDBDB), width: 1),
    );
    expect(
      style.foregroundColor!.resolve(const <WidgetState>{}),
      const Color(0xFF64748B),
    );
  });
}

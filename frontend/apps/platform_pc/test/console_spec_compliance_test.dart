import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/common.dart';
import 'package:ruoqi_platform_pc/admin_pages/system_settings_dialog.dart';
import 'package:ruoqi_platform_pc/ops_pages/operations_console_dialog.dart';

/// 控制台外壳按 DESIGN-consensus.md 规范落地：surface 导航栏、
/// 无紫色原型色、选中菜单项 primaryContainer、内容区 surface。
void main() {
  Future<void> open(
    WidgetTester tester,
    Future<void> Function(BuildContext) show,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ruoQiTheme(),
        home: const Scaffold(body: SizedBox()),
      ),
    );
    show(tester.element(find.byType(SizedBox)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
  }

  Color? containerColor(WidgetTester tester, String label) {
    final containers = find.ancestor(
      of: find.text(label),
      matching: find.byType(Container),
    );
    for (final e in containers.evaluate()) {
      final decoration = (e.widget as Container).decoration;
      if (decoration is BoxDecoration && decoration.color != null) {
        return decoration.color;
      }
    }
    return null;
  }

  testWidgets('管理后台外壳使用规范令牌而非原型紫色', (tester) async {
    await open(tester, (ctx) => SystemSettingsDialog.show(ctx));

    expect(containerColor(tester, '管理后台'), const Color(0xFFFFFFFF));
    // 顶部导航不再是原型紫色（原型内容区可能自带紫色，仅检查外壳区域 y<136）
    final purple = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == const Color(0xFF7172AD),
    );
    var purpleInChrome = false;
    for (final e in purple.evaluate()) {
      final rect = tester.getRect(find.byWidget(e.widget));
      if (rect.top >= 0 && rect.top < 136) {
        purpleInChrome = true;
        break;
      }
    }
    expect(purpleInChrome, isFalse);
    // 选中菜单项使用 primaryContainer
    final selected = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == const Color(0xFFFFF0F3),
    );
    expect(selected, findsWidgets);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('运营后台外壳使用规范令牌而非原型紫色', (tester) async {
    await open(tester, (ctx) => OperationsConsoleDialog.show(ctx));

    expect(containerColor(tester, '运营后台'), const Color(0xFFFFFFFF));
    final purple = find.byWidgetPredicate(
      (w) =>
          w is Container &&
          w.decoration is BoxDecoration &&
          (w.decoration! as BoxDecoration).color == const Color(0xFF7172AD),
    );
    expect(purple, findsNothing);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  /// 打开弹窗后校验退出按钮贴住右上角，再点掉弹窗避免影响后续用例。
  Future<void> expectExitAtTopRight(
    WidgetTester tester,
    Future<void> Function(BuildContext) show,
  ) async {
    await open(tester, show);

    final rect = tester.getRect(find.widgetWithText(OutlinedButton, '退出'));
    expect(
      1600 - rect.right,
      lessThanOrEqualTo(RuQiSpacing.md + 0.5),
      reason: '退出按钮应贴住窗口右上角，而不是被标题的 flex 空档顶离右边缘',
    );
    expect(rect.top, lessThan(28), reason: '退出按钮应落在顶栏（高 56）上半区');
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('退出'));
    await tester.pumpAndSettle();
  }

  testWidgets('管理后台退出按钮贴右上角', (tester) async {
    await expectExitAtTopRight(tester, SystemSettingsDialog.show);
    tester.view.reset();
  });

  testWidgets('运营后台退出按钮贴右上角', (tester) async {
    await expectExitAtTopRight(tester, OperationsConsoleDialog.show);
    tester.view.reset();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
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

    expect(containerColor(tester, 'XX管理后台'), const Color(0xFFFAFBFC));
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

    expect(containerColor(tester, 'XX运营后台'), const Color(0xFFFAFBFC));
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
}

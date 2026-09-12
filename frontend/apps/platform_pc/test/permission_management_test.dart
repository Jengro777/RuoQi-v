import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/permissions_module/permission_management_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/system_settings_dialog.dart';

void main() {
  Future<void> pumpBody(WidgetTester tester, Widget body) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      MaterialApp(
        theme: ruoQiTheme(),
        home: Scaffold(body: body),
      ),
    );
    await tester.pump();
  }

  testWidgets('权限页渲染角色列表、选项卡与矩阵，支持模块筛选', (tester) async {
    await pumpBody(tester, const PermissionsBody());

    // 标题 / 角色列表 / 系统范围选项卡
    expect(find.text('角色权限'), findsOneWidget);
    expect(find.text('Administrators'), findsOneWidget);
    expect(find.text('All Users'), findsOneWidget);
    expect(find.text('实施专员'), findsOneWidget);
    expect(find.text('运营'), findsWidgets);
    expect(find.text('管理'), findsOneWidget);

    // 表格头与默认 运营 范围模块
    expect(find.text('一级菜单'), findsOneWidget);
    expect(find.text('二级菜单'), findsOneWidget);
    expect(find.text('页面名称'), findsOneWidget);
    expect(find.text('查看'), findsOneWidget);
    expect(find.text('编辑'), findsOneWidget);
    expect(find.text('销售订单'), findsWidgets);
    expect(find.text('商品列表'), findsWidgets);
    expect(find.text('用户列表'), findsNothing);
    expect(tester.takeException(), isNull);

    // 筛选到 订单 模块
    await tester.tap(find.widgetWithText(ChoiceChip, '订单'));
    await tester.pumpAndSettle();
    expect(find.text('销售订单'), findsWidgets);
    expect(find.text('商品列表'), findsNothing);

    // 回到所有权限
    await tester.tap(find.widgetWithText(ChoiceChip, '所有权限'));
    await tester.pumpAndSettle();
    expect(find.text('商品列表'), findsWidgets);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('切换 运营 / 管理 系统范围选项卡', (tester) async {
    await pumpBody(tester, const PermissionsBody());

    expect(find.text('销售订单'), findsWidgets);
    expect(find.text('用户列表'), findsNothing);

    await tester.tap(find.text('管理'));
    await tester.pumpAndSettle();
    expect(find.text('用户列表'), findsWidgets);
    expect(find.text('销售订单'), findsNothing);

    // 管理范围下按模块筛选
    await tester.tap(find.widgetWithText(ChoiceChip, '用户管理'));
    await tester.pumpAndSettle();
    expect(find.text('操作日志'), findsNothing);

    await tester.tap(find.text('运营'));
    await tester.pumpAndSettle();
    expect(find.text('销售订单'), findsWidgets);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('修改权限出现提示，取消可还原', (tester) async {
    await pumpBody(tester, const PermissionsBody());
    expect(find.text('权限被修改'), findsNothing);

    // 取消第一行的 查看
    final viewCheckbox = find.byType(Checkbox).first;
    expect(tester.widget<Checkbox>(viewCheckbox).value, isTrue);
    await tester.tap(viewCheckbox);
    await tester.pumpAndSettle();
    expect(find.text('权限被修改'), findsOneWidget);
    expect(find.text('保存修改'), findsOneWidget);

    // 取消还原
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(find.text('权限被修改'), findsNothing);
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('保存修改：确认弹窗后保存并清除提示', (tester) async {
    await pumpBody(tester, const PermissionsBody());

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(find.text('权限被修改'), findsOneWidget);

    await tester.tap(find.text('保存修改'));
    await tester.pumpAndSettle();
    expect(find.text('保存权限？'), findsOneWidget);
    expect(find.textContaining('将新增 0 个权限，取消 1 个权限'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '是'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('保存权限？'), findsNothing);
    expect(find.text('权限被修改'), findsNothing);
    expect(find.text('已保存 Administrators 的权限'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('系统管理弹窗中 权限 展示业务正文', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    SystemSettingsDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('权限').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('角色权限'), findsOneWidget);
    expect(find.text('一级菜单'), findsOneWidget);
    expect(find.text('Administrators'), findsOneWidget);
    // 通用左菜单已隐藏，角色栏位于最左侧
    expect(find.text('搜索菜单'), findsNothing);
    expect(find.text('保存权限'), findsNothing);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });
}

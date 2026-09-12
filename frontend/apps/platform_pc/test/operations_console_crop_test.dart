import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/ops_pages/operations_console_dialog.dart';

void main() {
  Future<void> openDialog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    OperationsConsoleDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
  }

  // 判断文本是否绘制在可见页面区域（原型预览的 FittedBox 内）。
  bool inVisiblePage(WidgetTester tester, String label) {
    final fittedBoxes = find.byType(FittedBox).hitTestable().evaluate();
    if (fittedBoxes.isEmpty) {
      return false; // 业务静态页没有原型预览
    }
    final fittedBox = fittedBoxes.first.renderObject! as RenderBox;
    final pageRect = fittedBox.localToGlobal(Offset.zero) & fittedBox.size;
    for (final e in find.text(label).evaluate()) {
      final box = e.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.overlaps(pageRect.deflate(1))) {
        return true;
      }
    }
    return false;
  }

  testWidgets('动作弹窗中标准布局原型裁掉顶部菜单', (tester) async {
    await openDialog(tester);

    // 二级菜单：查看租户 等动作子页面不再作为菜单项
    expect(find.text('查看租户'), findsNothing);

    // 打开 租户列表 主页面
    await tester.tap(find.text('租户列表').hitTestable().first);
    await tester.pumpAndSettle();
    // 点击 查看 打开动作弹窗（查看租户 原型页）
    await tester.tap(find.text('查看').hitTestable().first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    expect(inVisiblePage(tester, 'IAM Operation Center'), isFalse);
    tester.view.reset();
  });

  testWidgets('动作弹窗中个人中心子页面裁掉 64px 顶栏', (tester) async {
    await openDialog(tester);

    // 展开 个人中心 板块，打开主页
    await tester.tap(find.text('个人中心').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('PC-个人中心(基本信息)').hitTestable().first);
    await tester.pumpAndSettle();
    // 打开 账号安全 动作弹窗
    await tester.tap(find.text('账号安全').hitTestable().first);
    await tester.pumpAndSettle();
    // 打开 修改密码 动作弹窗（原型页）
    await tester.tap(find.text('修改密码').hitTestable().first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // 修改密码 原型裁掉 64px 顶栏后，可见区域宽高比应为 1920 : (1080-64)。
    final fittedBoxes = find.byType(FittedBox).hitTestable().evaluate();
    expect(fittedBoxes, isNotEmpty);
    final fittedBox = fittedBoxes.first.renderObject! as RenderBox;
    final aspect = fittedBox.size.width / fittedBox.size.height;
    expect(aspect, greaterThan(1.85));
    tester.view.reset();
  });

  testWidgets('业务静态页打开不出现原型顶部菜单', (tester) async {
    await openDialog(tester);

    expect(tester.takeException(), isNull);
    expect(inVisiblePage(tester, 'IAM Operation Center'), isFalse);
    expect(inVisiblePage(tester, 'Personal Center'), isFalse);
    tester.view.reset();
  });

  testWidgets('左侧菜单为两级树形，板块可展开/折叠', (tester) async {
    await openDialog(tester);

    // 当前选中页所在板块（租户）默认展开
    expect(find.text('租户列表').hitTestable(), findsWidgets);
    expect(find.text('开户审核').hitTestable(), findsWidgets);

    // 折叠 租户 板块：页面项隐藏
    await tester.tap(find.text('租户').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('租户列表').hitTestable(), findsNothing);
    expect(find.text('开户审核').hitTestable(), findsNothing);

    // 再次点击展开：页面项恢复可见
    await tester.tap(find.text('租户').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('租户列表').hitTestable(), findsWidgets);
    expect(find.text('开户审核').hitTestable(), findsWidgets);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('变更审核的通过/拒绝/查看分别打开对应状态弹窗', (tester) async {
    await openDialog(tester);

    // 展开 项目 板块并打开 变更审核 主页面
    await tester.tap(find.text('项目').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('变更审核').hitTestable().first);
    await tester.pumpAndSettle();

    // 查看 → 审核详情
    await tester.tap(find.text('查看').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('审核结果：'), findsWidgets);
    expect(find.text('原因/说明(必)：'), findsNothing);
    await tester.tap(find.byIcon(Icons.close).hitTestable().first);
    await tester.pumpAndSettle();

    // 通过 → 审核（原因/说明 选填）
    await tester.tap(find.text('通过').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('原因/说明(选)：'), findsWidgets);
    expect(find.text('原因/说明(必)：'), findsNothing);
    // 小弹窗模式：尺寸贴合内容（700×600），内容自带 审核 标题，不再重复标题条
    expect(find.text('审核'), findsNothing);
    expect(find.text('审核\n'), findsWidgets);
    expect(
      find.byWidgetPredicate(
        (w) => w is SizedBox && w.width == 700 && w.height == 600,
      ),
      findsWidgets,
    );
    await tester.tap(find.byIcon(Icons.close).hitTestable().first);
    await tester.pumpAndSettle();

    // 拒绝 → 审核（原因/说明 必填）
    await tester.tap(find.text('拒绝').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('原因/说明(必)：'), findsWidgets);
    expect(find.text('原因/说明(选)：'), findsNothing);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });
}

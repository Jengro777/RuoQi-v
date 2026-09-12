import 'package:common/common.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/personal_pages/personal_console_dialog.dart';
import 'package:ruoqi_platform_pc/personal_pages/personal_sidebar.dart';
import 'package:ruoqi_platform_pc/personal_pages/theme_page/index.dart';
import 'package:ruoqi_platform_pc/main.dart';

/// personal_pages（个人中心）：外壳 = ConsoleTopBar + 左侧菜单 + 内容区。
void main() {
  const screenWidth = 1600.0;

  Future<void> openPersonalCenter(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    PersonalConsoleDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
  }

  Finder inSidebar(String label) => find.descendant(
    of: find.byType(PersonalSidebar),
    matching: find.text(label),
  );

  /// 主题页内的选项（顶栏也有一套同名三档，需限定在页面内）。
  Finder inThemePage(String label) => find.descendant(
    of: find.byType(ThemeBody),
    matching: find.byTooltip(label),
  );

  testWidgets('个人中心：顶栏标题 + 四项左侧菜单 + 默认个人资料', (tester) async {
    await openPersonalCenter(tester);

    expect(find.text('个人中心'), findsOneWidget);
    for (final label in ['个人资料', '账号安全', '多因素认证', '本地化', '主题']) {
      expect(inSidebar(label), findsOneWidget, reason: '左侧菜单应有 $label');
    }

    // 退出按钮仍贴右上角（共用 ConsoleTopBar）。
    final exit = tester.getRect(find.widgetWithText(OutlinedButton, '退出'));
    expect(screenWidth - exit.right, lessThanOrEqualTo(RuQiSpacing.md + 0.5));
    expect(exit.top, lessThan(28));

    // 默认选中 个人资料：内容区在左侧菜单右侧。
    expect(find.text('更换头像'), findsOneWidget);
    expect(tester.getRect(find.text('更换头像')).left, greaterThan(300));
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('左侧菜单逐个切换页面', (tester) async {
    await openPersonalCenter(tester);

    await tester.tap(inSidebar('账号安全'));
    await tester.pumpAndSettle();
    expect(find.text('登录密码'), findsOneWidget);
    expect(find.text('更换头像'), findsNothing);

    await tester.tap(inSidebar('多因素认证'));
    await tester.pumpAndSettle();
    expect(find.text('短信验证码'), findsOneWidget);

    await tester.tap(inSidebar('本地化'));
    await tester.pumpAndSettle();
    expect(find.text('显示设置'), findsOneWidget);

    await tester.tap(inSidebar('个人资料'));
    await tester.pumpAndSettle();
    expect(find.text('更换头像'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('个人资料内的入口直接切页（不叠弹层）', (tester) async {
    await openPersonalCenter(tester);

    // 个人资料正文的「账号安全」入口 → 切到账号安全页
    await tester.tap(find.widgetWithText(ListTile, '账号安全'));
    await tester.pumpAndSettle();
    expect(find.text('登录密码'), findsOneWidget);
    expect(find.text('更换头像'), findsNothing);

    // 账号安全里的「多因素认证 → 开启」→ 切到多因素认证页
    await tester.tap(find.text('开启'));
    await tester.pumpAndSettle();
    expect(find.text('短信验证码'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('主题页：版式与选项（背景 + 强调色）', (tester) async {
    await openPersonalCenter(tester);

    await tester.tap(inSidebar('主题'));
    await tester.pumpAndSettle();

    expect(find.text('自定义您的应用程序主题。'), findsOneWidget);
    expect(find.text('背景'), findsOneWidget);
    expect(find.text('强调色'), findsOneWidget);
    // 外壳未注入外观设置时按「跟随系统」显示，强调色退回默认青色。
    expect(find.text('跟随系统'), findsOneWidget);
    expect(find.text('青色'), findsOneWidget);
    // 三档背景 + 九档强调色。
    for (final label in ['跟随系统', '亮色', '暗色']) {
      expect(find.byTooltip(label), findsOneWidget, reason: '背景应有 $label');
    }
    for (final label in ['绿色', '青色', '蓝色', '靛蓝', '紫色', '琥珀', '橙色', '红色', '玫红']) {
      expect(find.byTooltip(label), findsOneWidget, reason: '强调色应有 $label');
    }
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('主题页切换背景与强调色会应用到整个应用', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PlatformApp());
    await tester.pumpAndSettle();

    // 走真实入口：账号菜单 → 个人资料 → 主题
    await tester.tap(find.byTooltip('账号菜单'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('个人资料'));
    await tester.pumpAndSettle();
    await tester.tap(inSidebar('主题'));
    await tester.pumpAndSettle();

    // 默认强调色 = 青
    const teal = Color(0xFF0D9488);
    expect(find.text('青色'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('强调色'))).colorScheme.primary,
      teal,
    );

    // 背景 → 暗色
    await tester.tap(inThemePage('暗色'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    // 强调色 → 紫色
    await tester.tap(find.byTooltip('紫色'));
    await tester.pumpAndSettle();
    const purple = Color(0xFF9333EA);
    expect(
      Theme.of(tester.element(find.text('强调色'))).colorScheme.primary,
      purple,
    );
    // 当前取值跟随更新（左侧菜单选中态用的是 primaryContainer）。
    expect(find.text('紫色'), findsOneWidget);

    // 切到别的页面再回到主题页，取值仍是刚选的那套。
    await tester.tap(inSidebar('本地化'));
    await tester.pumpAndSettle();
    await tester.tap(inSidebar('主题'));
    await tester.pumpAndSettle();
    expect(find.text('暗色'), findsOneWidget);
    expect(find.text('紫色'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

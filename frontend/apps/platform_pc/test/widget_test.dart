import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/common.dart';
import 'package:ruoqi_platform_pc/main.dart';

/// 当前应用主题模式（顶栏背景模式切换的结果）。
ThemeMode? _themeMode(WidgetTester tester) =>
    tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode;

void main() {
  testWidgets('Platform home shows IDM operator pages', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    expect(find.text('RuoQi-Platform'), findsOneWidget);
    expect(find.text('系统管理'), findsOneWidget);
    expect(find.text('系统全局管理'), findsOneWidget);
    expect(find.text('运营后台'), findsOneWidget);
    expect(find.text('租户管理后台'), findsOneWidget);
    expect(find.text('platform_pc · v1.0.0'), findsOneWidget);

    // 整页文案可选中复制：页头、卡片、页脚都在 SelectionArea 内。
    expect(
      find.ancestor(
        of: find.text('platform_pc · v1.0.0'),
        matching: find.byType(SelectionArea),
      ),
      findsOneWidget,
    );

    // 版本徽标跟在品牌文案右侧同一行，右侧是背景模式切换 + 账号菜单。
    final brand = tester.getCenter(find.text('RuoQi-Platform'));
    final badge = tester.getCenter(find.text('platform_pc · v1.0.0'));
    final switchCenter = tester.getCenter(find.byType(RuQiThemeModeSwitch));
    expect(badge.dx, greaterThan(brand.dx));
    expect((badge.dy - brand.dy).abs(), lessThan(6));
    expect(switchCenter.dx, greaterThan(badge.dx));
    expect(
      tester.getRect(find.byTooltip('账号菜单')).left,
      greaterThan(switchCenter.dx),
      reason: '账号菜单应在背景模式切换右侧',
    );
  });

  testWidgets('顶栏账号菜单：头像在开关右侧，面板贴头像下方', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PlatformApp());
    await tester.pumpAndSettle();

    final avatar = tester.getRect(find.byTooltip('账号菜单'));
    expect(avatar.top, lessThan(56), reason: '头像应落在顶栏内');

    await tester.tap(find.byTooltip('账号菜单'));
    await tester.pumpAndSettle();

    // 面板内容：姓名 + 邮箱 + 菜单项（含快捷键角标）。
    expect(find.text('Jengro'), findsOneWidget);
    expect(find.text('avey777@outlook.com'), findsOneWidget);
    expect(find.text('个人资料'), findsOneWidget);
    expect(find.text('退出'), findsOneWidget);
    expect(find.text('P'), findsOneWidget);
    expect(find.text('L'), findsOneWidget);

    // 面板在头像正下方，右边缘与头像对齐。
    final nameRect = tester.getRect(find.text('Jengro'));
    expect(nameRect.top, greaterThanOrEqualTo(avatar.bottom));
    expect(nameRect.right, lessThanOrEqualTo(avatar.right + 1));

    // 点击面板外关闭。
    await tester.tapAt(const Offset(100, 20));
    await tester.pumpAndSettle();
    expect(find.text('Jengro'), findsNothing);
  });

  testWidgets('账号菜单「个人资料」打开 personal_pages 的个人中心', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PlatformApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('账号菜单'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('个人资料'));
    await tester.pumpAndSettle();

    // 个人中心是独立模块（personal_pages），不再借用运营后台外壳。
    expect(find.text('个人中心'), findsOneWidget);
    expect(find.text('租户列表'), findsNothing);
    // 内容区为个人资料正文（左侧菜单已选中「个人资料」）。
    expect(find.text('更换头像'), findsOneWidget);
    expect(find.text('个人资料'), findsWidgets);
  });

  testWidgets('账号菜单「退出」经二次确认后给出退出反馈', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PlatformApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('账号菜单'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('退出'));
    await tester.pumpAndSettle();

    expect(find.text('退出登录'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, '退出'));
    await tester.pumpAndSettle();

    expect(find.text('已退出登录（原型）'), findsOneWidget);
  });

  testWidgets('账号菜单角标 P 对应个人资料快捷键', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PlatformApp());
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyP);
    await tester.pumpAndSettle();
    expect(find.text('个人中心'), findsOneWidget);
    expect(find.text('更换头像'), findsOneWidget);
  });

  testWidgets('账号菜单角标 L 对应退出快捷键', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const PlatformApp());
    await tester.pumpAndSettle();

    await tester.sendKeyEvent(LogicalKeyboardKey.keyL);
    await tester.pumpAndSettle();
    expect(find.text('退出登录'), findsOneWidget);
  });

  testWidgets('顶栏背景模式切换：跟随系统 / 亮色 / 暗色三档', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    // 与「个人中心 → 主题 → 背景」同一套选项。
    for (final label in ['跟随系统', '亮色', '暗色']) {
      expect(find.byTooltip(label), findsOneWidget, reason: '顶栏应有 $label');
    }
    expect(_themeMode(tester), ThemeMode.light);

    await tester.tap(find.byTooltip('暗色'));
    await tester.pumpAndSettle();
    expect(_themeMode(tester), ThemeMode.dark);

    await tester.tap(find.byTooltip('跟随系统'));
    await tester.pumpAndSettle();
    expect(_themeMode(tester), ThemeMode.system);

    await tester.tap(find.byTooltip('亮色'));
    await tester.pumpAndSettle();
    expect(_themeMode(tester), ThemeMode.light);
  });

  testWidgets('暗色顶栏的品牌文案仍取 onSurface（不退化成黑色）', (tester) async {
    await tester.pumpWidget(const PlatformApp());
    await tester.tap(find.byTooltip('暗色'));
    await tester.pumpAndSettle();

    final titleContext = tester.element(find.text('RuoQi-Platform'));
    // SelectionArea 会给文本套一层 MouseRegion，需下探到 RichText 才能取到段落样式。
    final paragraph = tester.renderObject<RenderParagraph>(
      find.descendant(
        of: find.text('RuoQi-Platform'),
        matching: find.byType(RichText),
      ),
    );
    expect(
      (paragraph.text as TextSpan).style?.color,
      Theme.of(titleContext).colorScheme.onSurface,
    );
  });

  testWidgets('入口卡片仍可点击打开弹窗（SelectionArea 不吞点击）', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(const PlatformApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('运营后台'));
    await tester.pumpAndSettle();
    // 控制台顶栏与首页卡片同名，因此是 2 处；外壳带「退出」。
    expect(find.text('运营后台'), findsNWidgets(2));
    expect(find.text('退出'), findsOneWidget);

    tester.view.reset();
  });
}

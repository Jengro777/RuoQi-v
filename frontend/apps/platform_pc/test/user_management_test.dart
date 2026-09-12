import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_common/ruoqi_common.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/users_module/roles_page/index.dart';
import 'package:ruoqi_platform_pc/admin_pages/users_module/user_management_page/index.dart';
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

  testWidgets('用户业务页渲染表格并支持状态筛选与邀请流程', (tester) async {
    await pumpBody(tester, const UsersBody());

    // 页头、表格与分页
    expect(find.text('邀请用户'), findsOneWidget);
    expect(find.text('名称'), findsOneWidget);
    expect(find.text('最后一次登录'), findsOneWidget);
    expect(find.text('Administrator Me'), findsOneWidget);
    expect(find.text('account2 : sub'), findsOneWidget);
    expect(find.text('m1@163.com'), findsOneWidget);
    expect(find.text('Ti T'), findsOneWidget);
    expect(find.text('10条/页 · 共6条'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 筛选：已停用
    await tester.tap(find.widgetWithText(ChoiceChip, '已停用'));
    await tester.pumpAndSettle();
    expect(find.text('Administrator Me'), findsNothing);
    expect(find.text('Ti T'), findsOneWidget);

    // 恢复所有用户
    await tester.tap(find.widgetWithText(ChoiceChip, '所有用户'));
    await tester.pumpAndSettle();
    expect(find.text('Administrator Me'), findsOneWidget);

    // 邀请用户：面板 -> 提交 -> 邀请令牌结果
    await tester.tap(find.text('邀请用户'));
    await tester.pumpAndSettle();
    final panel = find.byType(SettingsContentPanel);
    expect(
      find.descendant(of: panel, matching: find.text('新用户')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('名字')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('姓氏')),
      findsOneWidget,
    );
    await tester.tap(find.descendant(of: panel, matching: find.text('邀请')));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsContentPanel), findsOneWidget);
    expect(find.textContaining('名字 姓氏 已经被添加'), findsOneWidget);
    expect(find.text('邀请令牌'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('角色列跟随菜单可勾选 / 取消角色', (tester) async {
    await pumpBody(tester, const UsersBody());

    // 初始：普通用户 在 3 行（Administrator / account2 / Li），实施经理 在 1 行
    expect(tester.widgetList(find.text('普通用户')).length, 3);
    expect(tester.widgetList(find.text('实施经理')).length, 1);

    // 点击第一行角色胶囊，打开跟随菜单
    await tester.tap(find.text('管理员'));
    await tester.pumpAndSettle();
    expect(find.text('自定义角色'), findsOneWidget);
    expect(find.byType(CheckboxMenuButton), findsWidgets);

    // 勾选 实施经理、取消 普通用户（菜单保持打开）
    await tester.tap(find.widgetWithText(CheckboxMenuButton, '实施经理'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(CheckboxMenuButton, '普通用户'));
    await tester.pumpAndSettle();

    // 点击空白处关闭菜单
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('自定义角色'), findsNothing);
    expect(tester.widgetList(find.text('普通用户')).length, 2);
    expect(tester.widgetList(find.text('实施经理')).length, 2);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('角色弹窗默认选中默认角色并支持搜索', (tester) async {
    await pumpBody(tester, const UsersBody());

    // 打开第一行角色菜单
    await tester.tap(find.text('管理员'));
    await tester.pumpAndSettle();

    // 默认角色 所有用户：默认选中且不可取消
    final defaultRole = tester.widget<CheckboxMenuButton>(
      find.widgetWithText(CheckboxMenuButton, '所有用户'),
    );
    expect(defaultRole.value, isTrue);
    expect(defaultRole.onChanged, isNull);

    // 搜索过滤自定义角色
    final searchField = find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.hintText == '搜索角色',
    );
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, '运营');
    await tester.pumpAndSettle();
    expect(find.widgetWithText(CheckboxMenuButton, '运营经理'), findsOneWidget);
    expect(find.widgetWithText(CheckboxMenuButton, '运营专员'), findsOneWidget);
    expect(find.widgetWithText(CheckboxMenuButton, '普通用户'), findsNothing);
    expect(find.widgetWithText(CheckboxMenuButton, '实施经理'), findsNothing);
    expect(find.text('无匹配角色'), findsNothing);

    // 无匹配时给出空态
    await tester.enterText(searchField, '不存在的角色');
    await tester.pumpAndSettle();
    expect(find.text('无匹配角色'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 点击空白处关闭菜单
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.byType(CheckboxMenuButton), findsNothing);
    tester.view.reset();
  });

  testWidgets('用户行操作打开编辑面板与停用确认', (tester) async {
    await pumpBody(tester, const UsersBody());

    // 第一行（Administrator）操作菜单 -> 编辑用户
    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑用户').last);
    await tester.pumpAndSettle();
    final panel = find.byType(SettingsContentPanel);
    expect(
      find.descendant(of: panel, matching: find.text('编辑用户')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('账号')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('更新')),
      findsOneWidget,
    );

    // 关闭面板
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsContentPanel), findsNothing);

    // 停用用户 -> 确认对话框 -> 提示
    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('停用用户').last);
    await tester.pumpAndSettle();
    expect(find.text('停用 Administrator Me 的账户？'), findsOneWidget);
    expect(find.text('· 停用账号可以恢复'), findsOneWidget);
    await tester.tap(find.text('停用').last);
    await tester.pumpAndSettle();
    expect(find.text('已停用 Administrator Me'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('编辑用户面板账号旁 tips 按钮可查看字段说明', (tester) async {
    await pumpBody(tester, const UsersBody());

    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('编辑用户').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.info_outline));
    await tester.pumpAndSettle();
    expect(find.text('ID / 账号 / 用户名 说明'), findsOneWidget);
    expect(find.textContaining('组合方式：开发人员自定义'), findsOneWidget);
    expect(find.textContaining('一旦生成不可变化'), findsOneWidget);
    expect(find.textContaining('不支持中文'), findsOneWidget);
    expect(find.textContaining('可以随意变更'), findsOneWidget);

    // 点击空白处关闭
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('ID / 账号 / 用户名 说明'), findsNothing);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('角色业务页渲染并支持创建 / 删除角色组', (tester) async {
    await pumpBody(tester, const RolesBody());

    expect(find.text('创建角色组'), findsOneWidget);
    expect(find.text('管理员'), findsOneWidget);
    expect(find.text('所有用户'), findsOneWidget);
    expect(find.textContaining('特殊的默认组，不能被删除'), findsOneWidget);
    expect(find.text('成员'), findsOneWidget);
    expect(tester.takeException(), isNull);

    // 创建角色组面板
    await tester.tap(find.text('创建角色组'));
    await tester.pumpAndSettle();
    final panel = find.byType(SettingsContentPanel);
    expect(
      find.descendant(of: panel, matching: find.text('创建角色')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: panel, matching: find.text('角色名称')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('关闭'));
    await tester.pumpAndSettle();

    // 默认组不可删除
    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除角色组').last);
    await tester.pumpAndSettle();
    expect(find.text('管理员 是特殊默认组，不能被删除'), findsOneWidget);

    // 非默认组删除确认
    await tester.tap(find.byIcon(Icons.more_horiz).at(2));
    await tester.pumpAndSettle();
    await tester.tap(find.text('删除角色组').last);
    await tester.pumpAndSettle();
    expect(find.text('删除这个角色组？'), findsOneWidget);
    await tester.tap(find.text('是').last);
    await tester.pumpAndSettle();
    expect(find.text('已删除角色组 实施经理'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('角色页设置权限跳转到权限板块', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    SystemSettingsDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('用户').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('角色').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('创建角色组'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_horiz).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('设置权限').last);
    await tester.pumpAndSettle();

    // 已跳转到权限板块：内容为权限业务页
    expect(find.text('保存权限'), findsNothing);
    expect(find.textContaining('角色权限'), findsWidgets);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('系统管理弹窗中 用户/角色 展示业务正文', (tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    SystemSettingsDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('用户').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('邀请用户'), findsOneWidget);
    expect(find.text('名称/账号/邮件/手机号'), findsOneWidget);
    expect(find.text('Administrator Me'), findsOneWidget);

    await tester.tap(find.text('角色').hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.text('创建角色组'), findsOneWidget);
    expect(find.text('管理员'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });
}

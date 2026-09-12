import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/admin_pages/system_settings_dialog.dart';
import 'package:ruoqi_platform_pc/admin_pages/settings_content_dialog.dart';

void main() {
  Future<void> openDialog(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1.0;
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SizedBox())),
    );
    SystemSettingsDialog.show(tester.element(find.byType(SizedBox)));
    await tester.pumpAndSettle();
  }

  // 找到位于顶部导航栏（y < 65）内的指定文本。
  bool inTopBar(WidgetTester tester, String label) {
    for (final e in find.text(label).evaluate()) {
      final box = e.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.top < 65) {
        return true;
      }
    }
    return false;
  }

  // 找到位于左侧导航栏（x < 300 且 y > 顶栏高度 56）内的指定文本。
  bool inSidebar(WidgetTester tester, String label) {
    for (final e in find.text(label).evaluate()) {
      final box = e.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.left < 300 && rect.top > 60) {
        return true;
      }
    }
    return false;
  }

  // 找到位于内容区（左侧菜单 300px 之外）内的指定文本。
  bool inContent(WidgetTester tester, String label) {
    for (final e in find.text(label).evaluate()) {
      final box = e.renderObject! as RenderBox;
      final rect = box.localToGlobal(Offset.zero) & box.size;
      if (rect.left >= 300 && rect.top > 60) {
        return true;
      }
    }
    return false;
  }

  // 在内容区（x≥300）内向下滚动，露出下方内容。
  Future<void> scrollContent(WidgetTester tester, {int times = 1}) async {
    for (var i = 0; i < times; i++) {
      await tester.dragFrom(const Offset(900, 600), const Offset(0, -600));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('系统管理弹窗还原管理后台顶部导航与左侧导航', (tester) async {
    await openDialog(tester);

    // 顶部导航（样式还原自 管理后台 原型）
    expect(inTopBar(tester, '管理后台'), isTrue);
    for (final tab in ['设置', '用户', '权限', '菜单', '基础', '语言', '日志']) {
      expect(inTopBar(tester, tab), isTrue, reason: '顶部 Tab 应有 $tab');
    }
    expect(inTopBar(tester, '退出'), isTrue);
    // 左侧菜单带搜索框（参照 权限 页）
    expect(find.text('搜索菜单'), findsOneWidget);

    // 默认选中 设置：左侧导航为设置板块的子菜单
    for (final item in ['通用', '本地化', '电子邮件', '编码规则', '短信', 'auth登录', '验证消息']) {
      expect(inSidebar(tester, item), isTrue, reason: '设置侧栏应有 $item');
    }
    expect(tester.takeException(), isNull);

    // 切换到 用户：侧栏变为 用户 / 角色
    await tester.tap(find.text('用户').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inSidebar(tester, '用户'), isTrue);
    expect(inSidebar(tester, '角色'), isTrue);
    expect(inSidebar(tester, 'auth登录'), isFalse);

    // 切换到 日志：侧栏变为 4 个日志项
    await tester.tap(find.text('日志').hitTestable().first);
    await tester.pumpAndSettle();
    for (final item in ['验证日志', '操作日志', '登录日志', '支付日志']) {
      expect(inSidebar(tester, item), isTrue, reason: '日志侧栏应有 $item');
    }
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('权限 板块隐藏通用左菜单，角色左侧栏位于最左侧', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('权限').hitTestable().first);
    await tester.pumpAndSettle();
    // 通用左侧菜单隐藏，角色左侧栏占据最左侧
    expect(inSidebar(tester, '权限'), isFalse);
    expect(inSidebar(tester, 'Administrators'), isTrue);
    expect(find.text('一级菜单'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('内容区按页面实际边界裁切，关键元素不被裁掉', (tester) async {
    await openDialog(tester);

    // 短信 页的卡片从画布 x=250 开始，旧固定裁切会切掉左边 10px
    await tester.tap(find.text('短信').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inContent(tester, '阿里云短信'), isTrue);
    expect(tester.takeException(), isNull);

    // 时区 页右上角 编辑 按钮位于 y=138，旧裁切会切掉顶部
    await tester.tap(find.text('基础').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('UTC').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inContent(tester, '编辑'), isTrue);
    expect(tester.takeException(), isNull);

    // 编码规则 页标题从 x=244 开始，旧裁切会切掉左侧
    await tester.tap(find.text('设置').hitTestable().first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('编码规则').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inContent(tester, '编码规则'), isTrue);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('点击左侧导航项切换内容区且不抛异常', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('基础').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inSidebar(tester, '货币'), isTrue);
    await tester.tap(find.text('货币').hitTestable().first);
    await tester.pumpAndSettle();
    expect(inSidebar(tester, '历史汇率'), isTrue);
    await tester.tap(find.text('历史汇率').hitTestable().first);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('长页面按宽度适配显示，不再被整体缩小', (tester) async {
    await openDialog(tester);

    // 本地化 页内容很高（2776px），旧实现会缩到 30% 左右看不清
    await tester.tap(find.text('本地化').hitTestable().first);
    await tester.pumpAndSettle();

    final textFinder = find.text('默认语言');
    expect(textFinder, findsWidgets);
    final box = textFinder.evaluate().first.renderObject! as RenderBox;
    final size = box.size;
    // 内容按宽度适配后字号应接近原始设计尺寸（14px * 缩放），不会被缩成几像素
    expect(size.height, greaterThan(14), reason: '本地化内容不应被缩小');
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('设置-验证消息 展示业务页并可打开设置弹窗', (tester) async {
    await openDialog(tester);

    // 左侧菜单切到 验证消息（业务静态页）
    await tester.tap(find.text('验证消息').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('配置各类验证消息的通知模板与发送渠道。'), findsOneWidget);
    expect(find.text('验证码登录'), findsWidgets);
    expect(find.text('邀请用户'), findsWidgets);

    // 点击第一张卡片的 设置 按钮，打开设置弹窗
    final cardButtons = find.descendant(
      of: find.byType(Card),
      matching: find.text('设置'),
    );
    expect(cardButtons, findsNWidgets(5));
    await tester.tap(cardButtons.first);
    await tester.pumpAndSettle();

    final dialog = find.byType(SettingsContentPanel);
    Finder inDialog(String text) =>
        find.descendant(of: dialog, matching: find.text(text));
    expect(inDialog('电子邮件'), findsOneWidget);
    expect(inDialog('短信'), findsOneWidget);
    expect(inDialog('腾讯云短信'), findsOneWidget);
    expect(inDialog('阿里云短信'), findsOneWidget);
    expect(inDialog('Arkesel'), findsOneWidget);
    expect(inDialog('主题'), findsOneWidget);
    expect(inDialog('发件人'), findsOneWidget);
    expect(inDialog('模板 ID'), findsNWidgets(2));
    expect(
      find.descendant(of: dialog, matching: find.textContaining('场景变量：用户账号')),
      findsOneWidget,
    );
    expect(inDialog('保存修改'), findsOneWidget);
    expect(inDialog('取消'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('邀请用户设置弹窗为纯邮件配置', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('验证消息').hitTestable().first);
    await tester.pumpAndSettle();

    final cardButtons = find.descendant(
      of: find.byType(Card),
      matching: find.text('设置'),
    );
    await tester.tap(cardButtons.last);
    await tester.pumpAndSettle();

    final dialog = find.byType(SettingsContentPanel);
    Finder inDialog(String text) =>
        find.descendant(of: dialog, matching: find.text(text));
    expect(
      find.descendant(of: dialog, matching: find.textContaining('我们邀请您加入')),
      findsOneWidget,
    );
    expect(inDialog('电子邮件'), findsOneWidget);
    expect(inDialog('短信'), findsNothing);
    expect(
      find.descendant(
        of: dialog,
        matching: find.textContaining('邀请链接：\${Invite Link}'),
      ),
      findsOneWidget,
    );
    expect(inDialog('保存修改'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('设置-短信 展示业务页并可打开阿里云配置弹窗', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('短信').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('配置短信服务商与发送渠道。'), findsOneWidget);
    expect(find.text('阿里云短信'), findsWidgets);

    final settingButtons = find.descendant(
      of: find.byType(Card),
      matching: find.text('设置'),
    );
    expect(settingButtons, findsOneWidget);
    await tester.tap(settingButtons.first);
    await tester.pumpAndSettle();

    final dialog = find.byType(SettingsContentPanel);
    // 面板与内容区同尺寸：左侧菜单 300、顶栏 56 之外的部分。
    final rect = tester.getRect(dialog);
    expect(rect.left, 300);
    expect(rect.top, 56);
    expect(rect.width, 1600 - 300);
    expect(rect.height, 1000 - 56);
    Finder inDialog(String text) =>
        find.descendant(of: dialog, matching: find.text(text));
    expect(inDialog('AccessKeyID*'), findsOneWidget);
    expect(inDialog('AccessKeySecret*'), findsOneWidget);
    expect(inDialog('短信签名'), findsOneWidget);
    expect(inDialog('绑定验证'), findsOneWidget);
    expect(inDialog('配置说明：'), findsOneWidget);
    expect(inDialog('跟随运营商'), findsOneWidget);
    expect(inDialog('指定区号'), findsOneWidget);
    expect(inDialog('国际电话区号'), findsNothing);

    // 切换为指定区号
    await tester.tap(inDialog('指定区号'));
    await tester.pumpAndSettle();
    expect(inDialog('国际电话区号'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('设置-auth登录 展示业务页并可打开 Google 配置弹窗', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('auth登录').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('配置第三方账号登录方式。'), findsOneWidget);
    expect(find.text('Google账号登录'), findsWidgets);

    final settingButtons = find.descendant(
      of: find.byType(Card),
      matching: find.text('设置'),
    );
    await tester.tap(settingButtons.first);
    await tester.pumpAndSettle();

    final dialog = find.byType(SettingsContentPanel);
    expect(
      find.descendant(of: dialog, matching: find.text('客户ID')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: dialog,
        matching: find.textContaining('Google 帐户电子邮件地址'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('保存并启用')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('设置-通用 展示业务页', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('通用').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('基础信息'), findsOneWidget);
    expect(find.text('站点名称'), findsOneWidget);
    expect(find.text('网站URL'), findsOneWidget);
    expect(find.text('Favorites Icon'), findsOneWidget);
    expect(find.text('备案信息'), findsOneWidget);

    await scrollContent(tester);
    expect(find.text('保存修改'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('设置-本地化 展示业务页', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('本地化').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('语言与地区'), findsOneWidget);
    expect(find.text('默认语言'), findsOneWidget);

    await scrollContent(tester);
    expect(find.text('货币单位'), findsOneWidget);
    expect(find.text('数字分离器'), findsOneWidget);

    await scrollContent(tester);
    expect(find.text('日期样式'), findsOneWidget);

    await scrollContent(tester);
    expect(find.text('保存修改'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('设置-电子邮件 展示业务页', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('电子邮件').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('SMTP 服务器'), findsOneWidget);
    expect(find.text('SMTP地址'), findsOneWidget);
    expect(find.text('SMTP安全'), findsOneWidget);

    await scrollContent(tester);
    expect(find.text('发件人'), findsWidgets);
    expect(find.text('发送测试邮件'), findsWidgets);
    expect(find.text('保存修改'), findsOneWidget);
    expect(find.text('清除'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });

  testWidgets('设置-编码规则 展示业务页并可编辑规则', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('编码规则').hitTestable().first);
    await tester.pumpAndSettle();

    expect(find.text('系统所有单号生成规则，以及单号前缀。'), findsOneWidget);
    expect(find.text('销售单号'), findsOneWidget);
    // 表格占满内容区宽度（内容区 1300px - 两侧内边距）
    expect(tester.getSize(find.byType(Card).first).width, greaterThan(1200));

    // 打开第一条规则的编辑面板
    await tester.tap(find.text('编辑').hitTestable().first);
    await tester.pumpAndSettle();

    final dialog = find.byType(SettingsContentPanel);
    expect(
      find.descendant(of: dialog, matching: find.text('名称')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('单号前缀')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('生成单号规则')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('保存生效')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('取消')),
      findsOneWidget,
    );
    // 关闭面板后滚动到底部行
    await tester.tap(
      find.descendant(of: dialog, matching: find.byTooltip('关闭')),
    );
    await tester.pumpAndSettle();
    await scrollContent(tester);
    expect(find.text('批次号'), findsOneWidget);
    expect(tester.takeException(), isNull);
    tester.view.reset();
  });
}

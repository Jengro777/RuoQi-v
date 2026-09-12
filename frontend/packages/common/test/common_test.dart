import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/common.dart';

void main() {
  test('ruoQiTheme 亮色模式按规范注入品牌色', () {
    final theme = ruoQiTheme();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, const Color(0xFFFE2C55));
    expect(theme.colorScheme.surface, const Color(0xFFFFFFFF));
    expect(
      theme.extension<RuQiThemeExtension>()!.accentEnergy,
      const Color(0xFFFE2C55),
    );
  });

  test('ruoQiTheme 暗色模式卡片用描边替代阴影', () {
    final theme = ruoQiTheme(brightness: Brightness.dark);
    expect(theme.cardTheme.elevation, 0);
    expect(theme.colorScheme.primary, const Color(0xFFFE2C55));
    expect(theme.extension<RuQiThemeExtension>()!.onDark, Colors.white);
  });

  test('顶部导航标题显式取 onSurface', () {
    // 规范 §6.7：AppBar 文本用 onSurface。颜色一旦缺失，文字会退回黑色，
    // 暗色模式下标题与 surface 背景重合而完全不可见。
    for (final brightness in Brightness.values) {
      final theme = ruoQiTheme(brightness: brightness);
      expect(
        theme.appBarTheme.titleTextStyle?.color,
        theme.colorScheme.onSurface,
        reason: '$brightness 下 AppBar 标题必须显式带颜色',
      );
    }
  });

  test('主题强调色覆盖主色，选回品牌色仍是规范取值', () {
    const teal = Color(0xFF0D9488);
    final custom = ruoQiTheme(accent: teal);
    expect(custom.colorScheme.primary, teal);
    expect(custom.colorScheme.tertiary, teal);
    // 主色容器由强调色派生，不再是规范里的品牌粉浅底。
    expect(custom.colorScheme.primaryContainer, isNot(const Color(0xFFFFF0F3)));
    expect(
      ruoQiTheme(brightness: Brightness.dark, accent: teal).colorScheme.primary,
      teal,
    );

    // 传入品牌默认色 = 未个性化：逐位保持规范取值。
    final brand = ruoQiTheme(accent: ruoQiBrandColor);
    expect(brand.colorScheme.primary, const Color(0xFFFE2C55));
    expect(brand.colorScheme.primaryContainer, const Color(0xFFFFF0F3));
  });

  test('输入框默认白底，聚焦只加粗、不换成主色', () {
    final theme = ruoQiTheme();
    // 亮色：与卡片同色（最浅中性表面）。
    expect(theme.inputDecorationTheme.fillColor, const Color(0xFFFFFFFF));
    final focused =
        theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder;
    expect(focused.borderSide.color, const Color(0xFFC6C6C6));
    expect(focused.borderSide.width, 1.5);
    final enabled =
        theme.inputDecorationTheme.enabledBorder! as OutlineInputBorder;
    expect(enabled.borderSide.color, focused.borderSide.color);
  });

  test('输入框标签与浮动标签取中性灰，不用主色', () {
    final decoration = ruoQiTheme().inputDecorationTheme;
    const inkMuted = Color(0xFF94A3B8);
    expect(decoration.labelStyle?.color, inkMuted);
    expect(decoration.floatingLabelStyle?.color, inkMuted);
  });

  test('交互高亮统一用 #FAFAFA，不用主色', () {
    final theme = ruoQiTheme();
    // 亮色 hover / focus 都是最浅档 #FAFAFA；按下用 surfaceContainerHigh。
    expect(theme.hoverColor, const Color(0xFFFAFAFA));
    expect(theme.focusColor, const Color(0xFFFAFAFA));
    expect(theme.highlightColor, const Color(0xFFEDEDED));
  });

  test('分段选择选中段用中性底色，不继承品牌粉', () {
    final style = ruoQiTheme().segmentedButtonTheme.style!;
    expect(
      style.backgroundColor!.resolve(const {WidgetState.selected}),
      const Color(0xFFEDEDED),
    );
    expect(
      style.backgroundColor!.resolve(const <WidgetState>{}),
      Colors.transparent,
    );
    expect(
      style.foregroundColor!.resolve(const {WidgetState.selected}),
      const Color(0xFFFE2C55),
    );
    expect(
      style.side!.resolve(const <WidgetState>{}),
      const BorderSide(color: Color(0xFFEAEAEA), width: 1),
    );
  });

  test('按钮默认中性，hover / 聚焦才亮主色', () {
    final theme = ruoQiTheme();
    final filled = theme.filledButtonTheme.style!;
    // 默认：中性填充 + 深色文本（不铺主色）。
    expect(
      filled.backgroundColor!.resolve(const <WidgetState>{}),
      const Color(0xFFEDEDED),
    );
    expect(
      filled.foregroundColor!.resolve(const <WidgetState>{}),
      const Color(0xFF0F172A),
    );
    // hover：亮成主色 + onPrimary。
    expect(
      filled.backgroundColor!.resolve(const {WidgetState.hovered}),
      const Color(0xFFFF4D6A),
    );
    expect(
      filled.foregroundColor!.resolve(const {WidgetState.hovered}),
      const Color(0xFFFFFFFF),
    );

    final outlined = theme.outlinedButtonTheme.style!;
    // 默认：中性描边 + 中性文本。
    expect(
      outlined.side!.resolve(const <WidgetState>{}),
      const BorderSide(color: Color(0xFFDBDBDB), width: 1),
    );
    expect(
      outlined.foregroundColor!.resolve(const <WidgetState>{}),
      const Color(0xFF64748B),
    );
    // hover：描边与文字转主色。
    expect(
      outlined.side!.resolve(const {WidgetState.hovered}),
      const BorderSide(color: Color(0xFFFE2C55), width: 1),
    );
    expect(
      outlined.foregroundColor!.resolve(const {WidgetState.hovered}),
      const Color(0xFFFE2C55),
    );
  });

  test('行内删除动作默认中性，hover 才转错误色', () {
    final style = RuQiButtonStyles.linkDangerOf(
      ruoQiTheme().colorScheme,
      ruoQiTheme().extension<RuQiThemeExtension>(),
      ruoQiTheme().textTheme,
    );
    expect(
      style.foregroundColor!.resolve(const <WidgetState>{}),
      const Color(0xFF64748B),
    );
    expect(
      style.foregroundColor!.resolve(const {WidgetState.hovered}),
      const Color(0xFFCF222E),
    );
    expect(style.side!.resolve(const <WidgetState>{}), BorderSide.none);
  });

  test('危险按钮（删除确认）默认中性，hover 才转错误色', () {
    final style = RuQiButtonStyles.dangerOf(
      ruoQiTheme().colorScheme,
      ruoQiTheme().textTheme,
    );
    expect(
      style.backgroundColor!.resolve(const <WidgetState>{}),
      const Color(0xFFEDEDED),
    );
    expect(
      style.foregroundColor!.resolve(const <WidgetState>{}),
      const Color(0xFF0F172A),
    );
    expect(
      style.backgroundColor!.resolve(const {WidgetState.hovered}),
      // hover 亮成错误色（比 error 略深一档，便于与默认中性区分）。
      Color.lerp(const Color(0xFFCF222E), Colors.black, 0.08),
    );
    expect(
      style.foregroundColor!.resolve(const {WidgetState.hovered}),
      const Color(0xFFFFFFFF),
    );
  });

  test('ruoQiTheme 营销模式覆盖主色为品牌蓝', () {
    final theme = ruoQiTheme(purpose: RuQiPurpose.marketing);
    expect(theme.colorScheme.primary, const Color(0xFF2563EB));
    expect(
      theme.extension<RuQiThemeExtension>()!.primarySubdued,
      const Color(0xFFEFF6FF),
    );
    // 高能强调保持热粉
    expect(
      theme.extension<RuQiThemeExtension>()!.accentEnergy,
      const Color(0xFFFE2C55),
    );
  });

  test('display 系字重按模式注入', () {
    final light = ruoQiTheme();
    final dark = ruoQiTheme(brightness: Brightness.dark);
    expect(light.textTheme.displayLarge?.fontWeight, FontWeight.w500);
    expect(dark.textTheme.displayLarge?.fontWeight, FontWeight.w600);
    expect(light.textTheme.headlineLarge?.fontWeight, FontWeight.w600);
  });

  testWidgets('AppBadge renders app name and version', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppBadge(appName: 'platform', version: '1.0.0'),
        ),
      ),
    );
    expect(find.text('platform · v1.0.0'), findsOneWidget);
  });

  testWidgets('ruoQiSelectionBuilder 让全站文案可选中', (tester) async {
    // 作为 MaterialApp.builder 使用时，SelectableRegion 需要祖先里有 Overlay，
    // 这个用例同时守住「自带 Overlay」的实现（缺了会抛 No Overlay widget found）。
    await tester.pumpWidget(
      MaterialApp(
        builder: ruoQiSelectionBuilder,
        home: const Scaffold(body: Text('可复制的文案')),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(SelectionArea), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('可复制的文案'),
        matching: find.byType(SelectionArea),
      ),
      findsOneWidget,
    );
  });

  testWidgets('RuQiThemeModeSwitch 提供 跟随系统 / 亮色 / 暗色 三档', (tester) async {
    final picked = <ThemeMode>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: ruoQiTheme(),
        home: Scaffold(
          body: Center(
            child: RuQiThemeModeSwitch(
              themeMode: ThemeMode.light,
              onChanged: picked.add,
            ),
          ),
        ),
      ),
    );

    for (final label in ['跟随系统', '亮色', '暗色']) {
      expect(find.byTooltip(label), findsOneWidget, reason: '应有 $label 档');
    }
    await tester.tap(find.byTooltip('跟随系统'));
    await tester.tap(find.byTooltip('暗色'));
    expect(picked, [ThemeMode.system, ThemeMode.dark]);
  });
}

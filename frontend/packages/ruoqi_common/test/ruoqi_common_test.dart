import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_common/ruoqi_common.dart';

void main() {
  test('ruoQiTheme 亮色模式按规范注入品牌色', () {
    final theme = ruoQiTheme();
    expect(theme.useMaterial3, isTrue);
    expect(theme.colorScheme.primary, const Color(0xFFFE2C55));
    expect(theme.colorScheme.surface, const Color(0xFFFAFBFC));
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
}

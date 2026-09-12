import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_pc/main.dart';

void main() {
  testWidgets('Platform home shows IDM operator pages', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    expect(find.text('RuoQi-Platform'), findsOneWidget);
    expect(find.text('系统管理'), findsOneWidget);
    expect(find.text('platform_pc · v1.0.0'), findsOneWidget);

    // 整页文案可选中复制：页头、卡片、页脚都在 SelectionArea 内。
    expect(
      find.ancestor(
        of: find.text('platform_pc · v1.0.0'),
        matching: find.byType(SelectionArea),
      ),
      findsOneWidget,
    );

    // 版本徽标跟在品牌文案右侧同一行，右侧只留深浅色开关。
    final brand = tester.getCenter(find.text('RuoQi-Platform'));
    final badge = tester.getCenter(find.text('platform_pc · v1.0.0'));
    final switchCenter = tester.getCenter(
      find.byTooltip('切换暗黑 / 亮色模式'),
    );
    expect(badge.dx, greaterThan(brand.dx));
    expect((badge.dy - brand.dy).abs(), lessThan(6));
    expect(switchCenter.dx, greaterThan(badge.dx));
  });

  testWidgets('Top bar theme switch toggles dark mode', (tester) async {
    await tester.pumpWidget(const PlatformApp());

    // 浅色：滑块停在左侧，滑块内为太阳图标。
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(find.byIcon(Icons.dark_mode), findsNothing);

    await tester.tap(find.byTooltip('切换暗黑 / 亮色模式'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    expect(find.byIcon(Icons.light_mode), findsNothing);

    await tester.tap(find.byTooltip('切换暗黑 / 亮色模式'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.light,
    );
  });

  testWidgets('暗色顶栏的品牌文案仍取 onSurface（不退化成黑色）', (tester) async {
    await tester.pumpWidget(const PlatformApp());
    await tester.tap(find.byTooltip('切换暗黑 / 亮色模式'));
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
    expect(find.text('XX运营后台'), findsOneWidget);

    tester.view.reset();
  });
}

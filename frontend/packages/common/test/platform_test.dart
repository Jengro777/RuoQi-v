import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:common/common.dart';

void main() {
  test('platform inferred from width', () {
    expect(ruoQiPlatformFromSize(const Size(800, 600)), RuoQiPlatform.mobile);
    expect(ruoQiPlatformFromSize(const Size(1280, 720)), RuoQiPlatform.pc);
  });

  testWidgets('RuoQiPlatformScope overrides size inference', (tester) async {
    late RuoQiPlatform read;

    await tester.pumpWidget(
      RuoQiPlatformScope(
        platform: RuoQiPlatform.pc,
        child: Builder(
          builder: (context) {
            read = RuoQiPlatformScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(read, RuoQiPlatform.pc);
  });
}

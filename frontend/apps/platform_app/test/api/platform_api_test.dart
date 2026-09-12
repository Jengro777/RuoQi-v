import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_platform_app/api/platform/models/system_info.dart';

void main() {
  test('SystemInfo roundtrip', () {
    const info = SystemInfo(
      name: 'ruoqi-platform',
      version: '1.0.0',
      status: 'ok',
    );

    final json = info.toJson();
    expect(json['name'], 'ruoqi-platform');

    final parsed = SystemInfo.fromJson(json);
    expect(parsed.version, '1.0.0');
    expect(parsed.status, 'ok');
  });
}

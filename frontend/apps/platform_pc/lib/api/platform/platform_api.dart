import 'package:network/network.dart';

import 'models/system_info.dart';

/// 平台域后端的 API 客户端（platform_pc 专用）。
///
/// 用法：
/// ```dart
/// final client = RuoQiNetworkClient(
///   baseUrl: String.fromEnvironment('PLATFORM_API_BASE_URL', defaultValue: 'https://platform.example.com'),
/// );
/// final api = PlatformApi(client);
/// ```
class PlatformApi {
  const PlatformApi(this._client);

  final RuoQiNetworkClient _client;

  /// 获取平台系统信息。
  Future<SystemInfo> getSystemInfo() async {
    final data = await _client.get('/system/info');
    return SystemInfo.fromJson(data as Map<String, dynamic>);
  }
}

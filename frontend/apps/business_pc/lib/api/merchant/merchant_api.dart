import 'package:network/network.dart';

import 'models/dashboard_summary.dart';

/// 商户域后端的 API 客户端（business_pc 专用）。
///
/// 用法：
/// ```dart
/// final client = RuoQiNetworkClient(
///   baseUrl: String.fromEnvironment('MERCHANT_API_BASE_URL', defaultValue: 'https://merchant.example.com'),
/// );
/// final api = MerchantApi(client);
/// ```
class MerchantApi {
  const MerchantApi(this._client);

  final RuoQiNetworkClient _client;

  /// 获取商户首页数据概览。
  Future<DashboardSummary> getDashboard() async {
    final data = await _client.get('/merchant/dashboard');
    return DashboardSummary.fromJson(data as Map<String, dynamic>);
  }
}

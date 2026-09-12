import 'package:network/network.dart';

import 'models/login_request.dart';
import 'models/login_response.dart';

/// 客户域后端的 API 客户端（business_pc 专用）。
///
/// 用法：
/// ```dart
/// final client = RuoQiNetworkClient(
///   baseUrl: String.fromEnvironment('CUSTOMER_API_BASE_URL', defaultValue: 'https://customer.example.com'),
///   tokenProvider: MyTokenProvider(),
/// );
/// final api = CustomerApi(client);
/// ```
class CustomerApi {
  const CustomerApi(this._client);

  final RuoQiNetworkClient _client;

  /// 登录，返回令牌与用户 ID。
  Future<LoginResponse> login(LoginRequest request) async {
    final data = await _client.post('/auth/login', data: request.toJson());
    return LoginResponse.fromJson(data as Map<String, dynamic>);
  }
}

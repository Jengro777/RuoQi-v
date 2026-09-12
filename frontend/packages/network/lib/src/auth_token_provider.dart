/// token 提供者抽象，具体实现由各 App 自己维护
/// （存哪、怎么刷新、用什么认证头，各后端各不相同）。
abstract interface class AuthTokenProvider {
  /// 返回当前可用的访问令牌；无令牌时返回 `null`。
  Future<String?> getAccessToken();
}

/// 默认实现：不做任何认证头注入。
class NoAuthTokenProvider implements AuthTokenProvider {
  const NoAuthTokenProvider();

  @override
  Future<String?> getAccessToken() async => null;
}

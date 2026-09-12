import 'package:dio/dio.dart';

/// 统一的网络/API 错误类型。
enum RuoQiErrorType {
  /// 连接失败、DNS 解析失败等。
  network,

  /// 连接/发送/接收超时。
  timeout,

  /// HTTP 401，需要重新登录或刷新 token。
  unauthorized,

  /// 服务端返回了业务错误（如 HTTP 4xx/5xx）。
  business,

  /// 其他未归类错误。
  unknown,
}

/// 所有网络与 API 调用统一抛出的异常。
class RuoQiApiException implements Exception {
  const RuoQiApiException(
    this.type,
    this.message, {
    this.statusCode,
    this.businessCode,
    this.details,
  });

  final RuoQiErrorType type;
  final String message;
  final int? statusCode;

  /// 后端业务错误码（如果返回结构里有的话）。
  final String? businessCode;

  /// 原始错误对象或响应体，便于排查。
  final Object? details;

  @override
  String toString() =>
      'RuoQiApiException(${type.name}, $statusCode, $message)';
}

/// 将 dio 的异常映射为统一的 [RuoQiApiException]。
///
/// 与具体后端无关，各 App 可以在此基础上扩展自己的业务错误处理。
RuoQiApiException mapDioException(DioException error) {
  final statusCode = error.response?.statusCode;
  final details = error.response?.data;

  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.transformTimeout:
      return RuoQiApiException(
        RuoQiErrorType.timeout,
        '请求超时',
        statusCode: statusCode,
      );
    case DioExceptionType.connectionError:
      return RuoQiApiException(
        RuoQiErrorType.network,
        '网络连接失败，请检查网络',
        statusCode: statusCode,
      );
    case DioExceptionType.badResponse:
      if (statusCode == 401) {
        return RuoQiApiException(
          RuoQiErrorType.unauthorized,
          '未授权，请重新登录',
          statusCode: statusCode,
          details: details,
        );
      }
      return RuoQiApiException(
        RuoQiErrorType.business,
        '请求失败（$statusCode）',
        statusCode: statusCode,
        details: details,
      );
    case DioExceptionType.cancel:
      return const RuoQiApiException(RuoQiErrorType.unknown, '请求已取消');
    case DioExceptionType.badCertificate:
      return RuoQiApiException(
        RuoQiErrorType.network,
        '证书校验失败',
        statusCode: statusCode,
      );
    case DioExceptionType.unknown:
      return RuoQiApiException(
        RuoQiErrorType.unknown,
        '未知错误：${error.message ?? error.error}',
        statusCode: statusCode,
        details: error.error,
      );
  }
}

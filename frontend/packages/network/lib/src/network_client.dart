import 'package:dio/dio.dart';

import 'api_exception.dart';
import 'auth_token_provider.dart';

/// 与具体后端无关的网络客户端。
///
/// 只负责「怎么发请求」：超时、token 注入、统一错误映射。
/// baseUrl、接口路径、DTO 解析都由各 App 的 `lib/api/` 自行决定。
class RuoQiNetworkClient {
  RuoQiNetworkClient({
    required String baseUrl,
    AuthTokenProvider? tokenProvider,
    Dio? dio,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: connectTimeout,
                receiveTimeout: receiveTimeout,
              ),
            ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenProvider?.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  final Dio _dio;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.get(path, queryParameters: queryParameters),
    );
  }

  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.post(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.put(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.patch(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) {
    return _request(
      () => _dio.delete(path, data: data, queryParameters: queryParameters),
    );
  }

  Future<dynamic> _request(
    Future<Response<dynamic>> Function() send,
  ) async {
    try {
      final response = await send();
      return response.data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }
}

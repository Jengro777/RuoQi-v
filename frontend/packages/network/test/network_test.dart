import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network/network.dart';

class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter({this.statusCode = 200, this.body = '{}'});

  final int statusCode;
  final String body;
  RequestOptions? lastRequest;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    lastRequest = options;
    return ResponseBody.fromString(
      body,
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _FixedToken implements AuthTokenProvider {
  const _FixedToken(this.token);

  final String token;

  @override
  Future<String?> getAccessToken() async => token;
}

void main() {
  group('mapDioException', () {
    RequestOptions options() => RequestOptions(path: '/x');

    test('timeout', () {
      final error = DioException(
        requestOptions: options(),
        type: DioExceptionType.connectionTimeout,
      );

      final mapped = mapDioException(error);
      expect(mapped.type, RuoQiErrorType.timeout);
      expect(mapped.statusCode, isNull);
    });

    test('connection error', () {
      final error = DioException(
        requestOptions: options(),
        type: DioExceptionType.connectionError,
      );

      expect(mapDioException(error).type, RuoQiErrorType.network);
    });

    test('401 maps to unauthorized', () {
      final error = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          statusCode: 401,
          data: {'message': 'nope'},
        ),
        type: DioExceptionType.badResponse,
      );

      final mapped = mapDioException(error);
      expect(mapped.type, RuoQiErrorType.unauthorized);
      expect(mapped.statusCode, 401);
    });

    test('other status maps to business', () {
      final error = DioException(
        requestOptions: options(),
        response: Response(
          requestOptions: options(),
          statusCode: 500,
        ),
        type: DioExceptionType.badResponse,
      );

      expect(mapDioException(error).type, RuoQiErrorType.business);
    });
  });

  group('RuoQiNetworkClient', () {
    late _FakeAdapter adapter;
    late RuoQiNetworkClient client;

    setUp(() {
      adapter = _FakeAdapter(body: jsonEncode({'ok': true}));
      final dio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = adapter;
      client = RuoQiNetworkClient(
        baseUrl: 'https://example.com',
        dio: dio,
        tokenProvider: const _FixedToken('abc'),
      );
    });

    test('returns decoded json and injects bearer token', () async {
      final data = await client.get('/ping');

      expect(data, {'ok': true});
      expect(
        adapter.lastRequest?.headers['Authorization'],
        'Bearer abc',
      );
    });

    test('post forwards data and query parameters', () async {
      await client.post(
        '/login',
        data: {'username': 'u', 'password': 'p'},
        queryParameters: {'v': 1},
      );

      expect(adapter.lastRequest?.path, '/login');
      expect(adapter.lastRequest?.queryParameters['v'], 1);
      expect(adapter.lastRequest?.data['username'], 'u');
    });

    test('401 throws RuoQiApiException.unauthorized', () async {
      final failingDio = Dio(BaseOptions(baseUrl: 'https://example.com'))
        ..httpClientAdapter = _FakeAdapter(
          statusCode: 401,
          body: '{}',
        );
      final failingClient = RuoQiNetworkClient(
        baseUrl: 'https://example.com',
        dio: failingDio,
      );

      await expectLater(
        failingClient.post('/login'),
        throwsA(
          isA<RuoQiApiException>().having(
            (e) => e.type,
            'type',
            RuoQiErrorType.unauthorized,
          ),
        ),
      );
    });
  });
}

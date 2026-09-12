import 'package:flutter_test/flutter_test.dart';
import 'package:ruoqi_business_app/api/customer/models/login_request.dart';
import 'package:ruoqi_business_app/api/customer/models/login_response.dart';

void main() {
  test('LoginRequest serializes to json', () {
    const request = LoginRequest(username: 'alice', password: 'secret');

    expect(
      request.toJson(),
      {'username': 'alice', 'password': 'secret'},
    );
  });

  test('LoginResponse parses snake_case json', () {
    final response = LoginResponse.fromJson({
      'access_token': 'token-123',
      'user_id': 'u-1',
    });

    expect(response.accessToken, 'token-123');
    expect(response.userId, 'u-1');
    expect(
      response.toJson(),
      {'access_token': 'token-123', 'user_id': 'u-1'},
    );
  });
}

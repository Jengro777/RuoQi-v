import 'package:json_annotation/json_annotation.dart';

part 'login_response.g.dart';

@JsonSerializable()
class LoginResponse {
  const LoginResponse({
    required this.accessToken,
    required this.userId,
  });

  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'user_id')
  final String userId;

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

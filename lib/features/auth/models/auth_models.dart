import 'package:json_annotation/json_annotation.dart';
part 'auth_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginResponse {
  @JsonKey(name: 'access')
  final String accessToken;
  @JsonKey(name: 'refresh')
  final String refreshToken;

  LoginResponse({required this.accessToken, required this.refreshToken});

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LegacyTokenResponse {
  final String code;
  final String iv;

  LegacyTokenResponse({required this.code, required this.iv});

  factory LegacyTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$LegacyTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LegacyTokenResponseToJson(this);
}

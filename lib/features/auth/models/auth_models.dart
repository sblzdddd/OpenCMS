import 'package:json_annotation/json_annotation.dart';
part 'auth_models.g.dart';

@JsonSerializable()
class TokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  TokenResponse({required this.accessToken, required this.refreshToken});

  factory TokenResponse.fromJson(Map<String, dynamic> json) =>
      _$TokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TokenResponseToJson(this);
}

@JsonSerializable()
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

@JsonSerializable()
class LegacyTokenResponse {
  @JsonKey(name: 'code')
  final String code;

  @JsonKey(name: 'iv')
  final String iv;

  LegacyTokenResponse({required this.code, required this.iv});

  factory LegacyTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$LegacyTokenResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LegacyTokenResponseToJson(this);
}

/// User information data model
@JsonSerializable()
class UserInfo {
  @JsonKey(name: 'username')
  final String userName;
  @JsonKey(name: 'user_type')
  final int userType;
  final int id;
  final String name;
  @JsonKey(name: 'en_name')
  final String enName;
  final String language;
  final List<String> permissions;

  const UserInfo({
    required this.userName,
    required this.userType,
    required this.id,
    required this.name,
    required this.enName,
    required this.language,
    required this.permissions,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) =>
      _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  @override
  String toString() {
    return 'UserInfo(userName: $userName, userType: $userType, id: $id, name: $name, enName: $enName, language: $language, permissions: $permissions)';
  }
}

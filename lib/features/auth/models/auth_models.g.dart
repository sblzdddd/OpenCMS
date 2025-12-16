// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenResponse _$TokenResponseFromJson(Map<String, dynamic> json) =>
    TokenResponse(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
    );

Map<String, dynamic> _$TokenResponseToJson(TokenResponse instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'access': instance.accessToken,
      'refresh': instance.refreshToken,
    };

LegacyTokenResponse _$LegacyTokenResponseFromJson(Map<String, dynamic> json) =>
    LegacyTokenResponse(code: json['code'] as String, iv: json['iv'] as String);

Map<String, dynamic> _$LegacyTokenResponseToJson(
  LegacyTokenResponse instance,
) => <String, dynamic>{'code': instance.code, 'iv': instance.iv};

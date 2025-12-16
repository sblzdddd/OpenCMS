// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_bulletin_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DailyBulletin _$DailyBulletinFromJson(Map<String, dynamic> json) =>
    DailyBulletin(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      dept: json['dept'] as String,
    );

Map<String, dynamic> _$DailyBulletinToJson(DailyBulletin instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'dept': instance.dept,
    };

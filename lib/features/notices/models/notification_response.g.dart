// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Notification _$NotificationFromJson(Map<String, dynamic> json) => Notification(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  isTop: (json['is_top'] as num).toInt(),
  adddate: json['adddate'] as String,
);

Map<String, dynamic> _$NotificationToJson(Notification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'is_top': instance.isTop,
      'adddate': instance.adddate,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_today_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarTodayItem _$CalendarTodayItemFromJson(Map<String, dynamic> json) =>
    CalendarTodayItem(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      kind: (json['kind'] as num).toInt(),
      time: json['time'] as String,
      content: json['content'] as String,
      location: json['location'] as String,
      addedBy: json['added_by'] as String,
    );

Map<String, dynamic> _$CalendarTodayItemToJson(CalendarTodayItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'kind': instance.kind,
      'time': instance.time,
      'content': instance.content,
      'location': instance.location,
      'added_by': instance.addedBy,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_classroom_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeClassroomResponse _$FreeClassroomResponseFromJson(
  Map<String, dynamic> json,
) => FreeClassroomResponse(
  rooms: json['rooms'] as String,
  date: json['date'] as String,
  period: json['period'] as String,
);

Map<String, dynamic> _$FreeClassroomResponseToJson(
  FreeClassroomResponse instance,
) => <String, dynamic>{
  'rooms': instance.rooms,
  'date': instance.date,
  'period': instance.period,
};

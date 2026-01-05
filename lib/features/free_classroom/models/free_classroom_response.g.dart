// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'free_classroom_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FreeClassroomResponse _$FreeClassroomResponseFromJson(
  Map<String, dynamic> json,
) => FreeClassroomResponse(
  rooms: json['rooms'] as String,
  status: json['status'] as String,
  info: json['info'] as String,
);

Map<String, dynamic> _$FreeClassroomResponseToJson(
  FreeClassroomResponse instance,
) => <String, dynamic>{
  'rooms': instance.rooms,
  'status': instance.status,
  'info': instance.info,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_comment_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarCommentResponse _$CalendarCommentResponseFromJson(
  Map<String, dynamic> json,
) => CalendarCommentResponse(
  id: json['id'] as String,
  kind: json['kind'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$CalendarCommentResponseToJson(
  CalendarCommentResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'kind': instance.kind,
  'content': instance.content,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calendar_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CalendarDetailResponse _$CalendarDetailResponseFromJson(
  Map<String, dynamic> json,
) => CalendarDetailResponse(
  id: json['id'] as String,
  whichpage: json['whichpage'] as String,
  whichday: json['whichday'] as String,
  ctime: json['ctime'] as String,
  content: json['content'] as String,
  location: json['location'] as String,
  fromperiod: json['fromperiod'] as String,
  endperiod: json['endperiod'] as String,
  kind: json['kind'] as String,
  thekind: json['thekind'] as String,
  addtime: json['addtime'] as String,
  title: json['title'] as String,
  whoadd: json['whoadd'] as String,
  ctype: json['ctype'] as String,
  invisibleToParentsStudent: json['invisible_to_parents_student'] as String,
);

Map<String, dynamic> _$CalendarDetailResponseToJson(
  CalendarDetailResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'whichpage': instance.whichpage,
  'whichday': instance.whichday,
  'ctime': instance.ctime,
  'content': instance.content,
  'location': instance.location,
  'fromperiod': instance.fromperiod,
  'endperiod': instance.endperiod,
  'kind': instance.kind,
  'thekind': instance.thekind,
  'addtime': instance.addtime,
  'title': instance.title,
  'whoadd': instance.whoadd,
  'ctype': instance.ctype,
  'invisible_to_parents_student': instance.invisibleToParentsStudent,
};

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'homework_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HomeworkItem _$HomeworkItemFromJson(Map<String, dynamic> json) => HomeworkItem(
  id: (json['id'] as num).toInt(),
  title: json['title'] as String,
  whichday: json['whichday'] as String,
  duedate: json['duedate'] as String,
  ename: json['ename'] as String,
  courseEname: json['course_ename'] as String,
  teacherEname: json['teacher_ename'] as String,
  cate: (json['cate'] as num).toInt(),
);

Map<String, dynamic> _$HomeworkItemToJson(HomeworkItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'whichday': instance.whichday,
      'duedate': instance.duedate,
      'ename': instance.ename,
      'course_ename': instance.courseEname,
      'teacher_ename': instance.teacherEname,
      'cate': instance.cate,
    };

CompletedHomework _$CompletedHomeworkFromJson(Map<String, dynamic> json) =>
    CompletedHomework(
      courseName: json['course_name'] as String,
      title: json['title'] as String,
      completedAt: DateTime.parse(json['completed_at'] as String),
      homeworkId: (json['homework_id'] as num).toInt(),
    );

Map<String, dynamic> _$CompletedHomeworkToJson(CompletedHomework instance) =>
    <String, dynamic>{
      'course_name': instance.courseName,
      'title': instance.title,
      'completed_at': instance.completedAt.toIso8601String(),
      'homework_id': instance.homeworkId,
    };

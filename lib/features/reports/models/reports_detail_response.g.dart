// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_detail_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportDetail _$ReportDetailFromJson(Map<String, dynamic> json) => ReportDetail(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  grade: json['grade'] as String,
  year: (json['year'] as num).toInt(),
  semester: (json['semester'] as num).toInt(),
  month: json['month'] as String,
  kind: (json['kind'] as num).toInt(),
  courseMark: (json['course_mark'] as List<dynamic>)
      .map((e) => CourseMark.fromJson(e as Map<String, dynamic>))
      .toList(),
  pSat: (json['p_sat'] as List<dynamic>)
      .map((e) => PSat.fromJson(e as Map<String, dynamic>))
      .toList(),
  markComponent: (json['mark_component'] as List<dynamic>)
      .map((e) => MarkComponent.fromJson(e as Map<String, dynamic>))
      .toList(),
  subjectComment: json['subject_comment'] as List<dynamic>,
);

Map<String, dynamic> _$ReportDetailToJson(ReportDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'grade': instance.grade,
      'year': instance.year,
      'semester': instance.semester,
      'month': instance.month,
      'kind': instance.kind,
      'course_mark': instance.courseMark,
      'p_sat': instance.pSat,
      'mark_component': instance.markComponent,
      'subject_comment': instance.subjectComment,
    };

CourseMark _$CourseMarkFromJson(Map<String, dynamic> json) => CourseMark(
  id: (json['id'] as num).toInt(),
  courseName: json['course_name'] as String,
  average: json['average'] as String,
  mark: json['mark'] as String,
  grade: json['grade'] as String,
  comment: json['comment'] as String,
  commentCn: json['comment_cn'] as String,
  teacherName: json['teacher_name'] as String,
  level: json['level'] as String,
);

Map<String, dynamic> _$CourseMarkToJson(CourseMark instance) =>
    <String, dynamic>{
      'id': instance.id,
      'course_name': instance.courseName,
      'average': instance.average,
      'mark': instance.mark,
      'grade': instance.grade,
      'comment': instance.comment,
      'comment_cn': instance.commentCn,
      'teacher_name': instance.teacherName,
      'level': instance.level,
    };

PSat _$PSatFromJson(Map<String, dynamic> json) => PSat(
  total: (json['total'] as num).toInt(),
  math: (json['math'] as num).toInt(),
  rw: (json['rw'] as num).toInt(),
);

Map<String, dynamic> _$PSatToJson(PSat instance) => <String, dynamic>{
  'total': instance.total,
  'math': instance.math,
  'rw': instance.rw,
};

MarkComponent _$MarkComponentFromJson(Map<String, dynamic> json) =>
    MarkComponent(
      board: json['board'] as String,
      syllabus: json['syllabus'] as String,
      syllabusCode: json['syllabus_code'] as String,
      component: json['component'] as String,
      adjustedMark: json['adjusted_mark'] as String,
      finalMark: json['final_mark'] as String,
      grade: json['grade'] as String,
    );

Map<String, dynamic> _$MarkComponentToJson(MarkComponent instance) =>
    <String, dynamic>{
      'board': instance.board,
      'syllabus': instance.syllabus,
      'syllabus_code': instance.syllabusCode,
      'component': instance.component,
      'adjusted_mark': instance.adjustedMark,
      'final_mark': instance.finalMark,
      'grade': instance.grade,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_list_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GradeGroup _$GradeGroupFromJson(Map<String, dynamic> json) => GradeGroup(
  grade: json['grade'] as String,
  exams: (json['exams'] as List<dynamic>)
      .map((e) => Exam.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GradeGroupToJson(GradeGroup instance) =>
    <String, dynamic>{'grade': instance.grade, 'exams': instance.exams};

Exam _$ExamFromJson(Map<String, dynamic> json) => Exam(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  grade: json['grade'] as String,
  year: (json['year'] as num).toInt(),
  semester: (json['semester'] as num).toInt(),
  month: json['month'] as String,
  kind: (json['kind'] as num).toInt(),
  courseMark: json['course_mark'] as List<dynamic>,
  pSat: json['p_sat'] as List<dynamic>,
  markComponent: json['mark_component'] as List<dynamic>,
  subjectComment: json['subject_comment'] as List<dynamic>,
);

Map<String, dynamic> _$ExamToJson(Exam instance) => <String, dynamic>{
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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assessment_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubjectAssessment _$SubjectAssessmentFromJson(Map<String, dynamic> json) =>
    SubjectAssessment(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      subject: json['subject'] as String,
      assessments: (json['assessments'] as List<dynamic>)
          .map((e) => Assessment.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SubjectAssessmentToJson(SubjectAssessment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'subject': instance.subject,
      'assessments': instance.assessments,
    };

Assessment _$AssessmentFromJson(Map<String, dynamic> json) => Assessment(
  date: json['date'] as String,
  title: json['title'] as String,
  teacher: json['teacher'] as String,
  kind: json['kind'] as String,
  kindOther: json['kind_other'] as String,
  mark: json['mark'] as String,
  outOf: json['out_of'] as String,
  average: json['average'] as String,
);

Map<String, dynamic> _$AssessmentToJson(Assessment instance) =>
    <String, dynamic>{
      'date': instance.date,
      'title': instance.title,
      'teacher': instance.teacher,
      'kind': instance.kind,
      'kind_other': instance.kindOther,
      'mark': instance.mark,
      'out_of': instance.outOf,
      'average': instance.average,
    };

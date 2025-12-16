// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_stats_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourseStats _$CourseStatsFromJson(Map<String, dynamic> json) => CourseStats(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  studentCount: (json['student_count'] as num).toInt(),
  teachers: json['teachers'] as String,
  lessons: (json['lessons'] as num).toInt(),
  absent: (json['absent'] as num).toInt(),
  unapproved: (json['unapproved'] as num).toInt(),
  late: (json['late'] as num).toInt(),
  approved: (json['approved'] as num).toInt(),
  sick: (json['sick'] as num).toInt(),
  school: (json['school'] as num).toInt(),
);

Map<String, dynamic> _$CourseStatsToJson(CourseStats instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'student_count': instance.studentCount,
      'teachers': instance.teachers,
      'lessons': instance.lessons,
      'absent': instance.absent,
      'unapproved': instance.unapproved,
      'late': instance.late,
      'approved': instance.approved,
      'sick': instance.sick,
      'school': instance.school,
    };

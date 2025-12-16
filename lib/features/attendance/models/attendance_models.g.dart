// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceResponse _$AttendanceResponseFromJson(Map<String, dynamic> json) =>
    AttendanceResponse(
      recordOfDays: (json['record_of_days'] as List<dynamic>)
          .map((e) => RecordOfDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAbsentCount: (json['total_absent_count'] as num).toDouble(),
    );

Map<String, dynamic> _$AttendanceResponseToJson(AttendanceResponse instance) =>
    <String, dynamic>{
      'record_of_days': instance.recordOfDays,
      'total_absent_count': instance.totalAbsentCount,
    };

RecordOfDay _$RecordOfDayFromJson(Map<String, dynamic> json) => RecordOfDay(
  date: DateTime.parse(json['date'] as String),
  attendances: (json['attendances'] as List<dynamic>)
      .map((e) => AttendanceEntry.fromJson(e as Map<String, dynamic>))
      .toList(),
  absentCount: (json['absent_count'] as num).toDouble(),
  student: Student.fromJson(json['student'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RecordOfDayToJson(RecordOfDay instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'attendances': instance.attendances,
      'absent_count': instance.absentCount,
      'student': instance.student,
    };

AttendanceEntry _$AttendanceEntryFromJson(Map<String, dynamic> json) =>
    AttendanceEntry(
      courseId: (json['course_id'] as num).toInt(),
      courseName: json['course_name'] as String,
      kind: (json['kind'] as num).toInt(),
      reason: json['reason'] as String,
      grade: json['grade'] as String,
    );

Map<String, dynamic> _$AttendanceEntryToJson(AttendanceEntry instance) =>
    <String, dynamic>{
      'course_id': instance.courseId,
      'course_name': instance.courseName,
      'kind': instance.kind,
      'reason': instance.reason,
      'grade': instance.grade,
    };

Student _$StudentFromJson(Map<String, dynamic> json) =>
    Student(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$StudentToJson(Student instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

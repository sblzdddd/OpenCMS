import 'package:json_annotation/json_annotation.dart';

import 'attendance_constants.dart';

part 'attendance_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class AttendanceResponse {
  final List<RecordOfDay> recordOfDays;
  final double totalAbsentCount;

  AttendanceResponse({
    required this.recordOfDays,
    required this.totalAbsentCount,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) =>
      _$AttendanceResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RecordOfDay {
  final DateTime date;
  final List<AttendanceEntry> attendances;
  final double absentCount;
  final Student student;

  RecordOfDay({
    required this.date,
    required this.attendances,
    required this.absentCount,
    required this.student,
  });

  factory RecordOfDay.fromJson(Map<String, dynamic> json) =>
      _$RecordOfDayFromJson(json);
  Map<String, dynamic> toJson() => _$RecordOfDayToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class AttendanceEntry {
  final int courseId;
  final String courseName;
  final int kind;
  final String reason;
  final String grade;

  AttendanceEntry({
    required this.courseId,
    required this.courseName,
    required this.kind,
    required this.reason,
    required this.grade,
  });

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) =>
      _$AttendanceEntryFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceEntryToJson(this);

  String get subjectName => courseName == ''
      ? '/'
      : (courseName == 'ES' ? 'Evening Study' : courseName);

  String getSubjectNameWithIndex(int index) {
    if (index == 0) {
      return 'MR';
    }
    return courseName == ''
        ? '/'
        : (courseName == 'ES' ? 'Evening Study' : courseName);
  }

  String get kindText => AttendanceConstants.kindText[kind] ?? 'Unknown';
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Student {
  final int id;
  final String name;

  Student({required this.id, required this.name});

  factory Student.fromJson(Map<String, dynamic> json) =>
      _$StudentFromJson(json);
  Map<String, dynamic> toJson() => _$StudentToJson(this);
}

/// Data model for course statistics API response
library;

import 'package:json_annotation/json_annotation.dart';

part 'course_stats_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CourseStats {
  final int id;
  final String name;
  final int studentCount;
  final String teachers;
  final int lessons;
  final int absent;
  final int unapproved;
  final int late;
  final int approved;
  final int sick;
  final int school;

  CourseStats({
    required this.id,
    required this.name,
    required this.studentCount,
    required this.teachers,
    required this.lessons,
    required this.absent,
    required this.unapproved,
    required this.late,
    required this.approved,
    required this.sick,
    required this.school,
  });

  factory CourseStats.fromJson(Map<String, dynamic> json) =>
      _$CourseStatsFromJson(json);
  Map<String, dynamic> toJson() => _$CourseStatsToJson(this);

  int get totalAttendanceIssues => absent + unapproved + late;

  /// Get attendance rate as percentage
  double get attendanceRate {
    if (lessons == 0) return 100.0;
    final attended = lessons - absent;
    return (attended / lessons) * 100;
  }
}

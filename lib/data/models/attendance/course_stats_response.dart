/// Data model for course statistics API response

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

  factory CourseStats.fromJson(Map<String, dynamic> json) {
    return CourseStats(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      studentCount: json['student_count'] ?? 0,
      teachers: json['teachers'] ?? '',
      lessons: json['lessons'] ?? 0,
      absent: json['absent'] ?? 0,
      unapproved: json['unapproved'] ?? 0,
      late: json['late'] ?? 0,
      approved: json['approved'] ?? 0,
      sick: json['sick'] ?? 0,
      school: json['school'] ?? 0,
    );
  }

  /// Get total attendance issues (absent + unapproved + late)
  int get totalAttendanceIssues => absent + unapproved + late;

  /// Get attendance rate as percentage
  double get attendanceRate {
    if (lessons == 0) return 100.0;
    final attended = lessons - absent;
    return (attended / lessons) * 100;
  }
}

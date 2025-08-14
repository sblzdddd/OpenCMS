class AttendanceResponse {
  final List<RecordOfDay> recordOfDays;
  final double totalAbsentCount;

  AttendanceResponse({
    required this.recordOfDays,
    required this.totalAbsentCount,
  });

  factory AttendanceResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> daysJson = json['record_of_days'] as List<dynamic>? ?? [];
    return AttendanceResponse(
      recordOfDays: daysJson
          .map((e) => RecordOfDay.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAbsentCount: (json['total_absent_count'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

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

  factory RecordOfDay.fromJson(Map<String, dynamic> json) {
    final List<dynamic> atts = json['attendances'] as List<dynamic>? ?? [];
    return RecordOfDay(
      date: DateTime.parse(json['date'] as String),
      attendances: atts
          .map((e) => AttendanceEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      absentCount: (json['absent_count'] as num?)?.toDouble() ?? 0.0,
      student: Student.fromJson(json['student'] as Map<String, dynamic>),
    );
  }
}

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

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceEntry(
      courseId: (json['course_id'] as num?)?.toInt() ?? 0,
      courseName: (json['course_name'] as String?) ?? '',
      kind: (json['kind'] as num?)?.toInt() ?? 0,
      reason: (json['reason'] as String?) ?? '',
      grade: (json['grade'] as String?) ?? '',
    );
  }

  String get subjectName => courseName == ''? '/': (courseName == 'ES' ? 'Evening Study' : courseName);
}

class Student {
  final int id;
  final String name;

  Student({
    required this.id,
    required this.name,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
    );
  }
}



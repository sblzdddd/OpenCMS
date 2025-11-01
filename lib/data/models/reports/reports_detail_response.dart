/// Data models for detailed reports API response
library;

class ReportDetail {
  final int id;
  final String name;
  final String grade;
  final int year;
  final int semester;
  final String month;
  final int kind;
  final List<CourseMark> courseMark;
  final List<PSat> pSat;
  final List<MarkComponent> markComponent;
  final List<dynamic> subjectComment;

  ReportDetail({
    required this.id,
    required this.name,
    required this.grade,
    required this.year,
    required this.semester,
    required this.month,
    required this.kind,
    required this.courseMark,
    required this.pSat,
    required this.markComponent,
    required this.subjectComment,
  });

  factory ReportDetail.fromJson(Map<String, dynamic> json) {
    return ReportDetail(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      grade: json['grade'] ?? '',
      year: json['year'] ?? 0,
      semester: json['semester'] ?? 0,
      month: json['month'] ?? '',
      kind: json['kind'] ?? 0,
      courseMark:
          (json['course_mark'] as List<dynamic>?)
              ?.map((item) => CourseMark.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pSat:
          (json['p_sat'] as List<dynamic>?)
              ?.map((item) => PSat.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      markComponent:
          (json['mark_component'] as List<dynamic>?)
              ?.map(
                (item) => MarkComponent.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      subjectComment: json['subject_comment'] ?? [],
    );
  }

  /// Get exam type description based on kind
  String get examType {
    switch (kind) {
      case 0:
        return 'Regular Exam';
      case 4:
        return 'PSAT';
      case 5:
        return 'External Component';
      default:
        return 'Unknown Type';
    }
  }

  /// Check if this is a PSAT report
  bool get isPSAT => kind == 4;

  /// Check if this is an external component report
  bool get isExternalComponent => kind == 5;

  /// Check if this is a regular exam report
  bool get isRegularExam => kind == 0;
}

class CourseMark {
  final int id;
  final String courseName;
  final String average;
  final String mark;
  final String grade;
  final String comment;
  final String commentCn;
  final String teacherName;
  final String level;

  CourseMark({
    required this.id,
    required this.courseName,
    required this.average,
    required this.mark,
    required this.grade,
    required this.comment,
    required this.commentCn,
    required this.teacherName,
    required this.level,
  });

  factory CourseMark.fromJson(Map<String, dynamic> json) {
    return CourseMark(
      id: json['id'] ?? 0,
      courseName: json['course_name'] ?? '',
      average: json['average'] ?? '',
      mark: json['mark'] ?? '',
      grade: json['grade'] ?? '',
      comment: json['comment'] ?? '',
      commentCn: json['comment_cn'] ?? '',
      teacherName: json['teacher_name'] ?? '',
      level: json['level'] ?? '',
    );
  }

  /// Get numeric mark value
  double? get numericMark => double.tryParse(mark);

  /// Get numeric average value
  double? get numericAverage => double.tryParse(average);

  /// Check if mark is above average
  bool get isAboveAverage {
    final markNum = numericMark;
    final avgNum = numericAverage;
    if (markNum == null || avgNum == null) return false;
    return markNum > avgNum;
  }
}

class PSat {
  final int total;
  final int math;
  final int rw;

  PSat({required this.total, required this.math, required this.rw});

  factory PSat.fromJson(Map<String, dynamic> json) {
    return PSat(
      total: json['total'] ?? 0,
      math: json['math'] ?? 0,
      rw: json['rw'] ?? 0,
    );
  }

  /// Get evidence-based reading and writing score
  int get evidenceBasedReadingWriting => rw;

  /// Get total score as percentage of maximum (1600)
  double get totalPercentage => (total / 1600) * 100;

  /// Get math score as percentage of maximum (800)
  double get mathPercentage => (math / 800) * 100;

  /// Get reading/writing score as percentage of maximum (800)
  double get rwPercentage => (rw / 800) * 100;
}

class MarkComponent {
  final String board;
  final String syllabus;
  final String syllabusCode;
  final String component;
  final String adjustedMark;
  final String finalMark;
  final String grade;

  MarkComponent({
    required this.board,
    required this.syllabus,
    required this.syllabusCode,
    required this.component,
    required this.adjustedMark,
    required this.finalMark,
    required this.grade,
  });

  factory MarkComponent.fromJson(Map<String, dynamic> json) {
    return MarkComponent(
      board: json['board'] ?? '',
      syllabus: json['syllabus'] ?? '',
      syllabusCode: json['syllabus_code'] ?? '',
      component: json['component'] ?? '',
      adjustedMark: json['adjusted_mark'] ?? '',
      finalMark: json['final_mark'] ?? '',
      grade: json['grade'] ?? '',
    );
  }

  /// Get numeric adjusted mark
  double? get numericAdjustedMark => double.tryParse(adjustedMark);

  /// Get numeric final mark
  double? get numericFinalMark => double.tryParse(finalMark);

  /// Check if final mark is different from adjusted mark
  bool get hasMarkAdjustment {
    final adjusted = numericAdjustedMark;
    final finalMark = numericFinalMark;
    if (adjusted == null || finalMark == null) return false;
    return adjusted != finalMark;
  }
}

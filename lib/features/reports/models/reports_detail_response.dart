/// Data models for detailed reports API response
library;

import 'package:json_annotation/json_annotation.dart';

part 'reports_detail_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory ReportDetail.fromJson(Map<String, dynamic> json) => _$ReportDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ReportDetailToJson(this);

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

  bool get isPSAT => kind == 4;
  bool get isExternalComponent => kind == 5;
  bool get isRegularExam => kind == 0;
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory CourseMark.fromJson(Map<String, dynamic> json) => _$CourseMarkFromJson(json);
  Map<String, dynamic> toJson() => _$CourseMarkToJson(this);

  double? get numericMark => double.tryParse(mark);
  double? get numericAverage => double.tryParse(average);
  bool get isAboveAverage {
    final markNum = numericMark;
    final avgNum = numericAverage;
    if (markNum == null || avgNum == null) return false;
    return markNum > avgNum;
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class PSat {
  final int total;
  final int math;
  final int rw;

  PSat({required this.total, required this.math, required this.rw});

  factory PSat.fromJson(Map<String, dynamic> json) => _$PSatFromJson(json);
  Map<String, dynamic> toJson() => _$PSatToJson(this);

  /// Get evidence-based reading and writing score
  int get evidenceBasedReadingWriting => rw;
  double get totalPercentage => (total / 1600) * 100;
  double get mathPercentage => (math / 800) * 100;
  double get rwPercentage => (rw / 800) * 100;
}

@JsonSerializable(fieldRename: FieldRename.snake)
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

  factory MarkComponent.fromJson(Map<String, dynamic> json) => _$MarkComponentFromJson(json);
  Map<String, dynamic> toJson() => _$MarkComponentToJson(this);

  double? get numericAdjustedMark => double.tryParse(adjustedMark);
  double? get numericFinalMark => double.tryParse(finalMark);

  bool get hasMarkAdjustment {
    final adjusted = numericAdjustedMark;
    final finalMark = numericFinalMark;
    if (adjusted == null || finalMark == null) return false;
    return adjusted != finalMark;
  }
}

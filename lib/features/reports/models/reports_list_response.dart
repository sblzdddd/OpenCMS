/// Data models for reports list API response
library;

import 'package:json_annotation/json_annotation.dart';

part 'reports_list_response.g.dart';

class ReportsListResponse {
  final List<GradeGroup> gradeGroups;

  ReportsListResponse({required this.gradeGroups});

  factory ReportsListResponse.fromJson(List<dynamic> json) {
    return ReportsListResponse(
      gradeGroups: json
          .map((item) => GradeGroup.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class GradeGroup {
  final String grade;
  final List<Exam> exams;

  GradeGroup({required this.grade, required this.exams});

  factory GradeGroup.fromJson(Map<String, dynamic> json) =>
      _$GradeGroupFromJson(json);
  Map<String, dynamic> toJson() => _$GradeGroupToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Exam {
  final int id;
  final String name;
  final String grade;
  final int year;
  final int semester;
  final String month;
  final int kind;
  final List<dynamic> courseMark;
  final List<dynamic> pSat;
  final List<dynamic> markComponent;
  final List<dynamic> subjectComment;

  Exam({
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

  factory Exam.fromJson(Map<String, dynamic> json) =>
      _$ExamFromJson(json);
  Map<String, dynamic> toJson() => _$ExamToJson(this);

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

  /// Check if exam has detailed data
  bool get hasDetails =>
      courseMark.isNotEmpty || pSat.isNotEmpty || markComponent.isNotEmpty;
}

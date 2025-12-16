/// Data models for assessment API response
library;

import 'package:json_annotation/json_annotation.dart';

part 'assessment_models.g.dart';


class AssessmentResponse {
  final List<SubjectAssessment> subjects;

  AssessmentResponse({required this.subjects});

  factory AssessmentResponse.fromJson(List<dynamic> json) {
    return AssessmentResponse(
      subjects: (json).map((item) => SubjectAssessment.fromJson(item)).toList(),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class SubjectAssessment {
  final int id;
  final String name;
  final String subject;
  final List<Assessment> assessments;

  SubjectAssessment({
    required this.id,
    required this.name,
    required this.subject,
    required this.assessments,
  });

  factory SubjectAssessment.fromJson(Map<String, dynamic> json) =>
      _$SubjectAssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$SubjectAssessmentToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Assessment {
  final String date;
  final String title;
  final String teacher;
  final String kind;
  final String kindOther;
  final String mark;
  final String outOf;
  final String average;

  Assessment({
    required this.date,
    required this.title,
    required this.teacher,
    required this.kind,
    required this.kindOther,
    required this.mark,
    required this.outOf,
    required this.average,
  });

  factory Assessment.fromJson(Map<String, dynamic> json) =>
      _$AssessmentFromJson(json);
  Map<String, dynamic> toJson() => _$AssessmentToJson(this);

  double? get numericMark {
    try {
      return double.tryParse(mark);
    } catch (e) {
      return null;
    }
  }

  double? get numericOutOf {
    try {
      return double.tryParse(outOf);
    } catch (e) {
      return null;
    }
  }

  double? get numericAverage {
    try {
      // Remove percentage sign if present
      String cleanAverage = average.replaceAll('%', '');
      return double.tryParse(cleanAverage);
    } catch (e) {
      return null;
    }
  }

  double? get percentageScore {
    final markValue = numericMark;
    final outOfValue = numericOutOf;

    if (markValue != null && outOfValue != null && outOfValue > 0) {
      return (markValue / outOfValue) * 100;
    }
    return null;
  }

  bool get isTestOrExam =>
      kind.toLowerCase().contains('test') ||
      kind.toLowerCase().contains('exam');

  bool get isProject => kind.toLowerCase().contains('project');
  bool get isHomework => kind.toLowerCase().contains('homework');
  bool get isPractical => kind.toLowerCase().contains('practical');
  bool get isFormative => kind.toLowerCase().contains('formative');
}

/// Data models for assessment API response
library;

class AssessmentResponse {
  final List<SubjectAssessment> subjects;

  AssessmentResponse({required this.subjects});

  factory AssessmentResponse.fromJson(List<dynamic> json) {
    return AssessmentResponse(
      subjects: (json).map((item) => SubjectAssessment.fromJson(item)).toList(),
    );
  }
}

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

  factory SubjectAssessment.fromJson(Map<String, dynamic> json) {
    return SubjectAssessment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      assessments:
          (json['assessments'] as List<dynamic>?)
              ?.map((item) => Assessment.fromJson(item))
              .toList() ??
          [],
    );
  }
}

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

  factory Assessment.fromJson(Map<String, dynamic> json) {
    return Assessment(
      date: json['date'] ?? '',
      title: json['title'] ?? '',
      teacher: json['teacher'] ?? '',
      kind: json['kind'] ?? '',
      kindOther: json['kind_other'] ?? '',
      mark: json['mark'] ?? '',
      outOf: json['out_of'] ?? '',
      average: json['average'] ?? '',
    );
  }

  /// Get the numeric mark value
  double? get numericMark {
    try {
      return double.tryParse(mark);
    } catch (e) {
      return null;
    }
  }

  /// Get the numeric out of value
  double? get numericOutOf {
    try {
      return double.tryParse(outOf);
    } catch (e) {
      return null;
    }
  }

  /// Get the numeric average value
  double? get numericAverage {
    try {
      // Remove percentage sign if present
      String cleanAverage = average.replaceAll('%', '');
      return double.tryParse(cleanAverage);
    } catch (e) {
      return null;
    }
  }

  /// Calculate percentage score
  double? get percentageScore {
    final markValue = numericMark;
    final outOfValue = numericOutOf;

    if (markValue != null && outOfValue != null && outOfValue > 0) {
      return (markValue / outOfValue) * 100;
    }
    return null;
  }

  /// Check if this is a test/exam
  bool get isTestOrExam =>
      kind.toLowerCase().contains('test') ||
      kind.toLowerCase().contains('exam');

  /// Check if this is a project
  bool get isProject => kind.toLowerCase().contains('project');

  /// Check if this is homework
  bool get isHomework => kind.toLowerCase().contains('homework');

  /// Check if this is practical work
  bool get isPractical => kind.toLowerCase().contains('practical');

  /// Check if this is formative assessment
  bool get isFormative => kind.toLowerCase().contains('formative');
}

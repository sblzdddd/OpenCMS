import 'package:flutter/material.dart';

class AssessmentUtils {
  static Color getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 80) return Colors.blue;
    if (score >= 70) return Colors.orange;
    if (score >= 60) return Colors.yellow.shade700;
    return Colors.red;
  }

  static Color getGradeColor(String grade) {
    final upperGrade = grade.toUpperCase();
    if (upperGrade == 'A') return Colors.green;
    if (upperGrade == 'B') return Colors.blue;
    if (upperGrade == 'C') return Colors.orange;
    if (upperGrade == 'D') return Colors.yellow.shade700;
    if (upperGrade == 'E' || upperGrade == 'F' || upperGrade == 'U') {
      return Colors.red;
    }
    return Colors.grey;
  }

  static Color getAssessmentTypeColor(String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('test') || lowerType.contains('exam')) {
      return Colors.red;
    }
    if (lowerType.contains('project')) return Colors.blue;
    if (lowerType.contains('homework')) return Colors.green;
    if (lowerType.contains('practical')) return Colors.orange;
    if (lowerType.contains('formative')) return Colors.purple;
    return Colors.grey;
  }
}

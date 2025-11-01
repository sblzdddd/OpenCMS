/// Data models for homework API response
library;

class HomeworkResponse {
  final List<HomeworkItem> homeworkItems;

  HomeworkResponse({required this.homeworkItems});

  factory HomeworkResponse.fromJson(List<dynamic> json) {
    return HomeworkResponse(
      homeworkItems: json
          .map((item) => HomeworkItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class HomeworkItem {
  final int id;
  final String title;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String courseName;
  final String courseEnglishName;
  final String teacherName;
  final int category;

  HomeworkItem({
    required this.id,
    required this.title,
    required this.assignedDate,
    required this.dueDate,
    required this.courseName,
    required this.courseEnglishName,
    required this.teacherName,
    required this.category,
  });

  factory HomeworkItem.fromJson(Map<String, dynamic> json) {
    return HomeworkItem(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      assignedDate:
          DateTime.tryParse(json['whichday'] as String? ?? '') ??
          DateTime.now(),
      dueDate:
          DateTime.tryParse(json['duedate'] as String? ?? '') ?? DateTime.now(),
      courseName: json['ename'] as String? ?? '',
      courseEnglishName: json['course_ename'] as String? ?? '',
      teacherName: json['teacher_ename'] as String? ?? '',
      category: json['cate'] as int? ?? 0,
    );
  }

  /// Check if homework is overdue
  bool get isOverdue => DateTime.now().isAfter(dueDate);

  /// Get days until due date (negative if overdue)
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  /// Get category text for display
  String get categoryText {
    switch (category) {
      case 0:
        return 'Regular';
      case 1:
        return 'Important';
      case 2:
        return 'Urgent';
      default:
        return 'Unknown';
    }
  }
}

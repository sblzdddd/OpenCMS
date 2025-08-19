
/// Data models for homework API response
library;

class HomeworkResponse {
  final List<HomeworkItem> homeworkItems;
  final int currentPage;
  final int totalPages; 
  final int totalRecords;

  HomeworkResponse({
    required this.homeworkItems,
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
  });

  factory HomeworkResponse.fromJson(Map<String, dynamic> json) {
    return HomeworkResponse(
      homeworkItems: (json['homework_items'] as List<dynamic>?)
          ?.map((item) => HomeworkItem.fromJson(item as Map<String, dynamic>))
          .toList() ?? [],
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1, 
      totalRecords: (json['total_records'] as num?)?.toInt() ?? 0,
    );
  }
}

class HomeworkItem {
  final String id;
  final DateTime assignedDate;
  final String teacher;
  final String title;
  final String category;
  final DateTime dueDate;
  final String courseCode;
  final bool isCompleted;

  HomeworkItem({
    required this.id,
    required this.assignedDate,
    required this.teacher,
    required this.title,
    required this.category,
    required this.dueDate,
    required this.courseCode,
    required this.isCompleted,
  });

  factory HomeworkItem.fromJson(Map<String, dynamic> json) {
    return HomeworkItem(
      id: json['id'] as String? ?? '',
      assignedDate: DateTime.tryParse(json['assigned_date'] as String? ?? '') ?? DateTime.now(),
      teacher: json['teacher'] as String? ?? '',
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? '',
      dueDate: DateTime.tryParse(json['due_date'] as String? ?? '') ?? DateTime.now(),
      courseCode: json['course_code'] as String? ?? '',
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  /// Get homework status text for display
  String get statusText => isCompleted ? 'Completed' : 'Pending';

  /// Check if homework is overdue  
  bool get isOverdue => !isCompleted && DateTime.now().isAfter(dueDate);

  /// Get days until due date (negative if overdue)
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
}

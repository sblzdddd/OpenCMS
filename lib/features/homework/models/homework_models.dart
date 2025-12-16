/// Data models for homework API response
library;

import 'package:json_annotation/json_annotation.dart';

part 'homework_models.g.dart';

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

@JsonSerializable(fieldRename: FieldRename.snake)
class HomeworkItem {
  final int id;
  final String title;
  final String whichday;
  final String duedate;
  final String ename;
  final String courseEname;
  final String teacherEname;
  final int cate;

  HomeworkItem({
    required this.id,
    required this.title,
    required this.whichday,
    required this.duedate,
    required this.ename,
    required this.courseEname,
    required this.teacherEname,
    required this.cate,
  });

  @JsonKey(includeFromJson: false)
  DateTime get assignedDate => DateTime.tryParse(whichday) ?? DateTime.now();

  @JsonKey(includeFromJson: false)
  DateTime get dueDate => DateTime.tryParse(duedate) ?? DateTime.now();

  @JsonKey(includeFromJson: false) String get courseName => ename;
  @JsonKey(includeFromJson: false) String get courseEnglishName => courseEname;
  @JsonKey(includeFromJson: false) String get teacherName => teacherEname;
  @JsonKey(includeFromJson: false) int get category => cate;

  factory HomeworkItem.fromJson(Map<String, dynamic> json) =>
    _$HomeworkItemFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkItemToJson(this);

  /// negative if overdue
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  String get categoryText {
    switch (cate) {
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

/// Model for locally storing completed homework information
@JsonSerializable(fieldRename: FieldRename.snake)
class CompletedHomework {
  final String courseName;
  final String title;
  final DateTime completedAt;
  final int homeworkId;

  CompletedHomework({
    required this.courseName,
    required this.title,
    required this.completedAt,
    required this.homeworkId,
  });

  Map<String, dynamic> toJson() => _$CompletedHomeworkToJson(this);

  factory CompletedHomework.fromJson(Map<String, dynamic> json) =>
    _$CompletedHomeworkFromJson(json);
}

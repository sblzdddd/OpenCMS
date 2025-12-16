library;

import 'package:json_annotation/json_annotation.dart';
part 'daily_bulletin_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class DailyBulletin {
  final int id;
  final String title;
  final String dept;

  const DailyBulletin({
    required this.id,
    required this.title,
    required this.dept,
  });

  @JsonKey(includeFromJson: false)
  String get department => dept;

  factory DailyBulletin.fromJson(Map<String, dynamic> json) => 
    _$DailyBulletinFromJson(json);
  Map<String, dynamic> toJson() => _$DailyBulletinToJson(this);

  @override
  String toString() {
    return 'DailyBulletin(id: $id, title: $title, department: $department)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyBulletin &&
        other.id == id &&
        other.title == title &&
        other.department == department;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ department.hashCode;
  }
}

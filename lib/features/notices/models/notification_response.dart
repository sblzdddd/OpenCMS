library;

import 'package:json_annotation/json_annotation.dart';
part 'notification_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Notification {
  final int id;
  final String title;
  final int isTop;
  final String adddate;

  const Notification({
    required this.id,
    required this.title,
    required this.isTop,
    required this.adddate,
  });

  @JsonKey(includeFromJson: false)
  String get addDate => adddate;

  factory Notification.fromJson(Map<String, dynamic> json) => _$NotificationFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationToJson(this);

  bool get isPinned => isTop == 1;

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, isTop: $isTop, addDate: $addDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification &&
        other.id == id &&
        other.title == title &&
        other.isTop == isTop &&
        other.addDate == addDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ isTop.hashCode ^ addDate.hashCode;
  }
}

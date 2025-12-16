import 'package:json_annotation/json_annotation.dart';

part 'calendar_today_item.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CalendarTodayItem {
  final int id;
  final String title;
  final int kind; // category code (0,1,2,3,4,7,8,9,20)
  final String time; // empty or a range string
  final String content;
  final String location;
  final String addedBy;

  const CalendarTodayItem({
    required this.id,
    required this.title,
    required this.kind,
    required this.time,
    required this.content,
    required this.location,
    required this.addedBy,
  });

  factory CalendarTodayItem.fromJson(Map<String, dynamic> json) =>
    _$CalendarTodayItemFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarTodayItemToJson(this);

  /// Human readable category from kind code
  String get kindText {
    switch (kind) {
      case 0:
        return 'Public';
      case 1:
        return 'Other';
      case 2:
        return 'Academic';
      case 3:
        return 'Examinations';
      case 4:
        return 'Field Trips/Events/Fixtures';
      case 7:
        return 'CPD';
      case 8:
        return 'University';
      case 9:
        return 'Pastoral';
      case 20:
        return 'My Calendar';
      default:
        return 'Unknown';
    }
  }
}

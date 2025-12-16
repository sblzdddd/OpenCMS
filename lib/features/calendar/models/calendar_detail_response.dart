/// Data models for calendar detail API response
library;

import 'package:json_annotation/json_annotation.dart';

part 'calendar_detail_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CalendarDetailResponse {
  final String id;
  final String whichpage;
  final String whichday;
  final String ctime;
  final String content;
  final String location;
  final String fromperiod;
  final String endperiod;
  final String kind;
  final String thekind;
  final String addtime;
  final String title;
  final String whoadd;
  final String ctype;
  final String invisibleToParentsStudent;

  CalendarDetailResponse({
    required this.id,
    required this.whichpage,
    required this.whichday,
    required this.ctime,
    required this.content,
    required this.location,
    required this.fromperiod,
    required this.endperiod,
    required this.kind,
    required this.thekind,
    required this.addtime,
    required this.title,
    required this.whoadd,
    required this.ctype,
    required this.invisibleToParentsStudent,
  });

  factory CalendarDetailResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarDetailResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarDetailResponseToJson(this);

  /// Get parsed date time
  DateTime? get dateTime {
    try {
      return DateTime.parse(whichday);
    } catch (e) {
      return null;
    }
  }

  /// Get formatted date string
  String get formattedDate {
    final date = dateTime;
    if (date == null) return whichday;

    return '${date.day}/${date.month}/${date.year}';
  }

  /// Check if this is visible to parents/students
  bool get isVisibleToParentsStudent => invisibleToParentsStudent != '1';
}

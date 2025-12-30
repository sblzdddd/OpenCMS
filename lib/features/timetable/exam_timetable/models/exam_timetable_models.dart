import 'package:json_annotation/json_annotation.dart';
part 'exam_timetable_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ExamTimetableEntry {
  final int id;
  final int examId;
  final String examName;
  final String code;
  final String paper;
  final String date; // yyyy-mm-dd
  final String time;
  final String room;
  final String seat;
  final int isTaken;

  @JsonKey(includeFromJson: false)
  String get startTime => time.contains('-') ? time.split('-').first.trim() : '';

  @JsonKey(includeFromJson: false)
  String get endTime => time.contains('-') ? time.split('-').last.trim() : '';

  const ExamTimetableEntry({
    required this.id,
    required this.examId,
    required this.examName,
    required this.date,
    required this.time,
    required this.paper,
    required this.code,
    required this.room,
    required this.seat,
    required this.isTaken,
  });
  factory ExamTimetableEntry.fromJson(Map<String, dynamic> json) => _$ExamTimetableEntryFromJson(json);

  Map<String, dynamic> toJson() => _$ExamTimetableEntryToJson(this);
}

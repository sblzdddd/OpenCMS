/// Data model for an exam timetable entry parsed from legacy CMS HTML
library;

class ExamTimetableEntry {
  final int id;
  final int examId;
  final String examName;
  final String code;
  final String paper;
  final String date; // yyyy-mm-dd
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String room;
  final String seat;
  final bool isTaken;

  const ExamTimetableEntry({
    required this.id,
    required this.examId,
    required this.examName,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.paper,
    required this.code,
    required this.room,
    required this.seat,
    required this.isTaken,
  });
  factory ExamTimetableEntry.fromJson(Map<String, dynamic> json) {
    return ExamTimetableEntry(
      id: json['id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      examName: json['exam_name'] ?? '',
      code: json['code'] ?? '',
      paper: json['paper'] ?? '',
      date: json['date'] ?? '',
      startTime: (json['time'] != null && json['time'].contains('-'))
          ? json['time'].split('-')[0]
          : '',
      endTime: (json['time'] != null && json['time'].contains('-'))
          ? json['time'].split('-')[1]
          : '',
      room: json['room'] ?? '',
      seat: json['seat'] ?? '',
      isTaken: (json['is_taken'] ?? 0) == 1,
    );
  }
}

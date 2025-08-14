/// Data model for an exam timetable entry parsed from legacy CMS HTML

class ExamTimetableEntry {
  final String date; // yyyy-mm-dd
  final String startTime; // HH:mm
  final String endTime; // HH:mm
  final String subject;
  final String code;
  final String room;
  final String seat;

  const ExamTimetableEntry({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.code,
    required this.room,
    required this.seat,
  });
}



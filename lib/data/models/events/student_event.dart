/// Data model for student-led events
library;

enum StudentEventType { led, unstaffed }

class StudentEvent {
  final int id;
  final StudentEventType type;
  final String title;
  final String dateTime;
  final String applicant;
  final String applicantId;
  final String status;
  final String approvalStatus;

  StudentEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.dateTime,
    required this.applicant,
    required this.applicantId,
    required this.status,
    required this.approvalStatus,
  });

  factory StudentEvent.fromHtml({
    required int id,
    required StudentEventType type,
    required String title,
    required String dateTime,
    required String applicant,
    required String status,
    required String approvalStatus,
  }) {
    // Extract applicant ID from applicant string
    final applicantId =
        RegExp(r'\((\d+)\)').firstMatch(applicant)?.group(1) ?? '';

    return StudentEvent(
      id: id,
      type: type,
      title: title,
      dateTime: dateTime,
      applicant: applicant,
      applicantId: applicantId,
      status: status,
      approvalStatus: approvalStatus,
    );
  }

  @override
  String toString() {
    return 'StudentLedEvent(id: $id, title: $title, dateTime: $dateTime, applicant: $applicant, status: $status)';
  }
}

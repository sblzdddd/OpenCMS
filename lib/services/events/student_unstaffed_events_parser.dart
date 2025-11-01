import 'package:html/parser.dart' as html_parser;
import '../../data/models/events/student_event.dart';

/// Parser for student-unstaffed events HTML from legacy CMS
class StudentUnstaffedEventsParser {
  static List<StudentEvent> parseHtml(String html) {
    final document = html_parser.parse(html);
    final events = <StudentEvent>[];

    // Find the table containing events
    final table = document.querySelector('table');
    if (table == null) return events;

    // Get all table rows (skip header row)
    final rows = table.querySelectorAll('tr');
    for (int i = 1; i < rows.length; i++) {
      // Skip header row
      final row = rows[i];
      final cells = row.querySelectorAll('td');

      if (cells.length >= 6) {
        try {
          // Extract data from each cell
          final approvalStatusCell = cells[0];
          final titleCell = cells[2];
          final dateCell = cells[3];
          final applicantCell = cells[4];
          final statusCell = cells[5];

          // Extract approval status
          String approvalStatus = '';
          final approvalElement = approvalStatusCell.querySelector('strong');
          if (approvalElement != null) {
            approvalStatus = approvalElement.text.trim();
          } else {
            // Check for clock icon (pending approval)
            final clockIcon = approvalStatusCell.querySelector('i.fa-clock-o');
            if (clockIcon != null) {
              approvalStatus = 'Pending';
            }
          }

          // Extract title and ID from link
          String title = '';
          int eventId = 0;
          final titleLink = titleCell.querySelector('a');
          if (titleLink != null) {
            title = titleLink.text.trim();
            final href = titleLink.attributes['href'] ?? '';
            final idMatch = RegExp(r'/su_event/view/(\d+)/').firstMatch(href);
            if (idMatch != null) {
              eventId = int.tryParse(idMatch.group(1) ?? '0') ?? 0;
            }
          }

          // Extract date
          final date = dateCell.text.trim();

          // Extract applicant
          final applicant = applicantCell.text.trim();

          // Extract status
          final statusElement = statusCell.querySelector('span');
          final status = statusElement?.text.trim() ?? '';

          // Create event if we have valid data
          if (eventId > 0 && title.isNotEmpty) {
            events.add(
              StudentEvent.fromHtml(
                id: eventId,
                type: StudentEventType.unstaffed,
                title: title,
                dateTime: date,
                applicant: applicant,
                status: status,
                approvalStatus: approvalStatus,
              ),
            );
          }
        } catch (e) {
          // Skip malformed rows
          continue;
        }
      }
    }

    return events;
  }
}

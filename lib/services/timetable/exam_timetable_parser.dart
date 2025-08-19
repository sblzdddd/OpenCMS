import 'package:html/parser.dart' as html_parser;
import '../../data/models/timetable/exam_timetable_entry.dart';

List<ExamTimetableEntry> parseExamHtml(String html) {
  final document = html_parser.parse(html);
  final List<ExamTimetableEntry> entries = [];

  // Month context fallback: from header like "2025 - 5"
  int? headerYear;
  int? headerMonth;
  final headerLabel = document.querySelector('div.ct2 label.b');
  if (headerLabel != null) {
    final text = headerLabel.text.trim();
    final match = RegExp(r'^(\d{4})\s*-\s*(\d{1,2})').firstMatch(text);
    if (match != null) {
      headerYear = int.tryParse(match.group(1) ?? '');
      headerMonth = int.tryParse(match.group(2) ?? '');
    }
  }

  // Each exam item is an li with a title containing key:value pairs
  final lis = document.querySelectorAll('li[title]');
  for (final li in lis) {
    final title = (li.attributes['title'] ?? '').trim();
    if (title.isEmpty) continue;

    final info = _parseTitleAttributes(title);
    final subject = li.querySelector('strong.pl10')?.text.trim() ?? info['Paper'] ?? '';
    final timeStr = li.querySelector('strong.c1')?.text.trim() ?? info['Time'] ?? '';

    // Find date from preceding .ca li within the same ul
    String? dateStr;
    final parentUl = li.parent;
    if (parentUl != null) {
      final children = parentUl.children;
      final idx = children.indexOf(li);
      for (int i = idx - 1; i >= 0; i--) {
        final c = children[i];
        if (c.classes.contains('ca')) {
          final t = c.text.trim();
          if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(t)) {
            dateStr = t;
            break;
          }
        }
      }
    }

    // If missing exact date, fallback to header year/month with unknown day
    dateStr ??= _buildFallbackDate(headerYear, headerMonth);

    // Parse time like "08:45-10:30"
    String startTime = '';
    String endTime = '';
    final timeMatch = RegExp(r'(\d{2}:\d{2})\s*-\s*(\d{2}:\d{2})').firstMatch(timeStr);
    if (timeMatch != null) {
      startTime = timeMatch.group(1) ?? '';
      endTime = timeMatch.group(2) ?? '';
    }

    entries.add(ExamTimetableEntry(
      date: dateStr ?? '',
      startTime: startTime,
      endTime: endTime,
      subject: subject,
      code: info['Code'] ?? '',
      room: info['Room'] ?? '',
      seat: info['Seat'] ?? '',
    ));
  }

  // Sort by date then time
  entries.sort((a, b) {
    final ad = a.date.compareTo(b.date);
    if (ad != 0) return ad;
    return a.startTime.compareTo(b.startTime);
  });
  return entries;
}

Map<String, String> _parseTitleAttributes(String title) {
  // Format: "Time:08:45-10:30;Code:9709/45;Paper:Mathematics;Room:B324;Seat:D04"
  final Map<String, String> map = {};
  for (final part in title.split(';')) {
    final p = part.trim();
    final idx = p.indexOf(':');
    if (idx > 0) {
      final key = p.substring(0, idx).trim();
      final value = p.substring(idx + 1).trim();
      map[key] = value;
    }
  }
  return map;
}

String? _buildFallbackDate(int? year, int? month) {
  if (year == null || month == null) return null;
  final mStr = month.toString().padLeft(2, '0');
  return '${year.toString()}-$mStr-01';
}
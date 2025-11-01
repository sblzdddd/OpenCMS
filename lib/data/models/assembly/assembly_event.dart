/// Data model for assembly events
library;

class AssemblyEvent {
  final String title;
  final String location;
  final String date;
  final String classes;
  final String room;

  AssemblyEvent({
    required this.title,
    required this.location,
    required this.date,
    required this.classes,
    required this.room,
  });

  factory AssemblyEvent.fromJson(Map<String, dynamic> json) {
    return AssemblyEvent(
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      date: json['date'] ?? '',
      classes: json['classes'] ?? '',
      room: json['room'] ?? '',
    );
  }

  /// Get parsed date time from date string
  DateTime? get dateTime {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  /// Get the period index based on the title
  /// Form Time events should be period 0, Pastoral events should be period 8
  int? get periodIndex {
    final lowerTitle = title.toLowerCase();

    // Check for Form Time - should be period 0
    if (lowerTitle.contains('form time 1') ||
        (lowerTitle.contains('form time') && lowerTitle.contains('07:50'))) {
      return 0; // Form Time period
    }

    // Check for Pastoral (Form Time 2) - should be period 8
    if (lowerTitle.contains('form time 2') ||
        (lowerTitle.contains('form time') && lowerTitle.contains('13:20'))) {
      return 8; // Pastoral period
    }

    return null;
  }

  /// Get the weekday (0-6, Monday = 0) from the date
  int? get weekday {
    final dt = dateTime;
    if (dt == null) return null;
    return dt.weekday - 1; // Convert to 0-based (Monday = 0)
  }

  /// Check if this is a valid form time assembly event
  bool get isValidFormTimeEvent {
    return periodIndex != null &&
        weekday != null &&
        weekday! >= 0 &&
        weekday! < 5;
  }

  @override
  String toString() {
    return 'AssemblyEvent(title: $title, date: $date, location: $location, classes: $classes)';
  }
}

/// Data models for calendar detail API response
library;

class CalendarDetailResponse {
  final String id;
  final String whichPage;
  final String whichDay;
  final String ctime;
  final String content;
  final String location;
  final String fromPeriod;
  final String endPeriod;
  final String kind;
  final String theKind;
  final String addTime;
  final String title;
  final String whoAdd;
  final String ctype;
  final String invisibleToParentsStudent;

  CalendarDetailResponse({
    required this.id,
    required this.whichPage,
    required this.whichDay,
    required this.ctime,
    required this.content,
    required this.location,
    required this.fromPeriod,
    required this.endPeriod,
    required this.kind,
    required this.theKind,
    required this.addTime,
    required this.title,
    required this.whoAdd,
    required this.ctype,
    required this.invisibleToParentsStudent,
  });

  factory CalendarDetailResponse.fromJson(Map<String, dynamic> json) {
    return CalendarDetailResponse(
      id: json['id']?.toString() ?? '',
      whichPage: json['whichpage']?.toString() ?? '',
      whichDay: json['whichday']?.toString() ?? '',
      ctime: json['ctime']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      fromPeriod: json['fromperiod']?.toString() ?? '',
      endPeriod: json['endperiod']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      theKind: json['thekind']?.toString() ?? '',
      addTime: json['addtime']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      whoAdd: json['whoadd']?.toString() ?? '',
      ctype: json['ctype']?.toString() ?? '',
      invisibleToParentsStudent: json['invisible_to_parents_student']?.toString() ?? '',
    );
  }

  /// Get parsed date time
  DateTime? get dateTime {
    try {
      return DateTime.parse(whichDay);
    } catch (e) {
      return null;
    }
  }

  /// Get formatted date string
  String get formattedDate {
    final date = dateTime;
    if (date == null) return whichDay;
    
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Check if this is visible to parents/students
  bool get isVisibleToParentsStudent => invisibleToParentsStudent != '1';
}

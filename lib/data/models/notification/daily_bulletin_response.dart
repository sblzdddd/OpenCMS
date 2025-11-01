/// Daily Bulletin model representing a bulletin from the CMS system
class DailyBulletin {
  final int id;
  final String title;
  final String department;

  const DailyBulletin({
    required this.id,
    required this.title,
    required this.department,
  });

  factory DailyBulletin.fromJson(Map<String, dynamic> json) {
    return DailyBulletin(
      id: json['id'] as int,
      title: json['title'] as String,
      department: json['dept'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'department': department};
  }

  @override
  String toString() {
    return 'DailyBulletin(id: $id, title: $title, department: $department)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DailyBulletin &&
        other.id == id &&
        other.title == title &&
        other.department == department;
  }

  @override
  int get hashCode {
    return id.hashCode ^ title.hashCode ^ department.hashCode;
  }
}

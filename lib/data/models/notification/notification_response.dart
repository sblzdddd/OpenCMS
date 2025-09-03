/// Notification model representing a notice from the CMS system
class Notification {
  final int id;
  final String title;
  final int isTop;
  final String addDate;

  const Notification({
    required this.id,
    required this.title,
    required this.isTop,
    required this.addDate,
  });

  /// Create a Notification from JSON data
  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as int,
      title: json['title'] as String,
      isTop: json['is_top'] as int,
      addDate: json['adddate'] as String,
    );
  }

  /// Convert Notification to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'is_top': isTop,
      'adddate': addDate,
    };
  }

  /// Check if this notification is pinned to the top
  bool get isPinned => isTop == 1;

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, isTop: $isTop, addDate: $addDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification &&
        other.id == id &&
        other.title == title &&
        other.isTop == isTop &&
        other.addDate == addDate;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        isTop.hashCode ^
        addDate.hashCode;
  }
}

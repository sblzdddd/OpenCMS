/// Data models for calendar comment API response
library;

class CalendarCommentResponse {
  final String id;
  final String kind;
  final String content;

  CalendarCommentResponse({
    required this.id,
    required this.kind,
    required this.content,
  });

  factory CalendarCommentResponse.fromJson(Map<String, dynamic> json) {
    return CalendarCommentResponse(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
    );
  }

  /// Get formatted content with line breaks
  String get formattedContent {
    return content.replaceAll('\n', '<p>');
  }
}

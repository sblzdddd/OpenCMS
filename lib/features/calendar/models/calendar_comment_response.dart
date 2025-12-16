library;

import 'package:json_annotation/json_annotation.dart';

part 'calendar_comment_response.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class CalendarCommentResponse {
  final String id;
  final String kind;
  final String content;

  CalendarCommentResponse({
    required this.id,
    required this.kind,
    required this.content,
  });

  factory CalendarCommentResponse.fromJson(Map<String, dynamic> json) =>
      _$CalendarCommentResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CalendarCommentResponseToJson(this);

  /// Get formatted content with line breaks
  String get formattedContent {
    return content.replaceAll('\n', '<p>');
  }
}

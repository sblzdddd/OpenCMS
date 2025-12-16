/// Data models for referral comments API response
library;

import 'package:json_annotation/json_annotation.dart';
part 'referral_response.g.dart';

class ReferralResponse {
  final List<ReferralComment> comments;

  ReferralResponse({required this.comments});

  factory ReferralResponse.fromJson(List<dynamic> json) {
    return ReferralResponse(
      comments: json
          .map((item) => ReferralComment.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ReferralComment {
  final int id;
  final String teacherName;
  final String? subject;
  final String time;
  final String comment;
  final String commentTranslation;
  final String kind;
  final String kindName;
  final List<ReferralReply> replies;

  ReferralComment({
    required this.id,
    required this.teacherName,
    this.subject,
    required this.time,
    required this.comment,
    required this.commentTranslation,
    required this.kind,
    required this.kindName,
    required this.replies,
  });

  factory ReferralComment.fromJson(Map<String, dynamic> json) =>
    _$ReferralCommentFromJson(json);
  Map<String, dynamic> toJson() => _$ReferralCommentToJson(this);

  DateTime? get dateTime {
    try {
      return DateTime.parse(time);
    } catch (e) {
      return null;
    }
  }

  bool get isCommendation => kind.toLowerCase().contains('commendation');
  bool get isAreaOfConcern => kind.toLowerCase().contains('area of concern');
  bool get isAcademic => kind.toLowerCase().contains('academic');
  bool get isPastoral => kind.toLowerCase().contains('pastoral');
  bool get isResidence => kind.toLowerCase().contains('residence');
  bool get hasReplies => replies.isNotEmpty;

  String get formattedDate {
    final date = dateTime;
    if (date == null) return time;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String get category {
    final parts = kind.split(',');
    return parts.isNotEmpty ? parts.first : kind;
  }

  String get subcategory {
    final parts = kind.split(',');
    return parts.length > 1 ? parts[1] : '';
  }

  String get area {
    final parts = kind.split(',');
    return parts.length > 2 ? parts[2] : '';
  }
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ReferralReply {
  final int id;
  final int commentId;
  final String teacherName;
  final String teacherType;
  final String time;
  final String comment;
  final String commentTranslation;

  ReferralReply({
    required this.id,
    required this.commentId,
    required this.teacherName,
    required this.teacherType,
    required this.time,
    required this.comment,
    required this.commentTranslation,
  });

  factory ReferralReply.fromJson(Map<String, dynamic> json) =>
    _$ReferralReplyFromJson(json);
  Map<String, dynamic> toJson() => _$ReferralReplyToJson(this);

  /// Get parsed date time
  DateTime? get dateTime {
    try {
      return DateTime.parse(time);
    } catch (e) {
      return null;
    }
  }

  /// Get formatted date string
  String get formattedDate {
    final date = dateTime;
    if (date == null) return time;

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Data models for referral comments API response
library;

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

  factory ReferralComment.fromJson(Map<String, dynamic> json) {
    return ReferralComment(
      id: json['id'] as int? ?? 0,
      teacherName: json['teacher_name'] as String? ?? '',
      subject: json['subject'] as String?,
      time: json['time'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      commentTranslation: json['comment_translation'] as String? ?? '',
      kind: json['kind'] as String? ?? '',
      kindName: json['kind_name'] as String? ?? '',
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map(
                (item) => ReferralReply.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  /// Get parsed date time
  DateTime? get dateTime {
    try {
      return DateTime.parse(time);
    } catch (e) {
      return null;
    }
  }

  /// Check if this is a commendation
  bool get isCommendation => kind.toLowerCase().contains('commendation');

  /// Check if this is an area of concern
  bool get isAreaOfConcern => kind.toLowerCase().contains('area of concern');

  /// Check if this is academic related
  bool get isAcademic => kind.toLowerCase().contains('academic');

  /// Check if this is pastoral related
  bool get isPastoral => kind.toLowerCase().contains('pastoral');

  /// Check if this is residence related
  bool get isResidence => kind.toLowerCase().contains('residence');

  /// Check if this comment has replies
  bool get hasReplies => replies.isNotEmpty;

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

  /// Get category from kind string
  String get category {
    final parts = kind.split(',');
    return parts.isNotEmpty ? parts.first : kind;
  }

  /// Get subcategory from kind string
  String get subcategory {
    final parts = kind.split(',');
    return parts.length > 1 ? parts[1] : '';
  }

  /// Get specific area from kind string
  String get area {
    final parts = kind.split(',');
    return parts.length > 2 ? parts[2] : '';
  }
}

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

  factory ReferralReply.fromJson(Map<String, dynamic> json) {
    return ReferralReply(
      id: json['id'] as int? ?? 0,
      commentId: json['comment_id'] as int? ?? 0,
      teacherName: json['teacher_name'] as String? ?? '',
      teacherType: json['teacher_type'] as String? ?? '',
      time: json['time'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      commentTranslation: json['comment_translation'] as String? ?? '',
    );
  }

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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'referral_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReferralComment _$ReferralCommentFromJson(Map<String, dynamic> json) =>
    ReferralComment(
      id: (json['id'] as num).toInt(),
      teacherName: json['teacher_name'] as String,
      subject: json['subject'] as String?,
      time: json['time'] as String,
      comment: json['comment'] as String,
      commentTranslation: json['comment_translation'] as String,
      kind: json['kind'] as String,
      kindName: json['kind_name'] as String,
      replies: (json['replies'] as List<dynamic>)
          .map((e) => ReferralReply.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReferralCommentToJson(ReferralComment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'teacher_name': instance.teacherName,
      'subject': instance.subject,
      'time': instance.time,
      'comment': instance.comment,
      'comment_translation': instance.commentTranslation,
      'kind': instance.kind,
      'kind_name': instance.kindName,
      'replies': instance.replies,
    };

ReferralReply _$ReferralReplyFromJson(Map<String, dynamic> json) =>
    ReferralReply(
      id: (json['id'] as num).toInt(),
      commentId: (json['comment_id'] as num).toInt(),
      teacherName: json['teacher_name'] as String,
      teacherType: json['teacher_type'] as String,
      time: json['time'] as String,
      comment: json['comment'] as String,
      commentTranslation: json['comment_translation'] as String,
    );

Map<String, dynamic> _$ReferralReplyToJson(ReferralReply instance) =>
    <String, dynamic>{
      'id': instance.id,
      'comment_id': instance.commentId,
      'teacher_name': instance.teacherName,
      'teacher_type': instance.teacherType,
      'time': instance.time,
      'comment': instance.comment,
      'comment_translation': instance.commentTranslation,
    };

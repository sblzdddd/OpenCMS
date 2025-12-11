/// Referral comments service for fetching student referral data
library;

import '../../data/constants/api_endpoints.dart';
import '../../data/models/referral/referral.dart';
import '../../features/core/networking/http_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Service for handling referral comments API calls
class ReferralService {
  static final ReferralService _instance = ReferralService._internal();
  factory ReferralService() => _instance;
  ReferralService._internal();

  final HttpService _httpService = HttpService();

  /// Fetch referral comments for the current student
  ///
  /// Returns a list of referral comments with teacher feedback and replies
  /// Supports caching with 200 and 304 status codes
  Future<ReferralResponse> getReferralComments({bool refresh = false}) async {
    try {
      debugPrint(
        '[ReferralService] Fetching referral comments (refresh: $refresh)',
      );

      final response = await _httpService.get(
        API.referralUrl,
        refresh: refresh,
      );

      debugPrint('[ReferralService] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 304) {
        final List<dynamic> data = response.data as List<dynamic>;
        final referralResponse = ReferralResponse.fromJson(data);

        debugPrint(
          '[ReferralService] Successfully fetched ${referralResponse.comments.length} referral comments',
        );
        return referralResponse;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message:
              'Failed to fetch referral comments. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      debugPrint('[ReferralService] DioException - ${e.message}');
      rethrow;
    } catch (e) {
      debugPrint('[ReferralService] Unexpected error - $e');
      throw Exception('Failed to fetch referral comments: $e');
    }
  }

  /// Get referral comments with error handling
  ///
  /// Returns null if there's an error, otherwise returns the referral response
  Future<ReferralResponse?> getReferralCommentsSafe({
    bool refresh = false,
  }) async {
    try {
      return await getReferralComments(refresh: refresh);
    } catch (e) {
      debugPrint('[ReferralService] Safe fetch failed - $e');
      return null;
    }
  }

  /// Get only commendation comments
  Future<List<ReferralComment>> getCommendationComments({
    bool refresh = false,
  }) async {
    final response = await getReferralComments(refresh: refresh);
    return response.comments
        .where((comment) => comment.isCommendation)
        .toList();
  }

  /// Get only area of concern comments
  Future<List<ReferralComment>> getAreaOfConcernComments({
    bool refresh = false,
  }) async {
    final response = await getReferralComments(refresh: refresh);
    return response.comments
        .where((comment) => comment.isAreaOfConcern)
        .toList();
  }

  /// Get comments by category (Academic, Pastoral, Residence)
  Future<List<ReferralComment>> getCommentsByCategory({
    required String category,
    bool refresh = false,
  }) async {
    final response = await getReferralComments(refresh: refresh);
    return response.comments
        .where(
          (comment) => comment.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  /// Get comments by subject
  Future<List<ReferralComment>> getCommentsBySubject({
    required String subject,
    bool refresh = false,
  }) async {
    final response = await getReferralComments(refresh: refresh);
    return response.comments
        .where(
          (comment) => comment.subject?.toLowerCase() == subject.toLowerCase(),
        )
        .toList();
  }

  /// Get recent comments (within specified days)
  Future<List<ReferralComment>> getRecentComments({
    int days = 30,
    bool refresh = false,
  }) async {
    final response = await getReferralComments(refresh: refresh);
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return response.comments.where((comment) {
      final commentDate = comment.dateTime;
      return commentDate != null && commentDate.isAfter(cutoffDate);
    }).toList();
  }

  /// Get comments with replies
  Future<List<ReferralComment>> getCommentsWithReplies({
    bool refresh = false,
  }) async {
    final response = await getReferralComments(refresh: refresh);
    return response.comments.where((comment) => comment.hasReplies).toList();
  }

  /// Get statistics about referral comments
  Future<ReferralStatistics> getReferralStatistics({
    bool refresh = false,
  }) async {
    final response = await getReferralComments(refresh: refresh);
    final comments = response.comments;

    return ReferralStatistics(
      totalComments: comments.length,
      commendations: comments.where((c) => c.isCommendation).length,
      areasOfConcern: comments.where((c) => c.isAreaOfConcern).length,
      academicComments: comments.where((c) => c.isAcademic).length,
      pastoralComments: comments.where((c) => c.isPastoral).length,
      residenceComments: comments.where((c) => c.isResidence).length,
      commentsWithReplies: comments.where((c) => c.hasReplies).length,
      recentComments: comments.where((c) {
        final commentDate = c.dateTime;
        return commentDate != null &&
            commentDate.isAfter(
              DateTime.now().subtract(const Duration(days: 30)),
            );
      }).length,
    );
  }
}

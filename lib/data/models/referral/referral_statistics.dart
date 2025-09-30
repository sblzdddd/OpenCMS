
/// Statistics about referral comments
class ReferralStatistics {
  final int totalComments;
  final int commendations;
  final int areasOfConcern;
  final int academicComments;
  final int pastoralComments;
  final int residenceComments;
  final int commentsWithReplies;
  final int recentComments;

  const ReferralStatistics({
    required this.totalComments,
    required this.commendations,
    required this.areasOfConcern,
    required this.academicComments,
    required this.pastoralComments,
    required this.residenceComments,
    required this.commentsWithReplies,
    required this.recentComments,
  });

  /// Get commendation percentage
  double get commendationPercentage {
    if (totalComments == 0) return 0.0;
    return (commendations / totalComments) * 100;
  }

  /// Get area of concern percentage
  double get areaOfConcernPercentage {
    if (totalComments == 0) return 0.0;
    return (areasOfConcern / totalComments) * 100;
  }

  /// Get reply rate percentage
  double get replyRate {
    if (totalComments == 0) return 0.0;
    return (commentsWithReplies / totalComments) * 100;
  }
}

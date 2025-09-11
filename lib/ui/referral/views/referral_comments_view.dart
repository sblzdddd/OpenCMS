import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/subject_icon_constants.dart';
import '../../../services/referral/referral_service.dart';
import '../../../data/models/referral/referral_response.dart';
import '../../shared/views/refreshable_page.dart';

class ReferralCommentsView extends StatefulWidget {
  const ReferralCommentsView({super.key});

  @override
  State<ReferralCommentsView> createState() => _ReferralCommentsViewState();
}

class _ReferralCommentsViewState extends RefreshablePage<ReferralCommentsView> {
  final ReferralService _referralService = ReferralService();
  ReferralResponse? _referralResponse;
  String _selectedFilter = 'All';
  String _selectedSort = 'Recent';

  final List<String> _filters = [
    'All',
    'Commendations',
    'Areas of Concern',
    'Academic',
    'Pastoral',
    'Residence',
  ];
  final List<String> _sortOptions = ['Recent', 'Oldest', 'Subject', 'Teacher'];

  @override
  String get appBarTitle => 'Teacher Comments';

  @override
  List<Widget>? get appBarActions => [
    Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          setState(() {
            _selectedFilter = value;
          });
        },
        itemBuilder: (context) => _filters
            .map((filter) => PopupMenuItem(value: filter, child: Text(filter)))
            .toList(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _selectedFilter,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_drop_down,
                size: 18,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: PopupMenuButton<String>(
        onSelected: (value) {
          setState(() {
            _selectedSort = value;
          });
        },
        itemBuilder: (context) => _sortOptions
            .map((sort) => PopupMenuItem(value: sort, child: Text(sort)))
            .toList(),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            Icons.sort,
            size: 20,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ),
    ),
  ];

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final response = await _referralService.getReferralComments(
      refresh: refresh,
    );
    setState(() {
      _referralResponse = response;
    });
  }

  @override
  Widget buildPageContent(BuildContext context) {
    if (_referralResponse == null) return const SizedBox.shrink();

    final filteredComments = _getFilteredAndSortedComments();

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildStatistics(),
          const SizedBox(height: 16),
          _buildCommentsList(filteredComments),
        ],
      ),
    );
  }

  @override
  bool get isEmpty => _referralResponse?.comments.isEmpty ?? true;

  @override
  String get errorTitle => 'Error loading teacher comments';

  List<ReferralComment> _getFilteredAndSortedComments() {
    if (_referralResponse == null) return [];

    List<ReferralComment> comments = List.from(_referralResponse!.comments);

    // Apply filter
    switch (_selectedFilter) {
      case 'Commendations':
        comments = comments.where((c) => c.isCommendation).toList();
        break;
      case 'Areas of Concern':
        comments = comments.where((c) => c.isAreaOfConcern).toList();
        break;
      case 'Academic':
        comments = comments.where((c) => c.isAcademic).toList();
        break;
      case 'Pastoral':
        comments = comments.where((c) => c.isPastoral).toList();
        break;
      case 'Residence':
        comments = comments.where((c) => c.isResidence).toList();
        break;
    }

    // Apply sorting
    switch (_selectedSort) {
      case 'Recent':
        comments.sort(
          (a, b) => (b.dateTime ?? DateTime(1970)).compareTo(
            a.dateTime ?? DateTime(1970),
          ),
        );
        break;
      case 'Oldest':
        comments.sort(
          (a, b) => (a.dateTime ?? DateTime(1970)).compareTo(
            b.dateTime ?? DateTime(1970),
          ),
        );
        break;
      case 'Subject':
        comments.sort((a, b) => (a.subject ?? '').compareTo(b.subject ?? ''));
        break;
      case 'Teacher':
        comments.sort((a, b) => a.teacherName.compareTo(b.teacherName));
        break;
    }

    return comments;
  }

  Widget _buildStatistics() {
    if (_referralResponse == null) return const SizedBox.shrink();

    final comments = _referralResponse!.comments;
    final total = comments.length;
    final commendations = comments.where((c) => c.isCommendation).length;
    final concerns = comments.where((c) => c.isAreaOfConcern).length;
    final withReplies = comments.where((c) => c.hasReplies).length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comments Overview',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard('Total', total.toString(), Icons.comment),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Commendations',
                  commendations.toString(),
                  Icons.thumb_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Concerns',
                  concerns.toString(),
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Replies',
                  withReplies.toString(),
                  Icons.reply,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon, [
    Color? color,
  ]) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color ?? Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? Theme.of(context).colorScheme.primary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsList(List<ReferralComment> comments) {
    if (comments.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.comment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No comments found',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children: comments.map((comment) => _buildCommentCard(comment)).toList(),
    );
  }

  Widget _buildCommentCard(ReferralComment comment) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCommentHeader(comment),
            const SizedBox(height: 12),
            _buildCommentContent(comment),
            if (comment.hasReplies) ...[
              const SizedBox(height: 12),
              _buildReplies(comment.replies),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCommentHeader(ReferralComment comment) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            SubjectIconConstants.getIconForSubject(
              subjectName: comment.subject ?? '',
              code: comment.subject ?? '',
              placeholder: Symbols.person_rounded,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.teacherName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (comment.subject != null) ...[
                const SizedBox(height: 2),
                Text(
                  comment.subject!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              comment.formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 4),
            _buildKindChip(comment),
          ],
        ),
      ],
    );
  }

  Widget _buildKindChip(ReferralComment comment) {
    Color chipColor;
    if (comment.isCommendation) {
      chipColor = Colors.green;
    } else if (comment.isAreaOfConcern) {
      chipColor = Colors.orange;
    } else {
      chipColor = Colors.blue;
    }
    final kinds = comment.kindName.split(',');
    if (kinds.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 4.0,
      runSpacing: 2.0,
      children: kinds.map((kind) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: chipColor.withValues(alpha: 0.3)),
          ),
          child: Text(
            kind,
            style: TextStyle(
              fontSize: 10,
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCommentContent(ReferralComment comment) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.secondaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            comment.comment,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
          if (comment.commentTranslation.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Text(
                comment.commentTranslation,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReplies(List<ReferralReply> replies) {
    return Column(
      children: replies.map((reply) => _buildReplyCard(reply)).toList(),
    );
  }

  Widget _buildReplyCard(ReferralReply reply) {
    return Container(
      margin: EdgeInsets.only(top: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                child: Text(
                  'FT',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  reply.teacherName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                reply.formattedDate,
                style: TextStyle(
                  fontSize: 10,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.comment,
            style: const TextStyle(fontSize: 13, height: 1.3),
          ),
          if (reply.commentTranslation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              reply.commentTranslation,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'academic':
        return Colors.blue;
      case 'pastoral':
        return Colors.green;
      case 'residence':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

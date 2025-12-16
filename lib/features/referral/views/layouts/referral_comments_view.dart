import 'package:flutter/material.dart';
import 'package:opencms/features/referral/models/referral_response.dart';
import 'package:opencms/features/referral/views/components/referral_comments_list.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/referral/services/referral_service.dart';
import 'package:opencms/features/shared/views/views/refreshable_page.dart';
import 'package:opencms/features/referral/views/components/referral_stats.dart';

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
  @override
  String get skinKey => 'comments';

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
            color: themeNotifier.needTransparentBG
                ? (!themeNotifier.isDarkMode
                      ? Theme.of(
                          context,
                        ).colorScheme.surfaceBright.withValues(alpha: 0.5)
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
                : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: themeNotifier.getBorderRadiusAll(0.5),
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
                Symbols.arrow_drop_down_rounded,
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
            color: themeNotifier.needTransparentBG
                ? (!themeNotifier.isDarkMode
                      ? Theme.of(
                          context,
                        ).colorScheme.surfaceBright.withValues(alpha: 0.5)
                      : Theme.of(
                          context,
                        ).colorScheme.surfaceContainer.withValues(alpha: 0.8))
                : Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: themeNotifier.getBorderRadiusAll(0.5),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: Icon(
            Symbols.sort_rounded,
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
  Widget buildPageContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_referralResponse == null) return const SizedBox.shrink();

    final filteredComments = _getFilteredAndSortedComments();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          ReferralStatsWidget(
            themeNotifier: themeNotifier,
            comments: _referralResponse!.comments,
          ),
          const SizedBox(height: 16),
          ReferralCommentsList(
            themeNotifier: themeNotifier,
            comments: filteredComments,
          ),
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

  @override
  String get emptyTitle => 'No comments found';
}

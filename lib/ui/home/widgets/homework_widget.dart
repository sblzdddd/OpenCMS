import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/constants/periods.dart';
import '../../../data/models/homework/homework_response.dart';
import '../../../services/homework/homework_service.dart';
import 'dart:async';
import 'base_dashboard_widget.dart';

/// Widget that displays homework information
/// Shows recent homework items with due dates and status
class HomeworkCard extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;

  const HomeworkCard({super.key, this.onRefresh, this.refreshTick});

  @override
  State<HomeworkCard> createState() => _HomeworkCardState();
}

class _HomeworkCardState extends State<HomeworkCard>
    with AutomaticKeepAliveClientMixin, BaseDashboardWidgetMixin {
  @override
  bool get wantKeepAlive => true;

  HomeworkResponse? _homeworkData;
  final HomeworkService _homeworkService = HomeworkService();

  @override
  void initState() {
    super.initState();
    initializeWidget();
    startTimer();
  }

  @override
  void didUpdateWidget(covariant HomeworkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != null &&
        widget.refreshTick != oldWidget.refreshTick) {
      debugPrint(
        'HomeworkCard: refreshTick changed -> refreshing with refresh=true',
      );
      refresh();
    }
  }

  @override
  void dispose() {
    disposeMixin();
    super.dispose();
  }

  @override
  Future<void> initializeWidget() async {
    await _fetchHomework();
  }

  @override
  void startTimer() {
    // Update every hour to refresh homework status
    setCustomTimer(const Duration(hours: 1));
  }

  @override
  Future<void> refreshData() async {
    await _fetchHomework(refresh: true);
    // Call the parent refresh callback if provided
    widget.onRefresh?.call();
  }

  Future<void> _fetchHomework({bool refresh = false}) async {
    try {
      setLoading(true);
      setError(false);

      final homework = await _homeworkService.fetchHomework(
        academicYear: PeriodConstants.getAcademicYears().first.year,
        refresh: refresh,
      );

      if (mounted) {
        setState(() {
          _homeworkData = homework;
        });
        setLoading(false);
      }
    } catch (e) {
      if (mounted) {
        setLoading(false);
        setError(true);
      }
      debugPrint('HomeworkCard: Error fetching homework: $e');
    }
  }

  HomeworkItem? _getRecentHomework() {
    if (_homeworkData == null || _homeworkData!.homeworkItems.isEmpty) {
      return null;
    }

    // Sort by due date (latest first) and take up to 3 items
    final sortedHomework = List<HomeworkItem>.from(_homeworkData!.homeworkItems)
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

    return sortedHomework.reversed.first;
  }

  String _getDueDateText(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);

    final difference = dueDay.difference(today).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else if (difference <= 7) {
      return '$difference days';
    } else {
      return DateFormat('MMM dd').format(dueDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return buildCommonLayout();
  }

  @override
  String getWidgetTitle() => 'quickActions.homeworks'.tr();

  @override
  String getWidgetSubtitle() {
    final recentHomework = _getRecentHomework();
    if (recentHomework == null) return '';
    return recentHomework.title;
  }

  @override
  String? getBottomRightText() {
    final recentHomework = _getRecentHomework();
    if (recentHomework == null) return null;
    return _getDueDateText(recentHomework.dueDate);
  }

  @override
  String? getBottomText() {
    final recentHomework = _getRecentHomework();
    if (recentHomework == null) return null;
    return recentHomework.courseName;
  }

  @override
  String getLoadingText() => 'Loading homework...';

  @override
  String getErrorText() => 'Failed to load homework';

  @override
  String getNoDataText() => 'No recent homework';

  @override
  bool hasWidgetData() => _getRecentHomework() != null;

  @override
  String getActionId() => 'homeworks';

  @override
  IconData getWidgetIcon() => Symbols.edit_note_rounded;
}

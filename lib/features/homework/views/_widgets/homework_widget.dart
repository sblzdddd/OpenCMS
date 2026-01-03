import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../shared/constants/period_constants.dart';
import '../../models/homework_models.dart';
import '../../services/homework_service.dart';
import 'dart:async';
import '../../../home/views/widgets/base_dashboard_widget.dart';
import 'package:logging/logging.dart';

final logger = Logger('HomeworkCard');

class HomeworkCard extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;

  const HomeworkCard({super.key, this.onRefresh, this.refreshTick});

  @override
  State<HomeworkCard> createState() => _HomeworkCardState();
}

class _HomeworkCardState extends State<HomeworkCard>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  HomeworkResponse? _homeworkData;
  final HomeworkService _homeworkService = HomeworkService();
  bool _isLoading = true;
  bool _hasError = false;

  Future<void> _fetchWidgetData({bool refresh = false}) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

      final homework = await _homeworkService.fetchHomework(
        academicYear: PeriodConstants.getAcademicYears().first.year,
        refresh: refresh,
      );

      if (mounted) {
        setState(() {
          _homeworkData = homework;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      logger.severe('Error fetching homework', e, StackTrace.current);
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

  String _getWidgetSubtitle() {
    final recentHomework = _getRecentHomework();
    if (recentHomework == null) return '';
    return recentHomework.title;
  }

  String? _getBottomRightText() {
    final recentHomework = _getRecentHomework();
    if (recentHomework == null) return null;
    return _getDueDateText(recentHomework.dueDate);
  }

  String? _getBottomText() {
    final recentHomework = _getRecentHomework();
    if (recentHomework == null) return null;
    return recentHomework.courseName;
  }

  bool _hasWidgetData() => _getRecentHomework() != null;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BaseDashboardWidget(
      title: 'Homeworks',
      subtitle: _getWidgetSubtitle(),
      icon: Symbols.edit_note_rounded,
      actionId: 'homeworks',
      isLoading: _isLoading,
      hasError: _hasError,
      hasData: _hasWidgetData(),
      loadingText: 'Loading homework...',
      errorText: 'Failed to load homework',
      noDataText: 'No recent homework',
      bottomText: _getBottomText(),
      bottomRightText: _getBottomRightText(),
      onFetch: _fetchWidgetData,
      refreshTick: widget.refreshTick,
    );
  }
}

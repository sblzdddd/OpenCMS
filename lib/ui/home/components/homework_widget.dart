import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:intl/intl.dart';
import '../../../data/constants/period_constants.dart';
import '../../../data/models/homework/homework_response.dart';
import '../../../services/homework/homework_service.dart';
import '../../../pages/actions.dart';
import 'dart:async';

/// Widget that displays homework information
/// Shows recent homework items with due dates and status
class HomeworkCard extends StatefulWidget {
  final VoidCallback? onRefresh;
  final int? refreshTick;
  
  const HomeworkCard({super.key, this.onRefresh, this.refreshTick});

  @override
  State<HomeworkCard> createState() => _HomeworkCardState();
}

class _HomeworkCardState extends State<HomeworkCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  
  HomeworkResponse? _homeworkData;
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _updateTimer;
  
  final HomeworkService _homeworkService = HomeworkService();

  @override
  void initState() {
    super.initState();
    _fetchHomework();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant HomeworkCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != null && widget.refreshTick != oldWidget.refreshTick) {
      print('HomeworkCard: refreshTick changed -> refreshing with refresh=true');
      refresh();
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    // Update every hour to refresh homework status
    _updateTimer = Timer.periodic(const Duration(hours: 1), (_) {
      if (mounted) {
        setState(() {
          // Refresh to update overdue status
        });
      }
    });
  }

  /// Refresh the widget data
  Future<void> refresh() async {
    print('HomeworkCard: Refreshing homework');
    await _fetchHomework(refresh: true);
    // Call the parent refresh callback if provided
    widget.onRefresh?.call();
  }

  Future<void> _fetchHomework({bool refresh = false}) async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

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
      print('HomeworkCard: Error fetching homework: $e');
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
      return 'Due in $difference days';
    } else {
      return DateFormat('MMM dd').format(dueDate);
    }
  }

  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    
    final difference = dueDay.difference(today).inDays;
    
    if (difference < 0) {
      return Colors.red;
    } else if (difference == 0) {
      return Colors.orange;
    } else if (difference <= 2) {
      return Colors.orange;
    } else {
      return Theme.of(context).colorScheme.onSurface;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => buildActionPage({
                'id': 'homeworks',
                'title': 'Homeworks',
              }),
            ),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
          ),
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text('Loading homework...',
            style: TextStyle(
              fontSize: 8,
            ),
          ),
        ],
      );
    }
    
    if (_hasError) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.error_outline_rounded,
            fill: 1.0,
            color: Theme.of(context).colorScheme.error,
            size: 18,
          ),
          Text(
            'Failed to load homework',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const Spacer(),
          Text(
            'Swipe down to refresh',
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    final recentHomework = _getRecentHomework();
    
    if (recentHomework == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Symbols.book_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 18,
            fill: 1,
          ),
          Text(
            'Homeworks',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const Spacer(),
          Text(
            'No recent homework',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12, 
              color: Theme.of(context).colorScheme.onSurface
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Symbols.book_rounded,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
              fill: 1,
            ),
            const Spacer(),
            Text(
              _getDueDateText(recentHomework.dueDate),
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          recentHomework.courseName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const Spacer(),
        Text(
          recentHomework.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}

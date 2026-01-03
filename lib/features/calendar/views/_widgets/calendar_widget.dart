import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../models/calendar_today_item.dart';
import '../../services/calendar_service.dart';
import '../../../home/views/widgets/base_dashboard_widget.dart';
import 'package:logging/logging.dart';

final logger = Logger('CalendarWidget');

class CalendarWidget extends StatefulWidget {
  final Size? widgetSize;
  final VoidCallback? onRefresh;
  final int? refreshTick;

  const CalendarWidget({
    super.key,
    this.widgetSize,
    this.onRefresh,
    this.refreshTick,
  });

  @override
  State<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final CalendarService _calendarService = CalendarService();
  List<CalendarTodayItem> _items = const [];
  bool _isLoading = true;
  bool _hasError = false;

  bool get isWideMode {
    final size = widget.widgetSize;
    return size != null && size.width == 4 && size.height == 1.6;
  }

  Future<void> _fetchWidgetData({bool refresh = false}) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

      final data = await _calendarService.getTodayCalendar(refresh: refresh);
      if (!mounted) return;
      setState(() {
        _items = data;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
      logger.severe('Error fetching today\'s calendar: $e');
    }
  }

  String _formatRightSide() {
    if (_items.isEmpty) return '';
    final first = _items.first;
    if (first.time.isNotEmpty) return first.time;
    // fallback to date
    final now = DateTime.now();
    return DateFormat('EEE, MMM d').format(now);
  }

  String _getWidgetSubtitle() {
    if (_items.isEmpty) return 'No events today';
    return _items.first.title;
  }

  Widget? _getExtraContent(BuildContext context) {
    if (_items.length <= 1) return null;
    final color = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.75);

    // Show up to two more items below the subtitle
    final extras = _items.skip(1).take(isWideMode ? 6 : 2).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: isWideMode ? 0 : 4),
      child: Column(
        children: extras
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Symbols.event_rounded,
                      size: 14,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: color),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.time.isNotEmpty ? e.time : e.kindText,
                      style: TextStyle(fontSize: 11, color: color),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return BaseDashboardWidget(
      title: 'Calendar',
      subtitle: _getWidgetSubtitle(),
      icon: Symbols.calendar_month_rounded,
      actionId: 'calendar',
      isLoading: _isLoading,
      hasError: _hasError,
      hasData: _items.isNotEmpty,
      loadingText: 'Loading today\'s calendar...',
      errorText: 'Failed to load today\'s calendar',
      noDataText: 'No events today',
      rightSideText: _formatRightSide(),
      extraContent: _getExtraContent(context),
      onFetch: _fetchWidgetData,
      refreshTick: widget.refreshTick,
    );
  }
}

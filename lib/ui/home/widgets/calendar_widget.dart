import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../data/models/calendar/calendar_today_item.dart';
import '../../../services/calendar/calendar_service.dart';
import 'base_dashboard_widget.dart';

/// Dashboard widget that shows today's calendar items
/// Tapping anywhere navigates to the calendar page (id=calendar)
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
    with AutomaticKeepAliveClientMixin, BaseDashboardWidgetMixin {
  @override
  bool get wantKeepAlive => true;

  final CalendarService _calendarService = CalendarService();
  List<CalendarTodayItem> _items = const [];

  @override
  void initState() {
    super.initState();
    initializeWidget();
    startTimer();
  }

  @override
  void didUpdateWidget(covariant CalendarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != null &&
        widget.refreshTick != oldWidget.refreshTick) {
      debugPrint(
        'CalendarWidget: refreshTick changed -> refreshing with refresh=true',
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
    await _fetchToday();
  }

  @override
  void startTimer() {
    // Refresh every 30 minutes which is sufficient for calendar items
    setCustomTimer(const Duration(hours: 2));
  }

  @override
  Future<void> refreshData() async {
    await _fetchToday(refresh: true);
    widget.onRefresh?.call();
  }

  bool get isWideMode {
    final size = widget.widgetSize;
    return size != null && size.width == 4 && size.height == 1.6;
  }

  Future<void> _fetchToday({bool refresh = false}) async {
    try {
      setLoading(true);
      setError(false);

      final data = await _calendarService.getTodayCalendar(refresh: refresh);
      if (!mounted) return;
      setState(() {
        _items = data;
      });
      setLoading(false);
    } catch (e) {
      if (mounted) {
        setLoading(false);
        setError(true);
      }
      debugPrint('CalendarWidget: Error fetching today\'s calendar: $e');
    }
  }

  @override
  String getWidgetTitle() => 'Calendar';

  String _formatRightSide() {
    if (_items.isEmpty) return '';
    final first = _items.first;
    if (first.time.isNotEmpty) return first.time;
    // fallback to date
    final now = DateTime.now();
    return DateFormat('EEE, MMM d').format(now);
  }

  @override
  String? getRightSideText() => _formatRightSide();

  @override
  String getWidgetSubtitle() {
    if (_items.isEmpty) return 'No events today';
    return _items.first.title;
  }

  @override
  Widget? getExtraContent(BuildContext context) {
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
  bool hasWidgetData() => _items.isNotEmpty;

  @override
  String getActionId() => 'calendar';

  @override
  IconData getWidgetIcon() => Symbols.calendar_month_rounded;

  @override
  String getLoadingText() => 'Loading today\'s calendar...';

  @override
  String getErrorText() => 'Failed to load today\'s calendar';

  @override
  String getNoDataText() => 'No events today';

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return buildCommonLayout();
  }
}

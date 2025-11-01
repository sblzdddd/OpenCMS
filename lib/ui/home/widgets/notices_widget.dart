import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../services/theme/theme_services.dart';
import '../../../data/models/notification/notification_response.dart'
    as notification_model;
import '../../../data/models/notification/daily_bulletin_response.dart';
import '../../../data/models/events/student_event.dart';
import '../../../services/notification/notification_service.dart';
import '../../../services/notification/daily_bulletin_service.dart';
import '../../../services/events/events_service.dart';
import '../../../pages/actions.dart';
import 'base_dashboard_widget.dart';
import '../../shared/scaled_ink_well.dart';

class NoticeCard extends StatefulWidget {
  final Size? widgetSize;
  final VoidCallback? onRefresh;
  final int? refreshTick;

  const NoticeCard({
    super.key,
    this.widgetSize,
    this.onRefresh,
    this.refreshTick,
  });

  @override
  State<NoticeCard> createState() => _NoticeCardState();
}

class _NoticeCardState extends State<NoticeCard>
    with AutomaticKeepAliveClientMixin, BaseDashboardWidgetMixin {
  final NotificationService _notificationService = NotificationService();
  final DailyBulletinService _dailyBulletinService = DailyBulletinService();
  final EventsService _eventsService = EventsService();

  List<notification_model.Notification> _latestNotice = [];
  DailyBulletin? _latestBulletin;
  StudentEvent? _latestEvent;

  @override
  void initState() {
    super.initState();
    initializeWidget();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void didUpdateWidget(covariant NoticeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTick != null &&
        widget.refreshTick != oldWidget.refreshTick) {
      debugPrint(
        'NoticeCard: refreshTick changed -> refreshing with refresh=true',
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
    startTimer();
    await _fetchData();
  }

  @override
  Future<void> refreshData() async {
    await _fetchData(refresh: true);
    widget.onRefresh?.call();
  }

  Future<void> _fetchData({bool refresh = false}) async {
    try {
      setLoading(true);
      setError(false);

      // Fetch latest notice
      final notifications = await _notificationService.getSortedNotifications(
        refresh: refresh,
      );
      _latestNotice = notifications.isNotEmpty ? notifications : [];

      // Fetch latest daily bulletin for today
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final bulletins = await _dailyBulletinService.getDailyBulletinsList(
        date: todayString,
        refresh: refresh,
      );
      _latestBulletin = bulletins.isNotEmpty ? bulletins.first : null;

      // Fetch latest event
      final events = await _eventsService.fetchStudentLedEvents(
        refresh: refresh,
      );
      _latestEvent = events.isNotEmpty ? events.first : null;

      setLoading(false);
    } catch (e) {
      if (mounted) {
        setError(true);
        setLoading(false);
      }
    }
  }

  @override
  String getWidgetTitle() {
    return 'Notices';
  }

  /// Check if widget is in wide mode (4x1.6)
  bool get isWideMode {
    final size = widget.widgetSize;
    return size != null && size.width == 4 && size.height == 1.6;
  }

  @override
  String getWidgetSubtitle() {
    String subtitle = '';
    if (_latestNotice.isNotEmpty) {
      subtitle = _latestNotice.first.title;
      if (_latestNotice.length > 1) {
        subtitle += '\n${_latestNotice[1].title}';
      }
      if (_latestNotice.length > 2) {
        subtitle += '\n${_latestNotice[2].title}...';
      }
    }
    if (isWideMode) {
      return subtitle;
    } else {
      // For compact mode, show only notice title
      if (_latestNotice.isNotEmpty) {
        return subtitle;
      }
      return 'No recent notices';
    }
  }

  @override
  String? getRightSideText() {
    if (isWideMode) {
      return _latestNotice.isNotEmpty ? _latestNotice.first.addDate : null;
    } else {
      return null;
    }
  }

  @override
  Widget? getExtraContent(BuildContext context) {
    if (isWideMode) {
      return Column(
        children: [
          if (_latestBulletin != null) ...[
            const Divider(),
            _buildTappableSection(
              context: context,
              actionId: 'daily_bulletin',
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Bulletin',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _latestBulletin?.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        _latestBulletin?.department ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            _buildTappableSection(
              context: context,
              actionId: 'events',
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Events',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        _latestEvent?.title ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const Spacer(),
                      Text(
                        _latestEvent?.applicant ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    } else {
      // For compact mode, show bulletin info if available
      if (_latestBulletin != null) {
        return Column(
          children: [
            const Divider(height: 5),
            _buildTappableSection(
              context: context,
              actionId: 'daily_bulletin',
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _latestBulletin?.title ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                  Text(
                    _latestBulletin?.department ?? '',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }
    }
    return null;
  }

  /// Build a tappable section that properly handles navigation
  Widget _buildTappableSection({
    required BuildContext context,
    required String actionId,
    required Widget child,
  }) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    return ScaledInkWell(
      borderRadius: themeNotifier.getBorderRadiusAll(0.5),
      onTap: () async {
        final navigator = Navigator.of(context);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final page = await buildActionPage({'id': actionId});
          if (mounted) {
            navigator.push(MaterialPageRoute(builder: (_) => page));
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
        child: child,
      ),
    );
  }

  @override
  bool hasWidgetData() {
    return _latestBulletin != null || _latestEvent != null;
  }

  @override
  String getActionId() => 'notice';

  @override
  IconData getWidgetIcon() => Symbols.notifications_rounded;

  @override
  String getNoDataText() => 'No recent notices or bulletins';

  @override
  bool hasMultipleTapAreas() {
    // Return true if we have bulletin or events data (which create additional tap areas)
    return _latestBulletin != null || _latestEvent != null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    return buildCommonLayout();
  }
}

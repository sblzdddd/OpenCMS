import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:opencms/features/shared/constants/quick_actions.dart';
import 'package:provider/provider.dart';
import '../../../theme/services/theme_services.dart';
import '../../../notices/models/notification_response.dart'
    as notification_model;
import '../../../daily_bulletin/models/daily_bulletin_response.dart';
import '../../../events/models/student_event.dart';
import '../../../notices/services/notification_service.dart';
import '../../../daily_bulletin/services/daily_bulletin_service.dart';
import '../../../events/services/events_service.dart';
import '../../../shared/pages/actions.dart';
import 'base_dashboard_widget.dart';
import '../../../shared/views/widgets/scaled_ink_well.dart';

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
    with AutomaticKeepAliveClientMixin {
  final NotificationService _notificationService = NotificationService();
  final DailyBulletinService _dailyBulletinService = DailyBulletinService();
  final EventsService _eventsService = EventsService();

  List<notification_model.Notification> _latestNotice = [];
  DailyBulletin? _latestBulletin;
  StudentEvent? _latestEvent;

  bool _isLoading = true;
  bool _hasError = false;

  @override
  bool get wantKeepAlive => true;

  Future<void> _fetchWidgetData({bool refresh = false}) async {
    try {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _hasError = false;
        });
      }

      // Fetch latest notice
      final notifications = await _notificationService.getSortedNotifications(
        refresh: refresh,
      );
      
      // Fetch latest daily bulletin for today
      final today = DateTime.now();
      final todayString =
          '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      final bulletins = await _dailyBulletinService.getDailyBulletinsList(
        date: todayString,
        refresh: refresh,
      );

      // Fetch latest event
      final events = await _eventsService.fetchStudentLedEvents(
        refresh: refresh,
      );

      if (mounted) {
        setState(() {
          _latestNotice = notifications.isNotEmpty ? notifications : [];
          _latestBulletin = bulletins.isNotEmpty ? bulletins.first : null;
          _latestEvent = events.isNotEmpty ? events.first : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  /// Check if widget is in wide mode (4x1.6)
  bool get isWideMode {
    final size = widget.widgetSize;
    return size != null && size.width == 4 && size.height == 1.6;
  }

  String _getWidgetSubtitle() {
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

  Widget? _getExtraContent(BuildContext context) {
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
          final page = await buildActionPage(QuickAction(id: actionId, title: '', icon: ''));
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

  bool _hasWidgetData() {
    return _latestBulletin != null || _latestEvent != null;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return BaseDashboardWidget(
      title: 'Notices',
      subtitle: _getWidgetSubtitle(),
      icon: Symbols.notifications_rounded,
      actionId: 'notice',
      isLoading: _isLoading,
      hasError: _hasError,
      hasData: _hasWidgetData(),
      noDataText: 'No recent notices or bulletins',
      rightSideText: isWideMode 
          ? (_latestNotice.isNotEmpty ? _latestNotice.first.addDate : null) 
          : null,
      extraContent: _getExtraContent(context),
      onFetch: _fetchWidgetData,
      refreshTick: widget.refreshTick,
      hasMultipleTapAreas: _latestBulletin != null || _latestEvent != null,
    );
  }
}

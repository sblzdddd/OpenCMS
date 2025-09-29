import 'package:flutter/material.dart';
import '../../services/theme/theme_services.dart';
import '../../data/models/notification/notification_response.dart' as cms;
import '../../services/notification/notification_service.dart';
import '../shared/views/refreshable_view.dart';
import 'adaptive_notifications_layout.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends RefreshableView<NotificationsView> {
  final NotificationService _notificationService = NotificationService();
  List<cms.Notification>? _notifications;
  cms.Notification? _selectedNotification;

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final notifications = await _notificationService.getSortedNotifications(refresh: refresh);
    setState(() {
      _notifications = notifications;
    });
  }


  @override
  Widget buildContent(BuildContext context, ThemeNotifier themeNotifier) {
    if (_notifications == null) {
      return const Center(child: CircularProgressIndicator());
    }
      
    return AdaptiveNotificationsLayout(
      notifications: _notifications!,
      selectedNotification: _selectedNotification,
      onNotificationSelected: (notification) {
        setState(() {
          _selectedNotification = notification;
        });
      },
    );
  }

  @override
  String get emptyTitle => 'No notifications available';

  @override
  String get errorTitle => 'Error loading notifications';

  @override
  bool get isEmpty => _notifications == null || _notifications!.isEmpty;
}

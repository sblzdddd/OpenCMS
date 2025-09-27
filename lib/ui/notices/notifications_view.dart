import 'package:flutter/material.dart';
import '../../services/theme/theme_services.dart';
import '../../data/models/notification/notification_response.dart' as cms;
import '../../services/notification/notification_service.dart';
import '../shared/views/refreshable_view.dart';
import 'adaptive_notifications_layout.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

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
  Widget buildEmptyWidget(BuildContext context, ThemeNotifier themeNotifier) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Symbols.notifications_none_rounded,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'No notifications available',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Check back later for new notifications',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  String get errorTitle => 'Error loading notifications';

  @override
  bool get isEmpty => _notifications == null || _notifications!.isEmpty;
}

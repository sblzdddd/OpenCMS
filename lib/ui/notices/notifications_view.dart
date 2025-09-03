import 'package:flutter/material.dart';
import '../../data/models/notification/notification_response.dart' as cms;
import '../../services/notification/notification_service.dart';
import '../shared/views/refreshable_view.dart';
import '../../pages/actions/web_cms.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends RefreshableView<NotificationsView> {
  final NotificationService _notificationService = NotificationService();
  List<cms.Notification>? _notifications;

  @override
  Future<void> fetchData({bool refresh = false}) async {
    final notifications = await _notificationService.getSortedNotifications(refresh: refresh);
    setState(() {
      _notifications = notifications;
    });
  }

  Future<void> _navigateToNotificationDetail(cms.Notification notification) async {
    final contentUrl = await _notificationService.getNotificationContentUrl(notification.id);
    print(contentUrl);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebCmsPage(
          initialUrl: contentUrl,
          windowTitle: notification.title,
        ),
      ),
    );
  }

  Widget _buildNotificationItem(cms.Notification notification) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text(
          notification.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                if (notification.isPinned)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'PINNED',
                      style: TextStyle(
                        fontSize: 12, 
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (notification.isPinned) const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    notification.addDate,
                    style: TextStyle(
                      fontSize: 12, 
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToNotificationDetail(notification),
      ),
    );
  }

  @override
  Widget buildContent(BuildContext context) {
    if (_notifications == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemCount: _notifications!.length,
      itemBuilder: (context, index) {
        return _buildNotificationItem(_notifications![index]);
      },
    );
  }

  @override
  Widget buildEmptyWidget(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none_outlined,
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

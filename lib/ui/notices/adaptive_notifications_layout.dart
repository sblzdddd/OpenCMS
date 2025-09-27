import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/notification/notification_response.dart' as cms;
import '../../services/theme/theme_services.dart';
import '../../services/notification/notification_service.dart';
import '../shared/scaled_ink_well.dart';
import '../shared/views/adaptive_list_detail_layout.dart';
import '../shared/views/web_cms_content.dart';
import '../../pages/actions/web_cms.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class AdaptiveNotificationsLayout extends StatelessWidget {
  final List<cms.Notification> notifications;
  final Function(cms.Notification) onNotificationSelected;
  final cms.Notification? selectedNotification;
  final double breakpoint;

  const AdaptiveNotificationsLayout({
    super.key,
    required this.notifications,
    required this.onNotificationSelected,
    this.selectedNotification,
    this.breakpoint = 800.0,
  });

  @override
  Widget build(BuildContext context) {
    return AdaptiveListDetailLayout<cms.Notification>(
      items: notifications,
      selectedItem: selectedNotification,
      onItemSelected: onNotificationSelected,
      breakpoint: breakpoint,
      itemBuilder: (notification, isSelected) => _buildNotificationItem(notification, isSelected, context),
      detailBuilder: (notification) => _buildNotificationDetail(notification, context),
      emptyState: _buildEmptyState(context),
    );
  }

  Future<void> _navigateToNotificationDetail(cms.Notification notification, BuildContext context) async {
    final contentUrl = await NotificationService().getNotificationContentUrl(notification.id);
    if (context.mounted) {
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
  }

  Widget _buildNotificationItem(cms.Notification notification, bool isSelected, BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: true);
    
    return Material(
      color: Colors.transparent,
      child: ScaledInkWell(
        margin: const EdgeInsets.only(bottom: 8.0),
        background: (inkWell) => Material(
          color: isSelected ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: themeNotifier.getBorderRadiusAll(1),
          child: inkWell,
        ),
        onTap: () {
          onNotificationSelected(notification);
          // In mobile mode, navigate to detail page
          if (MediaQuery.of(context).size.width < breakpoint) {
            _navigateToNotificationDetail(notification, context);
          }
        },
        borderRadius: themeNotifier.getBorderRadiusAll(1),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: themeNotifier.getBorderRadiusAll(1),
            border: Border.all(
              color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5) : Theme.of(context).colorScheme.outline.withValues(alpha: 0),
              width: 1,
            ),
          ),
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            title: Text(
              notification.title,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
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
                          borderRadius: themeNotifier.getBorderRadiusAll(999),
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
                    if (notification.isPinned) const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                        borderRadius: themeNotifier.getBorderRadiusAll(999),
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
            trailing: const Icon(Symbols.arrow_forward_ios_rounded, size: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationDetail(cms.Notification notification, BuildContext context) {
    return FutureBuilder<String>(
      future: NotificationService().getNotificationContentUrl(notification.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError || !snapshot.hasData) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Symbols.error_outline_rounded,
                    size: 64,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load notification content',
                    style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Check if the widget is still mounted before building WebCmsContent
        if (!context.mounted) {
          return const SizedBox.shrink();
        }

        return WebCmsContent(
          key: ValueKey(notification.id),
          initialUrl: snapshot.data,
          windowTitle: notification.title,
          isWideScreen: true,
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              Symbols.notifications_none_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications available',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for new notifications',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../ui/shared/views/tabbed_page_base.dart';
import '../../ui/notices/views/notifications_view.dart';
import '../../ui/notices/views/daily_bulletin_view.dart';
import '../../ui/notices/views/events_view.dart';

class NoticesPage extends StatelessWidget {
  const NoticesPage({super.key, this.initialTabIndex = 0});
  final int initialTabIndex;

  @override
  Widget build(BuildContext context) {
    return TabbedPageBase(
      title: 'Notices',
      skinKey: ['notice', 'daily_bulletin', 'events'],
      initialTabIndex: initialTabIndex,
      tabs: const [
        Tab(text: 'Notifications'),
        Tab(text: 'Daily Bulletin'),
        Tab(text: 'Events'),
      ],
      tabViews: [
        const NotificationsView(),
        const DailyBulletinView(),
        const EventsView(),
      ],
    );
  }
}
